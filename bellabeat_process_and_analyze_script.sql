#Data too large to upload via Table Import Wizard
#Imported using LOAD DATA 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sec_heartrate_04.csv'
INTO TABLE sec_heartrate_04
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

#Change date_time's data type to datetime in sec_heartrate_03
#Add a new column with DATETIME type
ALTER TABLE sec_heartrate_03
ADD COLUMN temp_datetime DATETIME;

#Convert and update new column
UPDATE sec_heartrate_03
SET temp_datetime = STR_TO_DATE(date_time, '%m/%d/%Y %H:%i:%s');

#Drop old column
ALTER TABLE sec_heartrate_03
DROP column date_time;

#Rename new column to old column
ALTER TABLE sec_heartrate_03
CHANGE COLUMN temp_datetime date_time DATETIME;

#Change date_time's data type to datetime in sec_heartrate_04
#Add a new column with DATETIME type
ALTER TABLE sec_heartrate_04
ADD COLUMN temp_datetime DATETIME;

#Convert and update new column
UPDATE sec_heartrate_04
SET temp_datetime = STR_TO_DATE(date_time, '%Y-%m-%d %H:%i:%s');

#Drop old column
ALTER TABLE sec_heartrate_04
DROP column date_time;

#Rename new column to old column
ALTER TABLE sec_heartrate_04
CHANGE COLUMN temp_datetime date_time DATETIME;

#Combining hourly_calories_03 into daily_calories_03
CREATE TABLE daily_calories_03 AS
SELECT
	id,
    DATE(date_time) AS date,
    SUM(calories) AS calories
FROM hourly_calories_03
GROUP BY 
	id, date
ORDER BY
	id, date;
    
#Change date column into datetime and calories into int
ALTER TABLE daily_calories_03 ADD COLUMN temp_date DATETIME;

UPDATE daily_calories_03
SET temp_date = CAST(date AS DATETIME);

ALTER TABLE daily_calories_03 ADD COLUMN temp_calories INT;

UPDATE daily_calories_03
SET temp_calories = CAST(calories AS SIGNED);

ALTER TABLE daily_calories_03 DROP COLUMN date;
ALTER TABLE daily_calories_03 DROP COLUMN calories;

ALTER TABLE daily_calories_03 CHANGE COLUMN temp_date date DATETIME;
ALTER TABLE daily_calories_03 CHANGE COLUMN temp_calories calories INT;

    
#Combine similar datasets
CREATE TABLE daily_activity AS
SELECT id, date, week_day, steps, distance, very_active_min, fair_active_min, light_active_min, sed_min, calories FROM daily_activity_03
UNION 
SELECT id, date, week_day, steps, distance, very_active_min, fair_active_min, light_active_min, sed_min, calories FROM daily_activity_04;

CREATE TABLE weight_info AS
SELECT id, date_time, weight_lb, bmi FROM weight_info_03
UNION
SELECT id, date_time, weight_lb, bmi FROM weight_info_04;

CREATE TABLE hourly_calories AS
SELECT id, date_time, calories FROM hourly_calories_03
UNION
SELECT id, date_time, calories FROM hourly_calories_04;

CREATE TABLE hourly_steps AS
SELECT id, date_time, steps FROM hourly_steps_03
UNION
SELECT id, date_time, steps FROM hourly_steps_04;

CREATE TABLE min_sleep AS
SELECT id, date_time, sleep_value FROM min_sleep_03
UNION
SELECT id, date_time, sleep_value FROM min_sleep_04;

CREATE TABLE sec_heartrate AS
SELECT id, heartrate, date_time FROM sec_heartrate_03
UNION
SELECT id, heartrate, date_time FROM sec_heartrate_04;

CREATE TABLE daily_calories AS
SELECT id, date, calories FROM daily_calories_03
UNION
SELECT id, date, calories FROM daily_calories_04;

#Count number of entries per user
SELECT 
	id,
	COUNT(*) AS entries
FROM
	daily_activity
GROUP BY
	id;

#Search low entry users '2891001357' and '6391747486' to examine their data to see if any insight can be drawn from low entry users
SELECT
	*
FROM
	daily_activity
WHERE
	id='2891001357' OR id='6391747486';
    
#Determine if these users have significant data elsewhere
SELECT *
FROM
	hourly_calories
WHERE
	id='2891001357' OR id='6391747486';	
    
#Remove user '2891001357' across tables
DELETE FROM daily_activity
WHERE id='2891001357';

DELETE FROM daily_calories
WHERE id='2891001357';

DELETE FROM hourly_calories
WHERE id='2891001357';

DELETE FROM hourly_steps
WHERE id='2891001357';

DELETE FROM min_sleep
WHERE id='2891001357';

