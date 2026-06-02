
SELECT gender, COUNT(*) AS gender_count
FROM patients
GROUP BY gender;

SELECT race, COUNT(*) AS race_count
FROM patients
GROUP BY race;

SELECT city, COUNT(*) AS population_count
FROM patients
GROUP BY city;

SELECT city, COUNT(*) AS population_count
FROM patients
GROUP BY city
ORDER BY population_count DESC
LIMIT 1;

SELECT city, COUNT(*) AS population_count
FROM patients
GROUP BY city
ORDER BY population_count ASC
LIMIT 1;


-- Check if all patient IDs in conditions exist in patients
SELECT c.PATIENT
FROM conditions c
LEFT JOIN patients p ON c.PATIENT = p.Id
WHERE p.Id IS NULL;

-- Check if all encounter IDs in medications exist in encounters
SELECT m.ENCOUNTER
FROM medications m
LEFT JOIN encounters e ON m.ENCOUNTER = e.Id
WHERE e.Id IS NULL;

-- Validate Birthdate Range
SELECT Id, BIRTHDATE 
FROM patients 
WHERE BIRTHDATE < '1905-01-01' OR BIRTHDATE > '2025-01-01';

-- Check for invalid gender values
SELECT DISTINCT GENDER 
FROM patients;

-- Validate Total Claim Cost
SELECT Id AS encounter_id, TOTAL_CLAIM_COST 
FROM encounters 
WHERE TOTAL_CLAIM_COST < 0;

SELECT e.Id AS encounter_id, e.PATIENT AS patient_id, e.ENCOUNTERCLASS, e.TOTAL_CLAIM_COST,
       CASE 
           WHEN e.ENCOUNTERCLASS IN ('ambulatory', 'outpatient', 'wellness') THEN 'low'
           WHEN e.ENCOUNTERCLASS = 'urgentcare' THEN 'medium'
           WHEN e.ENCOUNTERCLASS IN ('emergency') THEN 'high'
           ELSE 'unknown'
       END AS inferred_severity
FROM encounters e;

SELECT m.PATIENT AS patient_id, m.DESCRIPTION AS medication_description, 
       CASE 
           WHEN m.DESCRIPTION LIKE '%Acetaminophen%' OR m.DESCRIPTION LIKE '%Ibuprofen%' OR m.DESCRIPTION LIKE '%Amoxicillin%' 
                OR m.DESCRIPTION LIKE '%sodium fluoride%' THEN 'low'
           WHEN m.DESCRIPTION LIKE '%Diazepam%' OR m.DESCRIPTION LIKE '%Nitrofurantoin%' OR m.DESCRIPTION LIKE '%Penicillin%' 
                OR m.DESCRIPTION LIKE '%lisinopril%' THEN 'medium'
           WHEN m.DESCRIPTION LIKE '%medroxyPROGESTERone%' OR m.DESCRIPTION LIKE '%epinephrine%' OR m.DESCRIPTION LIKE '%insulin%' 
                OR m.DESCRIPTION LIKE '%Hydrochlorothiazide%' OR m.DESCRIPTION LIKE '%amlodipine%' THEN 'high'
           ELSE 'unknown'
       END AS inferred_severity
FROM medications m;


PRAGMA table_info(encounters);
PRAGMA table_info(patients);

--report 1

SELECT p.CITY, 
       strftime('%Y', e.START) AS year, 
       COUNT(*) AS patient_count
FROM encounters e
JOIN patients p ON e.PATIENT = p.Id
WHERE date(e.START) >= date('now', '-5 years')  -- Filter for last 5 years
GROUP BY p.CITY, year
ORDER BY patient_count DESC
LIMIT 10;


--- Updated Rport 1 

--Fever cases for last 5 years
SELECT 
    p.CITY, 
    strftime('%Y', e.START) AS year, 
    COUNT(*) AS patient_count,
    'Fever' AS condition_type
FROM encounter e
JOIN patients p ON e.PATIENT = p.Id
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE c.CODE = '386661006'  -- Fever condition code
  AND date(e.START) >= date('now', '-5 years')  -- Filter for the last 5 years
GROUP BY p.CITY, year  -- Group by city and year
ORDER BY patient_count DESC
LIMIT 10;  -- Limit to the top 10 cities


--Flu cases for last 5 years
SELECT 
    p.CITY, 
    strftime('%Y', e.START) AS year, 
    COUNT(*) AS patient_count,
    'Flu' AS condition_type
FROM encounter e
JOIN patients p ON e.PATIENT = p.Id
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE c.CODE IN ('195662009', '444814009', '10509002', '233604007')  -- Flu-related conditions
  AND date(e.START) >= date('now', '-5 years')  -- Filter for the last 5 years
GROUP BY p.CITY, year  -- Group by city and year
ORDER BY patient_count DESC
LIMIT 10;  -- Limit to the top 10 cities

--report 2 

SELECT CITY, 
       ENCOUNTERCLASS,
       inferred_severity, 
       COUNT(*) AS case_count
