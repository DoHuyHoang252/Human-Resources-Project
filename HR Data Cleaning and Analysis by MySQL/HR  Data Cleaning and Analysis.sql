USE hrproject;

SELECT * FROM hr;

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id varchar(20) NULL;

DESCRIBE hr;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE 
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate Date;

UPDATE hr
SET hire_date = CASE 
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date Date;

UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate = '';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

select count(*) from hr where age < 18;

-- What is the gender breakdown of employees in the company?
select gender, count(*) as count
from hr
where age >= 18 and termdate =''
group by gender;

-- What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as count
from hr
where age >= 18 and termdate =''
group by race
order by count desc;

-- What is the age distribution of employees in the company
select min(age) as youngest, max(age) as oldest
from hr
where age >= 18 and termdate ='';

select
	case
		when age >=18 and age <=24 then'18-24'
		when age >=25 and age <=34 then'25-34'
		when age >=35 and age <=44 then'35-44'
		when age >=45 and age <=54 then'45-54'
		when age >=55 and age <=64 then'55-64'
        else '65+'
	end as age_group, count(*) as count
from hr
where age >= 18 and termdate =''
group by age_group
order by age_group;

select
	case
		when age >=18 and age <=24 then'18-24'
		when age >=25 and age <=34 then'25-34'
		when age >=35 and age <=44 then'35-44'
		when age >=45 and age <=54 then'45-54'
		when age >=55 and age <=64 then'55-64'
        else '65+'
	end as age_group, gender, count(*) as count
from hr
where age >= 18 and termdate =''
group by age_group, gender
order by age_group, gender;	

-- How many employees work at headquarters versus remote locations?
select location, count(*) as count
from hr
where age >= 18 and termdate =''
group by location;

-- What is the average length of employment for employees who have been terminated?
select 
	round(avg(datediff(termdate, hire_date))/365,2) as avg_length_employment
from hr
where termdate <= curdate() and termdate <> '' and age >=18;

-- How does the gender distribution vary across departments and job titles?
select department, jobtitle, gender, count(*) as count
from hr
where age >= 18 and termdate =''
group by department, gender, jobtitle
order by department;

-- What is the distribution of job titles across the company?
select jobtitle, count(*) as count
from hr 
where age >= 18 and termdate =''
group by jobtitle
order by jobtitle desc;

-- Which department has the highest turnover rate?
select department,
	total_count,
    terminated_count,
    terminated_count/total_count as termination_rate
from (
	select department,
    count(*) as total_count,
    sum(case when termdate <> '' and termdate <= curdate() then 1 else 0 end) as terminated_count
    from hr
    where age >=18 
    group by department
    ) as subquery 
order by termination_rate desc;

-- What is the distribution of employees across locations by city and state?
select location_state, count(*) as count
from hr
where age >= 18 and termdate =''
group by location_state
order by count desc;

-- How has the company's employee count changed over time based on hire and term date?
select
	year,
    hires,
    terminations,
	hires-terminations as net_change,
    round((hires-terminations)/hires * 100,2) as net_change_percent
from (
	select year(hire_date) as year,
    count(*) as hires,
    sum(case when termdate <> '' and termdate <= curdate() then 1 else 0 end) as terminations
    from hr
    where age >= 18
    group by year(hire_date)
    ) as subquery
order by year asc;

-- What is the tenure distribution for each department?
select department, round(avg(datediff(termdate, hire_date)/365),2) as avg_tenure
from hr
where age >= 18 and termdate <= curdate() and termdate <> ''
group by department;

