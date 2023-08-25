--Union all the 12 tables into a single data table Cyclistic_TripData_2022
--(5667717 rows affected)
SELECT *
INTO Cyclistic_TripData_2022
FROM [PortfolioProjects].[dbo].[202201-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202202-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202203-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202204-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202205-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202206-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202207-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202208-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202209-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202210-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202211-divvy-tripdata]
UNION ALL
SELECT *
FROM [PortfolioProjects].[dbo].[202212-divvy-tripdata]

		-----DATA EXPLORATION AND CHECK-----
--View table
SELECT TOP 10 *
FROM 
	[PortfolioProjects].[dbo].[202212-divvy-tripdata]

--Counting number of rows
SELECT 
	COUNT(*)
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]

--Counting the number of rides by casual members and rides by annual members
SELECT 
	member_casual,
	COUNT(*) AS number_of_rides
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY 
	member_casual

--Counting the number of rideable type
--The results show 3 bike types, which is again what we expected:  electric_bike, classic_bike, docked_bike.
SELECT
	rideable_type,
	COUNT(1)
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY
	rideable_type

--Checking member_casual column
SELECT 
	DISTINCT member_casual
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]

--Checking the ranges of lat and lng
SELECT 
	MIN(start_lat) AS min_start_lat,
	MAX(start_lat) AS max_start_lat,
	MIN(start_lng) AS min_start_lng,
	MAX(start_lng) AS max_start_lng,
	MIN(end_lat) AS min_end_lat,
	MAX(end_lat) AS max_end_lat,
	MIN(end_lng) AS min_end_lng, 
	MAX(end_lng) AS max_end_lng
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]

--Checking ride ids
SELECT
	ride_id,
	COUNT(*)
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY
	ride_id
HAVING
	COUNT(*) > 1

--Checking for nulls in ride_id, rideable_type, started_at, ended_at, member_casual
SELECT COUNT(*) 
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
WHERE
	ride_id IS NULL OR rideable_type IS NULL OR started_at IS NULL or ended_at IS NULL or member_casual IS NULL

--Checking for nulls in start_station_id, start_station_name
SELECT COUNT(*) 
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
WHERE
	start_station_id IS NULL or start_station_name IS NULL

--Checking for nulls in end_station_id, end_station_name
SELECT COUNT(*) 
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
WHERE
	end_station_id IS NULL or end_station_name IS NULL

--Checking for nulls in start_lat, end_lat
SELECT COUNT(*) 
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
WHERE
	start_lat IS NULL or end_lat IS NULL

--Checking for nulls in start_lng, end_lng
SELECT COUNT(*) 
FROM 
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
WHERE
	start_lng IS NULL or end_lng IS NULL

		-----DATA CLEANING-----
--Deleting all rows with null field
--(1298357 rows affected)
DELETE
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
WHERE
	ride_id IS NULL 
	OR rideable_type IS NULL
	OR started_at IS NULL
	OR ended_at IS NULL
	OR start_station_name IS NULL
	OR start_station_id IS NULL
	OR end_station_name IS NULL
	OR end_station_id IS NULL
	OR start_lat IS NULL
	OR start_lng IS NULL
	OR end_lat IS NULL
	OR end_lng IS NULL
	OR member_casual IS NULL

SELECT *
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
WHERE STARTED_AT >= ENDED_AT;

