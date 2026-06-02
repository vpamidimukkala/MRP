
SELECT COUNT(*) AS total_patient_cases
FROM encounters e
JOIN patients p ON e.PATIENT = p.Id
WHERE date(e.START) >= date('now', '-5 years');  -- Filter for last 5 years



SELECT COUNT(*) AS total_fever_cases
FROM encounters e
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE c.CODE = '386661006';

SELECT strftime('%Y', e.START) AS year, COUNT(*) AS total_fever_cases
FROM encounters e
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE c.CODE = '386661006'
GROUP BY year
ORDER BY year DESC;

SELECT DISTINCT c.CODE
FROM conditions c
ORDER BY c.CODE;

SELECT DISTINCT c.DESCRIPTION, c.CODE
FROM conditions c
WHERE c.DESCRIPTION LIKE '%respiratory%' OR c.DESCRIPTION LIKE '%viral%' OR c.DESCRIPTION LIKE '%infection%';

SELECT DISTINCT c.CODE, c.DESCRIPTION
FROM conditions c
WHERE c.DESCRIPTION LIKE '%respiratory%' 
   OR c.DESCRIPTION LIKE '%viral%'
   OR c.DESCRIPTION LIKE '%infection%'
ORDER BY c.CODE;

SELECT DISTINCT c.CODE, c.DESCRIPTION
FROM conditions c
WHERE c.DESCRIPTION LIKE '%pneumonia%' 
   OR c.DESCRIPTION LIKE '%bronchitis%'
ORDER BY c.CODE;

SELECT strftime('%Y', e.START) AS year, COUNT(*) AS total_cases
FROM encounters e
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE c.CODE IN ('195662009', '444814009', '10509002', '233604007')  -- Acute viral pharyngitis, Viral sinusitis, Acute bronchitis, Pneumonia
  AND date(e.START) >= date('now', '-6 months')  -- Last 6 months
GROUP BY year
ORDER BY year DESC;


SELECT 
    p.CITY, 
    strftime('%Y', e.START) AS year, 
    COUNT(*) AS patient_count,
    CASE 
        WHEN c.CODE = '386661006' THEN 'Fever'  -- Fever condition code
        WHEN c.CODE IN ('195662009', '444814009', '10509002', '233604007') THEN 'Flu'  -- Flu-related conditions
        ELSE 'Other'  -- Other cases (if any)
    END AS condition_type
FROM encounters e
JOIN patients p ON e.PATIENT = p.Id
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE c.CODE IN ('386661006', '195662009', '444814009', '10509002', '233604007')  -- Fever and Flu-related conditions
  AND date(e.START) >= date('now', '-5 years')  -- Filter for the last 5 years
GROUP BY p.CITY, year, condition_type  -- Group by city, year, and condition type
ORDER BY patient_count DESC
LIMIT 10;  -- Limit to the top 10 cities



SELECT 
    COUNT(*) AS total_all_cases
FROM encounter e
WHERE date(e.START) >= date('now', '-5 years');  -- Filter for the last 5 years

SELECT 
    COUNT(*) AS total_fever_cases
FROM encounters e
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE c.CODE = '386661006'  -- Fever condition code
  AND date(e.START) >= date('now', '-5 years');  -- Filter for the last 5 years

SELECT 
    COUNT(*) AS total_flu_cases
FROM encounters e
JOIN conditions c ON e.Id = c.ENCOUNTER
WHERE c.CODE IN ('195662009', '444814009', '10509002', '233604007')  -- Flu-related conditions
  AND date(e.START) >= date('now', '-5 years');  -- Filter for the last 5 years


PRAGMA table_info(organization);
PRAGMA table_info(encounter);
PRAGMA table_info(conditions);
PRAGMA table_info(patients);

SELECT name FROM sqlite_master WHERE type='table';



SELECT 
    NAME,
    CITY,
    200 - CAST(UTILIZATION AS INTEGER) AS AVAILABLE_BEDS  -- Assuming 200 total beds
FROM 
    organization;


SELECT 
    p.CITY,
    COUNT(*) AS FLU_OCCUPIED_BEDS
FROM 
    encounter e
JOIN 
    patients p ON e.PATIENT = p.Id
JOIN 
    conditions c ON e.Id = c.ENCOUNTER
WHERE 
    c.CODE IN ('195662009', '444814009', '10509002')  -- Flu-related conditions
    AND p.STATE = 'CA'  -- Filter for California
GROUP BY 
    p.CITY
ORDER BY 
    FLU_OCCUPIED_BEDS DESC;

-- Check if the encounter table has data
SELECT * FROM encounter LIMIT 10;

-- Check if the conditions table has flu-related conditions
SELECT * FROM conditions WHERE CODE IN ('195662009', '444814009', '10509002', '233604007') LIMIT 10;


PRAGMA table_info(conditions);

SELECT DISTINCT DESCRIPTION 
FROM conditions;

SELECT *
FROM conditions
WHERE DESCRIPTION LIKE '%flu%'
   OR DESCRIPTION LIKE '%fever%'
   OR DESCRIPTION LIKE '%pneumonia%'
   OR DESCRIPTION LIKE '%asthma%'
   OR DESCRIPTION LIKE '%bronchitis%'
   OR DESCRIPTION LIKE '%respiratory%'
   OR DESCRIPTION LIKE '%heat%'
   OR DESCRIPTION LIKE '%injury%'
   OR DESCRIPTION LIKE '%trauma%'
   OR DESCRIPTION LIKE '%gunshot%'
   OR DESCRIPTION LIKE '%wound%'
   OR DESCRIPTION LIKE '%accident%'
   OR DESCRIPTION LIKE '%burn%'
   OR DESCRIPTION LIKE '%fracture%'
   OR DESCRIPTION LIKE '%laceration%'
   OR DESCRIPTION LIKE '%concussion%'
   OR DESCRIPTION LIKE '%emergency%'
   OR DESCRIPTION LIKE '%shock%';
