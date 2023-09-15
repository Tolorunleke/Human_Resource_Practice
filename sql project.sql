create database proj;

use proj;
SELECT * FROM information_schema.triggers;

#change the id column name 
ALTER TABLE hr
CHANGE COLUMN ï»¿id id VARCHAR(20) NULL;

#change the birthdate value from text to date and edit the date sort
UPDATE hr
SET birthdate =  CASE 
WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
ELSE NULL
END;

ALTER TABLE hr
MODIFY birthdate DATE;



#change the data_type and  format of hire_date
UPDATE hr
SET hire_date = CASE
WHEN hire_date LIKE '%/%' THEN  date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
WHEN hire_date LIKE '%-%' THEN  date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
ELSE
 NULL
END;

ALTER TABLE hr
MODIFY hire_date DATE;



#work on termdate like hire and birth dates note termdate has both date and time
UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !='';

ALTER TABLE hr
MODIFY termdate DATE;



#CREATE A NEW TABLE 'AGE' AND GET THE AGE OF EACH EMPLOYEE
ALTER TABLE hr
ADD COLUMN Age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, curdate());



#ANALYSIS QUESTIONS 
#1. WHAT IS THE GENDER BREAK DOWN OF EMPLOYEES IN THE COMPANY
SELECT gender, count(*) 'No_Employees'
FROM hr
WHERE age >= 18
GROUP BY gender;


#2. WHAT IS THE RACE/ETHNICITY BREAKDOWN OF EMPLOYEES IN THE COMPANY
SELECT race, count(*) 'count'
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY count(*) desc;

#3. WHAT IS THE AGE DISTRIBUTION  IN THE COMPANY
SELECT race, location, jobtitle, max(age) 'oldest', min(age) 'youngest', count(*) num_employee
FROM hr
WHERE age >= 18 AND termdate = 0000-00-00
GROUP BY race, location, jobtitle;

# if you named your table with space in between and have difficulty renaming it the normalway use the tilde sign under the esc key
RENAME TABLE `human resource` TO `hr`;


# Group the age to different age_groups
SELECT CASE
WHEN age >= 18 AND age <= 20 THEN '18-20'
WHEN age >= 25 AND age <= 34 THEN '25-34'
WHEN age >= 35 AND age <= 44 THEN '35-44'
WHEN age >= 45 AND age <= 54 THEN '45-54'
WHEN age >= 55 AND age <= 64 THEN '55-64'
ELSE '65+'
END AS age_group, gender, COUNT(*) count
FROM hr
GROUP BY age_group, gender
ORDER BY age_group, gender;

#4. HOW MANY EMPLOYEE WORKS AT HQ VS REMOTE
SELECT location, count(*) Total_Employee
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;


#5. WHAT IS THE AVEREAGE LEN OF EMPLOYEMNT FOR EMPLOYEES WHO HAVE BEEN TERMINATED;
SELECT 
	round(avg(datediff(termdate, hire_date))/365,0) as avg_length_employed
FROM hr
WHERE termdate <= curdate() AND termdate <> 0000-00-00 AND age >= 18;


-- 6. How does the gender distribution vary across departments and job titles;
SELECT department, gender, jobtitle, count(*) 'count'
FROM hr
WHERE termdate = 0000-00-00 AND age >= 18
GROUP BY department, gender
ORDER BY department, gender;

#7. What is the distribution of job titles across the company
SELECT jobtitle, count(*) 
FROM hr
group by jobtitle
order by jobtitle DESC, gender;

#8. Which department has the highest turnover rate
select department, 
total_count,
terminated_count,
total_count/ terminated_count as rate
FROM(
	SELECT 
		department, 
		count(*) AS total_count,
		sum(case when termdate <> 0000-00-00 and termdate <= curdate() then 1 else 0 end) as terminated_count
		from hr 
		where age >=18
		group by department
    ) subquery
order by total_count;


SELECT department, sum(CASE
	WHEN department IS NOT NULL OR department != '' OR department != ' ' THEN 1 
    ELSE 0
    END) count
FROM hr 
where age >= 18
GROUP BY department;

-select department, count(*)
from hr 
where termdate <> 0000-00-00 and termdate <= curdate() and age >= 18
group by department;
-- where you have a query you want to add to the number of column thats to come out as result, that count number of rolls, group by a column, then a case where statment should be used 
-- note when you want to count the number of a where_like statement you can use the CASE function especially when the filer doesnt have a number
-- you can also you the CASE function on ORDER by clause 


-- 9 What is the distribution of employees across locations by city and state
select location_state, location_city, count(*) Total_Employee
FROM hr 
group by location_state, location_city
order by Total_Employee desc;


-- 10. How has the company employee count change over time based on hire and termdate?
WITH timeline AS
(
	SELECT 
	year,
	Hire,
	Terminations,
	hire - terminations AS Net_Change,
	CONCAT(round((hire- terminations)/hire*100,2),' ') AS 'Net_Change%'
	FROM( 
	 SELECT 
		YEAR(hire_date) AS year, 
		count(*) AS Hire,
		sum(CASE WHEN termdate <> 0000-00-00 AND termdate <= curdate()THEN 1 ELSE 0 END) AS Terminations
	 FROM hr
	 WHERE age >= 18
	 GROUP BY year) as subquery
	ORDER BY year asc
    )
    SELECT *
    FROM timeline ;

-- 11. What is the average tenure of each departments?
SELECT department, ROUND(AVG(datediff(termdate, hire_date)/365)) average
FROM hr
WHERE termdate <> 0000-00-00 and age >= 18 and termdate <= curdate()
GROUP BY department;
SELECT *
FROM hr
;