--Creating new column to calculate the trip duration in seconds
ALTER TABLE [PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
ADD ride_length_seconds float

--Calculating trip duration
UPDATE [PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
SET ride_length_seconds = DATEDIFF(SECOND, started_at, ended_at) --(4369360 rows affected)

--Creating new column to calculate the day of the week
ALTER TABLE [PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
ADD day_of_week nvarchar(50)

--Getting the day of the week
UPDATE [PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
SET day_of_week = FORMAt(started_at, 'dddd') --(4369360 rows affected)

--Creating new column to calculate the month
ALTER TABLE [PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
ADD month nvarchar(50)

--Getting the month
UPDATE [PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
SET month = FORMAt(started_at, 'MM') --(4369360 rows affected)

--Creating new column to calculate the hour of the day
ALTER TABLE [PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
ADD hour_of_day nvarchar(50)

--Getting the hour_of_day
UPDATE [PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
SET hour_of_day = FORMAt(started_at, 'HH') --(4369360 rows affected)

--Checking if there is any ride_length_seconds less than or equal to 0
--Less than or equal to 0 means that end time is earlier than start time, which is not possible
SELECT
	 COUNT(ride_length_seconds)
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
WHERE
	ride_length_seconds <= 0  --308 rides contain time less than or equal to ZERO.

--Checking if there is any rides was out longer than a day(24H).
SELECT
	 COUNT(ride_length_seconds)
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
WHERE
	ride_length_seconds >= 24*60*60 --156 rides

--Deleting rows with ride_length_seconds <= 0 AND > one day
DELETE
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
WHERE
	ride_length_seconds <= 0 
	OR ride_length_seconds >= 24*60*60  --(464 rows affected)

-----------------------------------------------DATA ANALYSIS------------------------------------------------------
--4368896 TOTAL riders
--1757913 casual riders 40.24%
--2610983 member riders 59.76%

--(1)Calculating the average ride length by each group
SELECT
	member_casual,
	AVG(ride_length_seconds)/60 as avg_ride_length_min
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY 
	member_casual -- AVG ride length for casual riders is 23.71 minutes
				  -- While AVG ride length for member riders is 12.44 minutes.

--(2)Calculating the average ride length daily in every monthly by each group
SELECT
	member_casual,
	month,
	day_of_week,
	AVG(ride_length_seconds)/60 as avg_ride_length_min,
	COUNT(member_casual) AS Total_rides_daily
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY 
	member_casual,
	month,
	day_of_week
ORDER BY
	month,
	day_of_week,
	member_casual

--(3)Calculating time spent by each group
SELECT
	member_casual,
	(SUM(ride_length_seconds))/(60*60) AS Total_ride_length
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY member_casual --694705.13 hour casual total ride length  "56.2%"
					   --541351.72 hour member total ride length  "43.8"

--(4)Calculating time spent by each group monthly
SELECT
	member_casual,
	month,
	(SUM(ride_length_seconds))/(60*60) AS Total_ride_length_hour
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY 
	member_casual,
	month
ORDER BY
	2,1

--(5)Calculating the pereferred types of bikes for each group
SELECT
	member_casual,
	rideable_type,
	COUNT(rideable_type) number_of_rides
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY
	member_casual,
	rideable_type

--(6)Calculating total number of rides by each group monthly
SELECT
	member_casual,
	month,
	COUNT(member_casual) AS Total_rides_monthly
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY
	member_casual,
	month
ORDER BY 
	2,1

--(7)Calculating total number of rides by each group daily
SELECT
	member_casual,
	day_of_week,
	COUNT(member_casual) AS Total_rides_daily
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY
	member_casual, 
	day_of_week
ORDER BY
	2,1

--(8) Calculating total number of rides by each group daily in each month
SELECT
	member_casual,
	month,
	day_of_week,
	COUNT(member_casual) AS Total_rides_daily
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022]
GROUP BY
	member_casual,
	month,
	day_of_week
ORDER BY
	2,3,1

--(9)Calculating total rides monthly for each route
------------Finding the top routes for each season by each group------------------------
--For Casual
SELECT
	*
FROM 
	( SELECT
		start_station_name,
		end_station_name,
		month,
		member_casual,
		COUNT(*) AS Total_rides_monthly,
		ROW_NUMBER() OVER(PARTITION BY member_casual, month ORDER BY COUNT(member_casual)DESC
			 ) AS route_rank
	FROM
		[PortfolioProjects].[dbo].[Cyclistic_TripData_2022] 
	GROUP BY
		start_station_name,
		end_station_name,
		month,
		member_casual
	) ranks
WHERE 
	route_rank <=5 AND
	member_casual = 'casual'
ORDER BY 3,5 DESC

--For Members
SELECT
	*
FROM 
	( 
	SELECT
		start_station_name,
		end_station_name,
		month,
		member_casual,
		COUNT(*) AS Total_rides_monthly,
		ROW_NUMBER() OVER(PARTITION BY member_casual, month ORDER BY COUNT(member_casual)DESC
			 ) AS route_rank
	FROM
		[PortfolioProjects].[dbo].[Cyclistic_TripData_2022] 
	GROUP BY
		start_station_name,
		end_station_name,
		month,
		member_casual
	) ranks
WHERE 
	route_rank <=5 AND
	member_casual = 'member'
ORDER BY 3,5 DESC

--(10) Calculating total number of rides by hour daily for each group
SELECT
	member_casual,
	day_of_week,
	hour_of_day,
	COUNT(member_casual) AS Total_rides
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022] 
GROUP BY 
	member_casual,
	day_of_week,
	hour_of_day
ORDER BY
	2,3,1

--(11) Calculating total number of rides by hour for each group
SELECT
	member_casual,
	hour_of_day,
	COUNT(member_casual) AS Total_rides
FROM
	[PortfolioProjects].[dbo].[Cyclistic_TripData_2022] 
GROUP BY 
	member_casual,
	hour_of_day
ORDER BY
	2,3,1
