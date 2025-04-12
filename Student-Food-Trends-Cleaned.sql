-- File: diet_cleaning.sql
-- Purpose: Standardizes and cleans diet-related free-text input

SELECT *
FROM food_coded;

-- Delete rows with NULL row_id or the most recent entry with a NULL ideal_diet
DELETE FROM food_coded WHERE row_id IS NULL OR row_id = (SELECT MAX(row_id) FROM food_coded WHERE ideal_diet IS NULL);

-- Create Staging as a working column from the original
CREATE TABLE food_coded_staging
LIKE food_coded;

-- Insert data from original table to staging table
INSERT food_coded_staging
SELECT *
FROM food_coded;


SELECT *
FROM food_coded_staging;

-- Auto-increment primary key to both table as row_id
ALTER TABLE food_coded ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;
ALTER TABLE food_coded_staging ADD COLUMN row_id INT AUTO_INCREMENT PRIMARY KEY;

-- Remove irrelevant columns from staging table
ALTER TABLE food_coded_staging
	-- Column does not contain relevant data or column does not have any reference data
	DROP COLUMN calories_day,
    DROP COLUMN cuisine,
    DROP COLUMN drink,
    DROP COLUMN eating_out,
    DROP COLUMN employment,
    DROP COLUMN ethnic_food,
    DROP COLUMN exercise, 
    DROP COLUMN food_childhood,
    DROP COLUMN fruit_day,
    DROP COLUMN grade_level,
    DROP COLUMN greek_food,
    DROP COLUMN healthy_feeling,
    DROP COLUMN income,
    DROP COLUMN indian_food,
    DROP COLUMN italian_food,
    DROP COLUMN life_rewarding,
    DROP COLUMN marital_status,
    DROP COLUMN meals_dinner_friend,
    DROP COLUMN mother_education,
    DROP COLUMN mother_profession,
    DROP COLUMN nutritional_check,
    DROP COLUMN on_off_campus,
    DROP COLUMN parents_cook,
    DROP COLUMN pay_meal_out,
    DROP COLUMN persian_food,
    DROP COLUMN self_perception_weight,
    DROP COLUMN soup,
    DROP COLUMN thai_food,
    DROP COLUMN veggies_day,
    DROP COLUMN vitamins,
    DROP COLUMN fries,
    DROP COLUMN cook, 
    DROP COLUMN eating_changes_coded1, -- repeated coding
    DROP COLUMN fav_food;

-- Remove leftover irrelevant columns (clean-up)
ALTER TABLE food_coded_staging
	DROP COLUMN fries,
    DROP COLUMN cook;
   
ALTER TABLE food_coded_staging
    DROP COLUMN comfort_food_reasons_coded;

-- Rename awkwardly named column 
ALTER TABLE food_coded_staging
RENAME COLUMN `comfort_food_reasons_coded_[0]` TO comfort_food_reasons_coded;
    
 -- Checking for duplicates using CTE
WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY GPA, Gender, comfort_food, comfort_food_reasons, comfort_food_reasons_coded, diet_current, diet_current_coded, eating_changes_coded, fav_cuisine, fav_cuisine_coded, healthy_meal, ideal_diet, ideal_diet_coded, sports, type_sports, weight) as row_num
FROM food_coded_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;
-- No duplicates found

-- Standartizing Data

-- Turn off safe updates
SET SQL_SAFE_UPDATES = 0; -- Turn off safe updates

SELECT *
FROM food_coded_staging;

-- Delete 'nan' values from comfort_food
DELETE FROM food_coded_staging
WHERE comfort_food = 'nan';

-- Alter Gender column to change data type from INT to TEXT to allow text values
ALTER TABLE food_coded_staging 
MODIFY COLUMN Gender TEXT;

-- Update 'Gender' column to change 1's to Female
UPDATE food_coded_staging 
SET Gender = 'Female'
WHERE Gender = '1';

