-- Databricks notebook source
SELECT * FROM bright_tv.data.user_profiles;
-------------------------------------------------
--gender checks 
-----------------------------------------------------
SELECT DISTINCT gender 
FROM bright_tv.data.user_profiles;
------------------------------------------------------------
---- if gender has an empty space is not known we replace it as unknown
---------------------------------------------------------------------
SELECT DISTINCT
CASE
   WHEN gender = 'None' THEN 'unknown'
   WHEN gender = ' ' THEN 'unknown'
   WHEN gender IS NULL  THEN 'unknown'
ELSE gender
END AS sex 
FROM bright_tv.data.user_profiles;

-----------------------------------------
-- Race checks 
----------------------------------------
SELECT DISTINCT race 
FROM bright_tv.data.user_profiles;


SELECT DISTINCT 
CASE
   WHEN race = 'other' THEN 'unknown'
   WHEN race = 'None' THEN 'unknown'
   WHEN race = ' ' THEN 'unknown'
   WHEN race IS NULL  THEN 'unknown'
ELSE race
END AS ethnicity 
FROM bright_tv.data.user_profiles;

-------------------------------------------------
---- Province Checks
----------------------------------------------------
SELECT DISTINCT province
FROM bright_tv.data.user_profiles;

SELECT DISTINCT
      CASE
          WHEN province = 'other'THEN 'unknown'
          WHEN province = ' ' THEN 'unknown'
          WHEN province = 'None' THEN 'unknown'
          WHEN province IS NULL THEN 'unknown'
     ELSE province
    END AS Region 
FROM bright_tv.data.user_profiles;
--------------------------------------------------
-- Age Checks
----------------------------------------------------
SELECT min (Age) AS min_age, -- Finding youngest user = 0
       max (Age) AS max_age,  --
       avg (Age) AS average_age
FROM bright_tv.data.user_profiles;

--------------------------------------------------

SELECT COUNT(DISTINCT UserID) AS subs,
CASE  
          WHEN Age = 0 THEN 'Infant'
          WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
          WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
          WHEN Age BETWEEN 20 AND 35 THEN 'Youth'
          WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
          WHEN Age > 50 AND Age <= 60 THEN 'Elder'
          WHEN Age > 64 THEN 'Pensioner'
     END AS Age_group
FROM bright_tv.data.user_profiles
GROUP BY Age_group;


----------------------------------------------------------------
--tEPORARY tBALE--
------
CREATE OR REPLACE TEMPORARY TABLE processed_bright_tv_user_profiles As 
(SELECT 
     UserID,
        Email,
        CASE 
            WHEN 'Email' IS NOT NULL THEN 1
            WHEN 'Email'<> ' ' THEN 1
            ELSE 0
        END AS email_flag,

        CASE 
            WHEN 'Social Media Handle' IS NOT NULL THEN 1
            ELSE 0
        END AS Social_media_handle_flag,

        CASE
            WHEN gender = 'None' THEN 'unknown'
            WHEN gender = ' ' THEN 'unknown'
            WHEN gender IS NULL THEN 'unknown' 
        ELSE gender 
        END AS sex,
    
        CASE
            WHEN race = 'other' THEN 'unknown'
            WHEN race = ' ' THEN 'unknown'
            WHEN race = 'None' THEN 'unknown'
            WHEN race IS NULL THEN 'unknown'
        ELSE race
        END AS Enthnicity, 


       province,
        CASE
            WHEN province = 'None' THEN 'unknown'
            WHEN province = ' ' THEN 'unknown'
            WHEN province IS NULL THEN 'unknown'
        ELSE province
        END AS Region,

        AGE,
        CASE 
            WHEN Age = 0 THEN '01.infant: 0'
            WHEN Age BETWEEN 1 AND 12 THEN '02.Kids: 1 - 12'
            WHEN Age BETWEEN 13 AND 17 THEN '03.youth: 13 - 17'
            WHEN Age BETWEEN 18 AND 35 THEN '04.youth Adults: 18 - 35'
            WHEN Age BETWEEN 36 AND 50 THEN '05.Adults: 36 - 50'
            WHEN Age > 50 AND Age<=60 THEN '06.Elder: 51 -60'
            WHEN Age > 60 THEN '07.Pensioner: >60'
        END AS Age_group
        From bright_tv.data.user_profiles);




select * from processed_bright_tv_user_profiles;


