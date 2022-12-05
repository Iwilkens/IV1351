---------- 1
CREATE VIEW lesson_and_booking AS
SELECT lesson.id AS lesson_id, lesson.lesson_type AS lesson_type, lesson_booking.id AS lesson_booking_id, lesson_booking.time_slot AS time_slot
FROM lesson FULL JOIN lesson_booking ON lesson.id = lesson_booking.id;

SELECT COUNT(lesson_id) AS lessons, '' AS lesson_type
FROM lesson_and_booking
WHERE EXTRACT(MONTH FROM time_slot)= 11 AND EXTRACT(YEAR FROM time_slot)= 2022
UNION ALL
SELECT COUNT(lesson_booking_id) AS lessons_per_type, lesson_type
FROM lesson_and_booking
WHERE EXTRACT(MONTH FROM time_slot)= 11 AND EXTRACT(YEAR FROM time_slot)= 2022
GROUP BY lesson_type;

---------- 2
SELECT SUM(case when sibling_student_id is null then 1 else 0 end) students_without_siblings,
count(sibling_student_id) number_of_siblings, sibling_student_id AS student_id
FROM siblings
LEFT JOIN student ON student.id = sibling_student_id
GROUP BY sibling_student_id ORDER BY sibling_student_id;

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


  SELECT to_char(time_slot, 'Day') AS day, target_genre, time_slot,
        CASE
            WHEN student_quota = 15 THEN 'No seats left'
            WHEN student_quota = 14 THEN 'One seats left'
            WHEN student_quota = 13 THEN 'Two seats left'
            ELSE 'Many seats left'
        END AS availability
        FROM ensemble_nextweek;

---------- 5
VACUUM ANALYZE;

EXPLAIN SELECT COUNT(lesson_id) AS lessons, '' AS lesson_type
FROM lesson_and_booking
WHERE EXTRACT(MONTH FROM time_slot)= 11 AND EXTRACT(YEAR FROM time_slot)= 2022
UNION ALL
SELECT COUNT(lesson_booking_id) AS lessons_per_type, lesson_type
FROM lesson_and_booking
WHERE EXTRACT(MONTH FROM time_slot)= 11 AND EXTRACT(YEAR FROM time_slot)= 2022
GROUP BY lesson_type;