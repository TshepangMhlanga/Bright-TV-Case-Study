-- Databricks notebook source
With user_profiles AS
(SELECT UserID,
        CASE --classifying province     
            WHEN province = 'None' THEN 'unknown'
            WHEN province = ' ' THEN 'unknown'
            WHEN province IS NULL THEN 'unknown'
            WHEN province = 'Other' THEN 'uknown'
        ELSE province
        END AS Region,

        Age,
          CASE  
                WHEN CAST(Age AS INT) = 0 THEN 'Infant'
                WHEN CAST(Age AS INT) BETWEEN 1 AND 12 THEN 'Kids'
                WHEN CAST(Age AS INT) BETWEEN 13 AND 17 THEN 'Teenager'
                WHEN CAST(Age AS INT) BETWEEN 18 AND 35 THEN 'Youth'
                WHEN CAST(Age AS INT) BETWEEN 36 AND 50 THEN 'Adults'
                WHEN CAST(Age AS INT) BETWEEN 51 AND 60 THEN 'Elder'
                WHEN CAST(Age AS INT) BETWEEN 61 AND 64 THEN 'Senior'
                WHEN CAST(Age AS INT) >= 65 THEN 'Pensioner'
              END AS Age_group,

           CASE --classifying email
                WHEN Email IS NOT NULL THEN 1 
                WHEN Email <> ' ' THEN 1 
                ELSE 0 
           END AS Email_flag, 

        CASE --classifying social media handle
            WHEN `Social Media Handle` IS NOT NULL THEN 1 
            ELSE 0 
        END AS Social_media_handle_flag,
   

           CASE ---Creating gender classification
                 WHEN Gender = 'None' THEN 'unknown' 
                 WHEN Gender = ' ' THEN 'unknown' 
                 WHEN Gender IS NULL THEN 'unknown' 
                 ELSE Gender 
              END AS Sex,
               
             CASE---classifying race
                 WHEN Race = 'None' THEN 'unknown' 
                 WHEN Race = ' ' THEN 'unknown' 
                 WHEN Race = 'other' THEN 'unknown' 
                 WHEN Race IS NULL THEN 'unknown' 
                 ELSE Race 
             END AS Ethnicity
 FROM bright_tv.data.user_profiles),

Viewership AS
              (SELECT
              COALESCE (UserID0, userid4) AS User_id,-- combining two user ids into one
              From_UTC_Timestamp(RecordDate2, 'Africa/Johannesburg') AS RecordDate_SAST,--converting timestamp to SA time 
	          Channel2,
             `Duration 2`
FROM bright_tv.data.viewership
),
Cleaned_viewership AS
( SELECT
              User_id,
              RecordDate_SAST,
              TO_DATE(RecordDate_SAST) AS watch_date, -- Convert a string into a date YYYY-MM=-DD 
              DAYNAME(TO_DATE(RecordDate_SAST))AS day_name, -- Extract the day name 
              MONTHNAME(TO_DATE(RecordDate_SAST)) AS month_name, -- Extracts the month name 
               YEAR(TO_DATE(RecordDate_SAST)) AS event_year, -- Extracts the year value 
               DAY(TO_DATE(RecordDate_SAST)) AS event_day, -- Extracts the day value 
               HOUR(RecordDate_SAST) AS Hour_of_day,--extracts hour of day
        CASE 
               WHEN DAYNAME(TO_DATE(RecordDate_SAST)) IN ('Sat', 'Sun') THEN '02. Weekend' 
               ELSE '01. Weekday' 
        END AS day_classification,

        date_format(RecordDate_SAST, 'HH:mm:ss') AS Watch_time,--converting date format to time
    CASE
        WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
        WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
        WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
        WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
    END AS Time_of_day,

    
     `Duration 2`,
        DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS Duration,--converting duration into time format
(
    HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) +
    MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 60.0 + --converting minutes to seconds
    SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) / 3600.0--converting seconds to minutes
) AS Duration_hours, 

        (
            HOUR(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 3600 + --converting hours to seconds
            MINUTE(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss')) * 60 + ---converting minutes to seconds
            SECOND(TO_TIMESTAMP(`Duration 2`, 'HH:mm:ss'))
        ) AS Duration_seconds,    

    CASE
        WHEN Duration_seconds BETWEEN 300 AND 1800 THEN '01. Low Usage (<30 min)'
        WHEN Duration_seconds BETWEEN 1801 AND 3599 THEN '02. Medium Usage (<60 min)'
        WHEN Duration_seconds >= 3600 THEN '03. High Usage (>60 min)'
        ELSE '04. No Usage'
    END AS Screen_time_bucket, 

      CASE --cleaning channel
        WHEN Channel2 IN ('SawSee','Sawsee') THEN 'SawSee'
        WHEN Channel2 IN ('SuperSport Live Events','Live on SuperSport', 'Supersport Live Events', 'DStv Events 1') THEN 'Live Events'
        ELSE Channel2
    END AS Tv_channel
FROM viewership)

----Creating the final table
SELECT 
      COALESCE (A. User_id, B. UserID) AS Sub_ID,
          Sex,
          Ethnicity,
          Age_group,
          Region,
          Email_flag,
          Social_media_handle_flag,
          RecordDate_SAST,
          Watch_date,
          Day_name,
          Month_name,
          Event_year,
          Event_day,
          Hour_of_day,
          Day_classification,
          Watch_time,
          Time_of_day,
          Duration,
          Duration_hours,
          Duration_seconds,
          Screen_time_bucket, 
          Tv_channel
FROM Cleaned_viewership AS A
LEFT JOIN user_profiles AS B
ON A.User_id=B.UserID;