DELETE FROM sec_heartrate
WHERE id='2891001357';

DELETE FROM weight_info
WHERE id='2891001357';

#Check for hourly log count
SELECT 
	id,
    COUNT(id) as count
FROM
	hourly_steps
GROUP BY 
	id
ORDER BY
	count DESC;
    
#Investigate records missing the most hours of tracking, investigating daily_activity and min_sleep for low records     
SELECT
	*
FROM
	daily_activity 
WHERE
	id = '6391747486' OR id='4388161847' OR id='4057192912'
ORDER BY
	id,
    date;
    
#Investigate records missing the most hours of tracking, investigating daily_activity and min_sleep for low records     
SELECT
	*
FROM
	daily_activity 
WHERE
	id = '6391747486' OR id='4388161847' OR id='4057192912'
ORDER BY
	id,
    date;

#User '6391747486' has small amounts of data across the board, deleting across all tables
DELETE FROM daily_activity
WHERE id = '6391747486';

DELETE FROM daily_calories
WHERE id = '6391747486';

DELETE FROM hourly_calories
WHERE id = '6391747486';

DELETE FROM hourly_steps
WHERE id = '6391747486';

DELETE FROM min_sleep
WHERE id = '6391747486';

DELETE FROM sec_heartrate
WHERE id = '6391747486'
LIMIT 10000;

DELETE FROM weight_info
WHERE id = '6391747486';

#Check how many sleep logs each user has
SELECT
	id,
    COUNT(id) AS total_sleep_logs
FROM
	min_sleep
GROUP BY
	id
ORDER BY
	total_sleep_logs;

#Delete users ‘2320127002’, '2022484408', and ‘7007744171’ for low number of sleep logs 
DELETE FROM min_sleep
WHERE id='2320127002' OR id='2022484408' OR id='7007744171';

#See which column names are shared across tables
SELECT
	column_name,
	COUNT(*) AS column_count
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_SCHEMA = 'bellabeat'
GROUP BY
	column_name
ORDER BY
	column_count DESC;
    
#Calculate the average user
SELECT
    MIN(steps) AS min_steps,
    MAX(steps) AS max_steps,
	AVG(steps) AS avg_steps,
    MIN(distance) AS min_distance,
    MAX(distance) AS max_distance,
    AVG(distance) AS avg_distance,
    MIN(calories) AS min_calories,
    MAX(calories) AS max_calories,
    AVG(calories) AS avg_calories,
    MIN(very_active_min) AS min_very_active,
    MAX(very_active_min) AS max_very_active,
    AVG(very_active_min) AS avg_very_active,
    MIN(fair_active_min) AS min_fair_active,
    MAX(fair_active_min) AS max_fair_active,
    AVG(fair_active_min) AS avg_fair_active,
    MIN(light_active_min) AS min_light_active,
    MAX(light_active_min) AS max_light_active,
    AVG(light_active_min) AS avg_light_active,
    MIN(sed_min) AS min_sed,
    MAX(sed_min) AS max_sed,
    AVG(sed_min) AS avg_sed
FROM
	daily_activity;
    
#Calculate average daily steps, distance, and calories per day_of_week
#CREATE TEMPORARY TABLE steps_distance_calories_day_of_week AS #Creates a table to use to calculate correlation coefficient 
SELECT
	CASE
		WHEN DAYOFWEEK(date)=1 THEN 'Sunday'
        WHEN DAYOFWEEK(date)=2 THEN 'Monday'
        WHEN DAYOFWEEK(date)=3 THEN 'Tuesday'
        WHEN DAYOFWEEK(date)=4 THEN 'Wednesday'
        WHEN DAYOFWEEK(date)=5 THEN 'Thursday'
        WHEN DAYOFWEEK(date)=6 THEN 'Friday'
        WHEN DAYOFWEEK(date)=7 THEN 'Saturday'
	END AS day_of_week,
	AVG(calories) AS avg_calories,
    AVG(steps) AS avg_steps,
    AVG(distance) AS avg_distance
FROM
	daily_activity
GROUP BY
	day_of_week
