-- View the entire cleaned dataset including weight
SELECT *
FROM food_coded_with_weight;

-- Count how many students identified as each Gender
SELECT COUNT(Gender) AS count_gender, Gender 
FROM food_coded_with_weight
GROUP BY gender;

-- Show GPAs rounded to the 2nd decimal palce
SELECT ROUND(GPA, 2) AS rounded_gpa, GPA 
FROM food_coded_with_weight;

-- Find the average GPA of both males and females
SELECT ROUND(AVG(GPA), 2) AS rounded_gpa, Gender 
FROM food_coded_with_weight
GROUP BY gender;

-- Categorize students into performance groups based on GPA
SELECT row_id, ROUND(GPA, 1) AS rounded_GPA, 
CASE 
	WHEN GPA > 3.5 THEN 'Excellent'
    WHEN GPA > 3 THEN 'Good'
    WHEN GPA > 2.5 THEN 'Okay'
    ELSE 'Needs improvement'
END AS performance
FROM food_coded_with_weight;

-- Count how many students selected each comfort food reason and show the average GPA for each group
SELECT comfort_food_reasons_cleaned, COUNT(comfort_food_reasons_cleaned) AS num_of_comfort_food, ROUND(AVG(GPA), 1) AS avg_gpa 
FROM food_coded_with_weight
WHERE comfort_food_reasons_cleaned IS NOT NULL
GROUP BY comfort_food_reasons_cleaned
ORDER BY avg_gpa DESC;

-- Returns the average weight of students based on there comfort_food_reasons
SELECT comfort_food_reasons_cleaned, ROUND(AVG(weight), 1) AS avg_weight 
FROM food_coded_with_weight
GROUP BY comfort_food_reasons_cleaned
ORDER BY avg_weight DESC;

-- Count the number of students for each current_diet category
SELECT COUNT(row_id) AS num_of_students, diet_current_cleaned 
FROM food_coded_with_weight
GROUP BY diet_current_cleaned;


-- Show students who consider their diet 'Somewhat Healthy' but reported their eating habits have worsened, including GPA and goals
SELECT row_id, GPA, diet_current_cleaned, eating_changes_cleaned, ideal_diet_cleaned 
FROM food_coded_with_weight
WHERE diet_current_cleaned = 'Somewhat Healthy' AND eating_changes_cleaned = 'Worse'
ORDER BY GPA ASC;


-- Find the average weight and average GPA of students that do and do not play sports
SELECT does_sports, ROUND(AVG(weight), 1) AS avg_weight_rounded, ROUND(AVG(GPA), 2) AS avg_gpa_rounded 
FROM food_coded_with_weight
GROUP BY does_sports;

-- Find students who mentioned vegetables in their healthy meals and view their GPA, gender, and weight
SELECT GPA, gender, diet_current_cleaned, healthy_meal, does_sports, weight 
FROM food_coded_with_weight
WHERE healthy_meal LIKE '%veg%'
ORDER BY GPA;

-- Identify the comfort food reason associated with the highest average GPA using a subquery
SELECT row_id, GPA, comfort_food_reasons_cleaned 
FROM food_coded_with_weight
WHERE comfort_food_reasons_cleaned IN (
	SELECT comfort_food_reasons_cleaned
    FROM food_coded_with_weight
    GROUP BY comfort_food_reasons_cleaned
	ORDER BY AVG(GPA) DESC);

-- Groups gender by how many male and felmales there are, if they do sports, and the percentage of them that do sports
SELECT Gender,	
       COUNT(*) AS total,
       SUM(CASE WHEN does_sports = 'Yes' THEN 1 ELSE 0 END) AS sports_count,
       ROUND(100.0 * SUM(CASE WHEN does_sports = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS percent_play_sports
FROM food_coded_with_weight
GROUP BY Gender;


-- Show how average GPA changes depending on ideal diet goal and eating habit changes
SELECT ideal_diet_cleaned, eating_changes_cleaned, ROUND(AVG(GPA), 2) AS avg_gpa 
FROM food_coded_with_weight
GROUP BY ideal_diet_cleaned, eating_changes_cleaned
ORDER BY avg_gpa DESC;

-- List all students who say their diet is "Healthy" but their eating habits have gotten worse
SELECT *
FROM food_coded_with_weight
WHERE diet_current_cleaned = 'Healthy' AND eating_changes_cleaned = 'Worse';

-- Count how many students fall into each combination of comfort food reason and eating change status
SELECT comfort_food_reasons_cleaned, eating_changes_cleaned, COUNT(*) AS count
FROM food_coded_with_weight
WHERE comfort_food_reasons_cleaned IS NOT NULL
GROUP BY comfort_food_reasons_cleaned, eating_changes_cleaned
ORDER BY count DESC;

-- Count how many students with "Somewhat Unhealthy" diets aim for specific ideal diets (e.g., "Healthier", "Controlled Eating")
SELECT diet_current_cleaned, ideal_diet_cleaned, COUNT(*) AS COUNT
FROM food_coded_with_weight
WHERE diet_current_cleaned IS NOT NULL 
GROUP BY diet_current_cleaned, ideal_diet_cleaned
HAVING diet_current_cleaned = 'Somewhat Unhealthy' AND ideal_diet_cleaned IN ('Healthier', 'Controlled Eating');

-- Show average GPA and weight of students broken down by sport participation and comfort food reason
SELECT does_sports, comfort_food_reasons_cleaned,
       ROUND(AVG(GPA), 2) AS avg_gpa,
       ROUND(AVG(weight), 1) AS avg_weight,
       COUNT(*) AS count
FROM food_coded_with_weight
WHERE comfort_food_reasons_cleaned IS NOT NULL
GROUP BY does_sports, comfort_food_reasons_cleaned
ORDER BY avg_gpa DESC;

-- Categorize students into profiles based on GPA, weight, and diet, then count how many fall into each profile
SELECT 
  student_profile,
  COUNT(*) AS num_students
FROM (
  SELECT 
    CASE 
      WHEN GPA >= 3.5 AND weight < 150 AND diet_current_cleaned LIKE '%Healthy%' THEN 'High GPA, Fit, Healthy'
      WHEN GPA >= 3.0 AND weight < 180 THEN 'Good GPA, Avg Weight'
      WHEN GPA < 3.0 AND weight >= 180 THEN 'Low GPA, Higher Weight'
      ELSE 'Other'
    END AS student_profile
  FROM food_coded_with_weight
) AS profiles
GROUP BY student_profile;