-- Update 'Gender' column to change 2's to Male
UPDATE food_coded_staging 
SET Gender = 'Male'
WHERE Gender = '2';

-- Capitalize the first letter in key columns for consistency
UPDATE food_coded_staging
SET comfort_food = CONCAT(UCASE(LEFT(comfort_food, 1)), LCASE(SUBSTRING(comfort_food, 2))) 
WHERE comfort_food IS NOT NULL;

UPDATE food_coded_staging
SET healthy_meal = CONCAT(UCASE(LEFT(healthy_meal, 1)), LCASE(SUBSTRING(healthy_meal, 2)))
WHERE healthy_meal IS NOT NULL;

UPDATE food_coded_staging
SET ideal_diet = CONCAT(UCASE(LEFT(ideal_diet, 1)), LCASE(SUBSTRING(ideal_diet, 2)))
WHERE ideal_diet IS NOT NULL;

UPDATE food_coded_staging
SET type_sports = CONCAT(UCASE(LEFT(type_sports, 1)), LCASE(SUBSTRING(type_sports, 2)))
WHERE type_sports IS NOT NULL;

-- Cleaning comfort_food_reasons data by adding cleaned column, inserting cleaned data to new column, and deleting uncleaned column
ALTER TABLE food_coded_staging ADD COLUMN comfort_food_reasons_cleaned VARCHAR(50) AFTER comfort_food_reasons_coded; 

UPDATE food_coded_staging 
SET comfort_food_reasons_cleaned =
	CASE 
		WHEN comfort_food_reasons_coded = 1 THEN 'Stress'
		WHEN comfort_food_reasons_coded = 2 THEN 'Boredom'
		WHEN comfort_food_reasons_coded = 3 THEN 'Sadness'
		WHEN comfort_food_reasons_coded = 4 THEN 'None'
        WHEN comfort_food_reasons_coded = 9 THEN 'None'
		WHEN comfort_food_reasons_coded = 5 THEN 'Tired'
		WHEN comfort_food_reasons_coded = 7 THEN 'Happy'
		ELSE 'Other'
	END;

ALTER TABLE food_coded_staging 
DROP COLUMN comfort_food_reasons;

-- Cleaning diet_current data by adding cleaned column, inserting cleaned data to new column, and deleting uncleaned column
ALTER TABLE food_coded_staging ADD COLUMN diet_current_cleaned VARCHAR(50) AFTER diet_current_coded;

UPDATE food_coded_staging
SET diet_current_cleaned =
	CASE 
		WHEN diet_current_coded = 1 THEN 'Healthy'
        WHEN diet_current_coded = 2 THEN 'Somewhat Unhealthy'
        WHEN diet_current_coded = 3 AND 4 THEN 'Structured Diet'
        ELSE 'Other'
END;

ALTER TABLE food_coded_staging
DROP COLUMN diet_current;

-- Cleaning eating_changes data by adding cleaned column, inserting cleaned data to new column, and deleting uncleaned column
ALTER TABLE food_coded_staging ADD COLUMN eating_changes_cleaned VARCHAR(50) AFTER eating_changes_coded;

UPDATE food_coded_staging
SET eating_changes_cleaned =
	CASE 
		WHEN eating_changes_coded = 1 THEN 'Worse'
        WHEN eating_changes_coded = 2 THEN 'Better'
        WHEN eating_changes_coded = 3 THEN 'None'
        ELSE 'Other'
END;

ALTER TABLE food_coded_staging
DROP COLUMN eating_changes;

-- Cleaning fav_cuisine data by adding cleaned column, inserting cleaned data to new column, and deleting uncleaned column
ALTER TABLE food_coded_staging ADD COLUMN fav_cuisine_cleaned VARCHAR(50)AFTER fav_cuisine_coded;