ORDER BY
	FIELD(day_of_week, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
    
#Calculate correlation between average calories and average steps 
SELECT
	(n * sum_xy - sum_x * sum_y) /
    SQRT((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y*sum_y)) AS correlation
FROM (
	SELECT
		COUNT(*) AS n,
        SUM(avg_calories) AS sum_x,
        SUM(avg_steps) AS sum_y,
        SUM(avg_calories * avg_steps) AS sum_xy,
        SUM(avg_calories * avg_calories) AS sum_x2,
        SUM(avg_steps * avg_steps) AS sum_y2
	FROM
		steps_distance_calories_day_of_week
) AS stats;

#Calculate average calories burned per day of the week
SELECT
	AVG(calories) as avg_calories,
    CASE
		WHEN DAYOFWEEK(date_time) = 1 THEN 'Sunday'
		WHEN DAYOFWEEK(date_time) = 2 THEN 'Monday'
		WHEN DAYOFWEEK(date_time) = 3 THEN 'Tuesday'
		WHEN DAYOFWEEK(date_time) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(date_time) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(date_time) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(date_time) = 7 THEN 'Saturday'
	END AS day_of_week
FROM
	hourly_calories 
GROUP BY
	day_of_week
ORDER BY
	FIELD(day_of_week, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
    
#Calculate average steps burned per day of the week
SELECT
	AVG(steps) as avg_steps,
    CASE
		WHEN DAYOFWEEK(date_time) = 1 THEN 'Sunday'
		WHEN DAYOFWEEK(date_time) = 2 THEN 'Monday'
		WHEN DAYOFWEEK(date_time) = 3 THEN 'Tuesday'
		WHEN DAYOFWEEK(date_time) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(date_time) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(date_time) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(date_time) = 7 THEN 'Saturday'
	END AS day_of_week
FROM
	hourly_steps 
GROUP BY
	day_of_week
ORDER BY
	FIELD(day_of_week, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');

#Calculate average calories and steps burned per time of day	
SELECT
	AVG(cal.calories) as avg_calories,
    AVG(step.steps) as avg_steps,
    CASE
		WHEN HOUR(cal.date_time) BETWEEN 6 AND 11 THEN 'Morning'
		WHEN HOUR(cal.date_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		WHEN HOUR(cal.date_time) BETWEEN 18 and 21 THEN 'Evening'
		ELSE 'Night'
	END AS time_of_day
FROM
	hourly_calories AS cal
JOIN hourly_steps AS step ON cal.id=step.id
GROUP BY
	time_of_day
ORDER BY
    FIELD(time_of_day, 'Morning', 'Afternoon', 'Evening', 'Night');

#Calculate average calories burned per hour of day
SELECT
    AVG(calories) as avg_calories,
    CASE
		WHEN HOUR(date_time)=0 THEN '0'
		WHEN HOUR(date_time)=1 THEN '1'
        WHEN HOUR(date_time)=2 THEN '2'
        WHEN HOUR(date_time)=3 THEN '3'
        WHEN HOUR(date_time)=4 THEN '4'
        WHEN HOUR(date_time)=5 THEN '5'
        WHEN HOUR(date_time)=6 THEN '6'
        WHEN HOUR(date_time)=7 THEN '7'
        WHEN HOUR(date_time)=8 THEN '8'
        WHEN HOUR(date_time)=9 THEN '9'
        WHEN HOUR(date_time)=10 THEN '10'
        WHEN HOUR(date_time)=11 THEN '11'
        WHEN HOUR(date_time)=12 THEN '12'
        WHEN HOUR(date_time)=13 THEN '13'
        WHEN HOUR(date_time)=14 THEN '14'
        WHEN HOUR(date_time)=15 THEN '15'
        WHEN HOUR(date_time)=16 THEN '16'
        WHEN HOUR(date_time)=17 THEN '17'
        WHEN HOUR(date_time)=18 THEN '18'
        WHEN HOUR(date_time)=19 THEN '19'
        WHEN HOUR(date_time)=20 THEN '20'
        WHEN HOUR(date_time)=21 THEN '21'
        WHEN HOUR(date_time)=22 THEN '22'
        WHEN HOUR(date_time)=23 THEN '23'
	END AS time_of_day
FROM
	hourly_calories
GROUP BY
	time_of_day
ORDER BY
    FIELD(time_of_day, '0', '1', '2', '3', '4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23');
    
#Calculate average steps per hour of day
SELECT
    AVG(steps) as avg_steps,
    CASE
		WHEN HOUR(date_time)=0 THEN '0'
		WHEN HOUR(date_time)=1 THEN '1'
        WHEN HOUR(date_time)=2 THEN '2'
        WHEN HOUR(date_time)=3 THEN '3'
        WHEN HOUR(date_time)=4 THEN '4'
        WHEN HOUR(date_time)=5 THEN '5'
        WHEN HOUR(date_time)=6 THEN '6'
        WHEN HOUR(date_time)=7 THEN '7'
        WHEN HOUR(date_time)=8 THEN '8'
        WHEN HOUR(date_time)=9 THEN '9'
        WHEN HOUR(date_time)=10 THEN '10'
        WHEN HOUR(date_time)=11 THEN '11'
        WHEN HOUR(date_time)=12 THEN '12'
        WHEN HOUR(date_time)=13 THEN '13'
        WHEN HOUR(date_time)=14 THEN '14'
        WHEN HOUR(date_time)=15 THEN '15'
        WHEN HOUR(date_time)=16 THEN '16'
        WHEN HOUR(date_time)=17 THEN '17'
        WHEN HOUR(date_time)=18 THEN '18'
        WHEN HOUR(date_time)=19 THEN '19'
        WHEN HOUR(date_time)=20 THEN '20'
        WHEN HOUR(date_time)=21 THEN '21'
        WHEN HOUR(date_time)=22 THEN '22'
        WHEN HOUR(date_time)=23 THEN '23'
	END AS time_of_day
FROM
	hourly_steps
GROUP BY
	time_of_day
ORDER BY
    FIELD(time_of_day, '0', '1', '2', '3', '4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23');

#Calculate average total sleep minutes per day of the week
SELECT
    CAST(AVG(total_sleep_min) AS SIGNED) AS avg_total_sleep_min,
    day_of_week
FROM (
	SELECT
		id,
		COUNT(id) AS total_sleep_min,
		CASE
			WHEN DAYOFWEEK(date_time) = 1 THEN 'Sunday'
			WHEN DAYOFWEEK(date_time) = 2 THEN 'Monday'
			WHEN DAYOFWEEK(date_time) = 3 THEN 'Tuesday'
			WHEN DAYOFWEEK(date_time) = 4 THEN 'Wednesday'
			WHEN DAYOFWEEK(date_time) = 5 THEN 'Thursday'
			WHEN DAYOFWEEK(date_time) = 6 THEN 'Friday'
			WHEN DAYOFWEEK(date_time) = 7 THEN 'Saturday'
		END AS day_of_week
	FROM
		min_sleep
	GROUP BY
		day_of_week,
        id
) AS total_sleep
GROUP BY
    day_of_week
ORDER BY
    FIELD(day_of_week, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');

#Calculate average total sleep minutes per day of the week
SELECT
    AVG(total_sleep_min) AS avg_total_sleep_min,
    day_of_week
FROM (
	SELECT
		id,
		COUNT(id) AS total_sleep_min,
		CASE
			WHEN DAYOFWEEK(date_time) = 1 THEN 'Sunday'
			WHEN DAYOFWEEK(date_time) = 2 THEN 'Monday'
			WHEN DAYOFWEEK(date_time) = 3 THEN 'Tuesday'
			WHEN DAYOFWEEK(date_time) = 4 THEN 'Wednesday'
			WHEN DAYOFWEEK(date_time) = 5 THEN 'Thursday'
			WHEN DAYOFWEEK(date_time) = 6 THEN 'Friday'
			WHEN DAYOFWEEK(date_time) = 7 THEN 'Saturday'
		END AS day_of_week
	FROM
		min_sleep
	GROUP BY
		day_of_week,
        id
) AS total_sleep
GROUP BY
    day_of_week
ORDER BY
    FIELD(day_of_week, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');

#Calculate average total sleep minutes based on hour of day
SELECT
	AVG(total_sleep_min),
    time_of_day
FROM (
	SELECT
		id,
		COUNT(id) AS total_sleep_min,
		CASE
			WHEN HOUR(date_time)=0 THEN '0'
			WHEN HOUR(date_time)=1 THEN '1'
			WHEN HOUR(date_time)=2 THEN '2'
			WHEN HOUR(date_time)=3 THEN '3'
			WHEN HOUR(date_time)=4 THEN '4'
			WHEN HOUR(date_time)=5 THEN '5'
			WHEN HOUR(date_time)=6 THEN '6'
			WHEN HOUR(date_time)=7 THEN '7'
			WHEN HOUR(date_time)=8 THEN '8'
			WHEN HOUR(date_time)=9 THEN '9'
			WHEN HOUR(date_time)=10 THEN '10'
			WHEN HOUR(date_time)=11 THEN '11'
			WHEN HOUR(date_time)=12 THEN '12'
			WHEN HOUR(date_time)=13 THEN '13'
			WHEN HOUR(date_time)=14 THEN '14'
			WHEN HOUR(date_time)=15 THEN '15'
			WHEN HOUR(date_time)=16 THEN '16'
			WHEN HOUR(date_time)=17 THEN '17'
			WHEN HOUR(date_time)=18 THEN '18'
			WHEN HOUR(date_time)=19 THEN '19'
			WHEN HOUR(date_time)=20 THEN '20'
			WHEN HOUR(date_time)=21 THEN '21'
			WHEN HOUR(date_time)=22 THEN '22'
			WHEN HOUR(date_time)=23 THEN '23'
		END AS time_of_day
	FROM
		min_sleep
	GROUP BY
		time_of_day,
        id
) AS hourly_sleep
GROUP BY
	time_of_day
ORDER BY
	FIELD(time_of_day, '0', '1', '2', '3', '4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23');