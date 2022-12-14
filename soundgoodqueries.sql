---------- 1
CREATE VIEW lesson_and_booking AS
SELECT lesson.id AS lesson_id, lesson.lesson_type AS lesson_type, lesson_booking.id AS lesson_booking_id, lesson_booking.time_slot AS time_slot
FROM lesson FULL JOIN lesson_booking ON lesson.id = lesson_booking.id;

SELECT COUNT(lesson_id) AS lessons,
    COUNT(lesson_type) FILTER (WHERE lesson_type = 'individual') AS individual_lessons,
    COUNT(lesson_type) FILTER (WHERE lesson_type = 'group') AS group_lessons,
    COUNT(lesson_type) FILTER (WHERE lesson_type = 'ensemble') AS ensemble_lessons,
    EXTRACT(MONTH FROM time_slot) AS month
    FROM lesson_and_booking
    GROUP BY EXTRACT(MONTH FROM time_slot);

---------- 2
SELECT COUNT(s.student_id) number_of_students, COALESCE(sws.number_of_siblings, 0) number_of_siblings
FROM student s
LEFT JOIN (
  SELECT sibling_student_id AS student_id, COUNT(*) number_of_siblings
  FROM siblings
  GROUP BY sibling_student_id
) sws ON s.id = sws.student_id
GROUP BY sws.number_of_siblings
ORDER BY sws.number_of_siblings;

---------- 3
SELECT COUNT(instructor_id), instructor_id FROM lesson_booking
WHERE EXTRACT(MONTH FROM time_slot)= 11
GROUP BY instructor_id
HAVING COUNT(instructor_id) > 2;

---------- 4
CREATE MATERIALIZED VIEW ensemble_next_week AS
    SELECT to_char(time_slot, 'Day') AS day, target_genre, time_slot,
    CASE
        WHEN student_quota = 15 THEN 'no seats left'
        WHEN student_quota = 14 THEN 'one seats left'
        WHEN student_quota = 13 THEN 'two seats left'
        ELSE 'multiple seats left'
    END AS availability
    FROM lesson_booking
    FULL JOIN lesson ON lesson.id = lesson_booking.id
    WHERE EXTRACT(WEEK FROM time_slot)= 45 AND lesson_type = 'ensemble'
    ORDER BY target_genre;

---------- 5
VACUUM ANALYZE;

EXPLAIN SELECT COUNT(lesson_id) AS lessons,
    COUNT(lesson_type) FILTER (WHERE lesson_type = 'individual') AS individual_lessons,
    COUNT(lesson_type) FILTER (WHERE lesson_type = 'group') AS group_lessons,
    COUNT(lesson_type) FILTER (WHERE lesson_type = 'ensemble') AS ensemble_lessons,
    EXTRACT(MONTH FROM time_slot) AS month
    FROM lesson_and_booking
    GROUP BY EXTRACT(MONTH FROM time_slot);








