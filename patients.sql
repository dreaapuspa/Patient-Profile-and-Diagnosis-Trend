select *
from patient_visits ;

update patient_visits
set date_of_birth = str_to_date(date_of_birth, '%Y-%m-%d') ;


-- 1. What does the clinic’s patient population look like by Age?
-- 2. What are the top diagnoses overall?
-- 3. How many visits does the average patient have, and who are the high utilizers?
-- 4. Which CPT codes (procedures) are performed most often?

-- 1. What does the clinic’s patient population look like by Age?
SELECT 
CASE 
	WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%Y-%m-%d'), '2025-11-26') < 18 THEN '0-17'
	WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%Y-%m-%d'), '2025-11-26') BETWEEN 18 AND 39 THEN '18-39'
	WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%Y-%m-%d'), '2025-11-26') BETWEEN 40 AND 64 THEN '40-64'
	ELSE '65+'
END AS age_band,
     COUNT(DISTINCT patient_id) AS total_patients
FROM patient_visits
GROUP BY age_band;


-- 2. What are the top diagnoses overall?

select * 
from patient_visits ;

-- top 10 icd code
select icd_code, 
count(*) as total_cases
from patient_visits
group by icd_code
order by total_cases desc
limit 10 ;


-- breakdown by age band
SELECT 
    icd_code,
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%Y-%m-%d'), CURDATE()) BETWEEN 0 AND 17 THEN '0-17'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%Y-%m-%d'), CURDATE()) BETWEEN 18 AND 39 THEN '18-39'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%Y-%m-%d'), CURDATE()) BETWEEN 40 AND 64 THEN '40-64'
        ELSE '65+'
    END AS age_band,
    COUNT(*) AS total_cases
FROM patient_visits
GROUP BY icd_code, age_band
ORDER BY total_cases DESC;


-- breakdown by patient sex
select icd_code, 
patient_sex,
count(icd_code) as total_cases
from patient_visits
group by icd_code, patient_sex
order by total_cases desc ;


-- overall age band, patient sex, and total case
with base_query as (
select patient_id,
icd_code,
patient_sex,
timestampdiff(year, str_to_date(date_of_birth, '%Y-%m-%d'),curdate()) as patient_age
from patient_visits ),
age_range as(
select *, 
case
	when patient_age <18 then '0-17'
    when patient_age between 18 and 39 then '18-39'
    when patient_age between 40 and 64 then '40-64'
    else '65+'
end as age_band
from base_query),
top_10_icd as (
select icd_code, 
count(ar.icd_code) as total_case
from age_range ar
group by icd_code
order by total_case desc
limit 10 )
select ar.age_band,
ar.patient_sex,
count(ar.icd_code) total_case
from age_range ar
join top_10_icd as ti on ar.icd_code = ti.icd_code
group by ar.age_band, ar.patient_sex
order by total_case desc ;

-- 3. How many visits does the average patient have, and who are the high utilizers?
select *
from patient_visits ;

-- total visits
SELECT 
    patient_id,
    COUNT(*) AS total_visits
FROM patient_visits
GROUP BY patient_id;

-- average visit per person
select round(avg(total_visits),2) as avg_visits
from (SELECT 
    patient_id,
    COUNT(*) AS total_visits
FROM patient_visits
GROUP BY patient_id) total ;

-- high utilizers (more than 4 visist)
select patient_id, count(patient_id) total_visits
from patient_visits
group by patient_id
having count(*) >= 4
order by total_visits desc ;

-- group by total_visits (high utilizers /mote than 4 visits)
select total_visits,
count(*) as total_patient
from (
		select patient_id, count(*) as total_visits
		from patient_visits
		group by patient_id ) tv
group by total_visits
order by total_visits desc ;


-- 4. Which CPT codes (procedures) are performed most often?

select *
from patient_visits ;

select cpt_code, 
count(*) as frequency
from patient_visits
group by cpt_code 
order by frequency desc
;