UPDATE food_coded_staging
SET fav_cuisine_cleaned =
	CASE
		WHEN fav_cuisine_coded = '1' THEN 'Italian'
        WHEN fav_cuisine_coded = '2' THEN 'Mexican'
        WHEN fav_cuisine_coded = '3' THEN 'Middle Eastern'
        WHEN fav_cuisine_coded = '4' THEN 'Asain'
        WHEN fav_cuisine_coded = '5' THEN 'American'
        WHEN fav_cuisine_coded = '6' THEN 'African'
        WHEN fav_cuisine_coded = '7' THEN 'Jamaican'
        WHEN fav_cuisine_coded = '8' THEN 'Indian'
        WHEN fav_cuisine_coded = '0' THEN 'None'
END;

ALTER TABLE food_coded_staging
DROP COLUMN fav_cuisine;

-- Cleaning ideal_diet data by adding cleaned column, inserting cleaned data to new column, and deleting uncleaned column
ALTER TABLE food_coded_staging ADD COLUMN ideal_diet_cleaned VARCHAR(50) AFTER ideal_diet_coded;

UPDATE food_coded_staging
SET ideal_diet_cleaned = 
CASE
	WHEN ideal_diet_coded = '1' THEN 'Controlled Eating'
    WHEN ideal_diet_coded = '2' THEN 'Healthier'
    WHEN ideal_diet_coded = '3' THEN 'More Energy'
    WHEN ideal_diet_coded = '4' THEN 'Less processed foods'
    WHEN ideal_diet_coded = '5' THEN 'More organic foods'
    WHEN ideal_diet_coded = '6' THEN 'No Change' 
    WHEN ideal_diet_coded = '7' THEN 'More protein'
    WHEN ideal_diet_coded = '8' THEN 'Healthier'
END;

ALTER TABLE food_coded_staging
DROP COLUMN ideal_diet_cleaned;


-- Clean does_sports into yes and no values
ALTER TABLE food_coded_staging ADD COLUMN does_sports VARCHAR(50) AFTER sports;

UPDATE food_coded_staging
SET does_sports = 
	CASE
		WHEN sports = '1' THEN 'Yes'
        WHEN sports = '2' THEN 'No'
END;

-- Normalise and clean type_sports data
ALTER TABLE your_table ADD COLUMN sport_cleaned VARCHAR(255);

UPDATE food_coded_staging
SET type_sports = 
  CASE
    WHEN LOWER(TRIM(type_sports)) IN ('none', 'nan', 'none.', 'none right now', 'none organized', '') THEN 'No sport'
    ELSE type_sports
  END;
  
-- Trim extra spaces in type_sport column
UPDATE food_coded_staging
SET type_sports = TRIM(type_sports);

-- Clean and standardize values in the weight column so it only contains numeric values
UPDATE food_coded_staging
SET weight =
  CASE
    WHEN weight LIKE '%answering this%' THEN NULL
    WHEN weight LIKE '%lbs' THEN REGEXP_SUBSTR(weight, '[0-9]+')
    WHEN weight LIKE 'Not sure%' THEN REGEXP_SUBSTR(weight, '[0-9]+')
    WHEN weight REGEXP '^[0-9]+$' THEN weight
    WHEN weight = 'nan' THEN NULL
     WHEN weight = 'n/a' THEN NULL
    ELSE weight
  END;

-- Convert NULL weights back to string 'n/a'
UPDATE food_coded_staging
SET weight = 'n/a'
WHERE weight IS NULL;

-- Create a new table with rows that have valid weight entries
CREATE TABLE food_coded_with_weight AS
SELECT *
FROM food_coded_staging
WHERE weight IS NOT NULL;

-- Create a new table with columns that will be used for visualization
CREATE TABLE food_coded_viz AS 
SELECT row_id, GPA, Gender, comfort_food_reasons_coded, comfort_food_reasons_cleaned, diet_current_coded, 
diet_current_cleaned,eating_changes_coded,eating_changes_cleaned,fav_cuisine_coded,fav_cuisine_cleaned,
ideal_diet_coded,ideal_diet_cleaned,sports,does_sports,weight
FROM food_coded_staging;



