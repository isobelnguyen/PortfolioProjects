select*
from teen_phone_addiction_dataset;

-- Analyzing phone addiction per age group utilizing daily usage hours

SELECT age, AVG(Daily_usage_hours) AS avg_addiction
FROM teen_phone_addiction_dataset
GROUP BY age
ORDER BY avg_addiction DESC;


-- Correlations between mental health and phone addiction
SELECT 
  gender,
  AVG(Anxiety_Level) AS avg_anxiety,
  AVG(Depression_Level) AS avg_depression,
  AVG(Self_Esteem) AS avg_self_esteem
FROM teen_phone_addiction_dataset
WHERE gender IN ('Female', 'Male', 'Other')
GROUP BY gender;



-- Exploring the data - male vs female 
SELECT
  gender,
  ROUND(AVG(Addiction_Level), 2) AS avg_addiction_level
FROM teen_phone_addiction_dataset
GROUP BY gender;

-- Home demographics
Select
parental_control,
count(*) as total,
round(100.0 * count(*)/(Select count(*) from teen_phone_addiction_dataset),2) as percentage
from teen_phone_addiction_dataset
Group by Parental_Control;



-- Impact on social interactions- Does higher phone usage corrolate with lower social interactions
SELECT 
  age,
  ROUND(AVG(Daily_usage_hours), 2) AS avg_usage,
  ROUND(AVG(Social_interactions), 2) AS avg_social_score
FROM teen_phone_addiction_dataset
GROUP BY age
ORDER BY avg_usage DESC;

SELECT 
  CASE 
    WHEN Daily_usage_hours < 3 THEN 'Low Usage'
    WHEN Daily_usage_hours BETWEEN 3 AND 6 THEN 'Medium Usage'
    ELSE 'High Usage'
  END AS usage_group,
  ROUND(AVG(Social_interactions), 2) AS avg_social_score
FROM teen_phone_addiction_dataset
GROUP BY usage_group
ORDER BY usage_group;





  