FROM (
    SELECT p.CITY, 
           e.ENCOUNTERCLASS, 
           CASE 
               WHEN e.ENCOUNTERCLASS IN ('ambulatory', 'outpatient', 'wellness') THEN 'low'
               WHEN e.ENCOUNTERCLASS = 'urgentcare' THEN 'medium'
               WHEN e.ENCOUNTERCLASS = 'emergency' THEN 'high'
               ELSE 'unknown'
           END AS inferred_severity
    FROM encounter e
    JOIN patients p ON e.PATIENT = p.Id
) severity_cases
WHERE inferred_severity IN ('low', 'medium', 'high')  -- Filter for low, medium, and high severity
GROUP BY CITY, ENCOUNTERCLASS, inferred_severity  -- Group by city, encounter class, and inferred severity
ORDER BY case_count DESC  -- Order by the total count of cases
LIMIT 10;  -- Limit the result to top 10 cities

--total no .of beds avaliable
SELECT 
    SUM(CASE 
            WHEN CAST(UTILIZATION AS INTEGER) > 200 THEN 0  -- Handling cases where utilization exceeds total capacity
            ELSE 200 - CAST(UTILIZATION AS INTEGER) 
        END) AS TOTAL_AVAILABLE_BEDS
FROM 
    organization
WHERE 
    STATE = 'CA'  -- Filter for California
    AND CAST(UTILIZATION AS INTEGER) <= 200;  -- Excluding cases where utilization exceeds total capacity


-- Beds available in each city of California, for top 5 cities with highest beds count
SELECT 
    CITY,
    SUM(CASE 
            WHEN CAST(UTILIZATION AS INTEGER) > 200 THEN 0  -- Handling cases where utilization exceeds total capacity
            ELSE 200 - CAST(UTILIZATION AS INTEGER) 
        END) AS TOTAL_AVAILABLE_BEDS
FROM 
    organization
WHERE 
    STATE = 'CA'  -- Filter for California
    AND CAST(UTILIZATION AS INTEGER) <= 200  -- Exclude cases where utilization exceeds total capacity
GROUP BY 
    CITY  -- Group by city to get total available beds for each city
ORDER BY 
    TOTAL_AVAILABLE_BEDS DESC  -- Sort by the total available beds in descending order
LIMIT 5;  -- Limit to the top 5 cities with the highest available beds


-- Fever cases for last 5 years
SELECT 
    p.CITY, 
    strftime('%Y', e.START) AS year, 
    COUNT(*) AS patient_count,
    'Fever' AS condition_type,
    e.ENCOUNTERCLASS,  -- Encounter class
    SUM(CASE 
            WHEN CAST(e.TOTAL_CLAIM_COST AS INTEGER) > 200 THEN 0  -- Handling cases where utilization exceeds total capacity
            ELSE 200 - CAST(e.TOTAL_CLAIM_COST AS INTEGER)  -- Assuming this is where cost maps to bed usage
        END) AS beds_occupied
FROM encounter e
JOIN patients p ON e.PATIENT = p.Id
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE c.CODE = '386661006'  -- Fever condition code
  AND date(e.START) >= date('now', '-5 years')  -- Filter for the last 5 years
GROUP BY p.CITY, year, e.ENCOUNTERCLASS  -- Group by city, year, and encounter class
ORDER BY patient_count DESC
LIMIT 5;  -- Limit to the top 5 cities


-- Flu cases for last 5 years
SELECT 
    p.CITY, 
    strftime('%Y', e.START) AS year, 
    COUNT(*) AS patient_count,
    'Flu' AS condition_type,
    e.ENCOUNTERCLASS,  -- Encounter class
    SUM(CASE 
            WHEN CAST(e.TOTAL_CLAIM_COST AS INTEGER) > 200 THEN 0  -- Handling cases where utilization exceeds total capacity
            ELSE 200 - CAST(e.TOTAL_CLAIM_COST AS INTEGER)  -- Assuming this is where cost maps to bed usage
        END) AS beds_occupied
FROM encounter e
JOIN patients p ON e.PATIENT = p.Id
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE c.CODE IN ('195662009', '444814009', '10509002', '233604007')  -- Flu-related conditions
  AND date(e.START) >= date('now', '-5 years')  -- Filter for the last 5 years
GROUP BY p.CITY, year, e.ENCOUNTERCLASS  -- Group by city, year, and encounter class
ORDER BY patient_count DESC
LIMIT 5;  -- Limit to the top 5 cities


-- Top 5 years where encounter classes occupied the most number of beds in the last 5 years
SELECT 
    strftime('%Y', e.START) AS year,  -- Extracting the year from encounter start date
    e.ENCOUNTERCLASS,  -- Encounter class type (e.g., Inpatient, Outpatient)
    SUM(CASE 
            WHEN CAST(e.TOTAL_CLAIM_COST AS INTEGER) > 200 THEN 0  -- Adjust bed occupancy calculation if needed
            ELSE 200 - CAST(e.TOTAL_CLAIM_COST AS INTEGER)  -- Estimation of beds occupied based on claim cost
        END) AS beds_occupied
FROM encounter e
JOIN patients p ON e.PATIENT = p.Id
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE (c.CODE IN ('386661006', '195662009', '444814009', '10509002', '233604007'))  -- Include codes for seasonal illnesses
  AND date(e.START) >= date('now', '-5 years')  -- Filter for the last 5 years
GROUP BY year, e.ENCOUNTERCLASS  -- Group by year and encounter class type
ORDER BY beds_occupied DESC  -- Sort by beds occupied in descending order
LIMIT 5;  -- Limit to the top 5 years with most beds occupied

