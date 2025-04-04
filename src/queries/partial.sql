-- For each driver, provide:
--  Full name
--  Age
--  Seniority contracted (whole years)
--  Active years (years on road)
--  Number of stops per active year
--  Number of loans per active year
--  Percentage of unreturned loans


-- Get the stops per active year for each driver
WITH 
-- Get the info that we need from the drivers table into an smaller table 
-- passport (so that we can still identify), Full name, birthdate age(needs to be computed), seniority(needs to be computed), active years(needs to be computed), we also maintain the contract start and end dates
driver_base AS (
    SELECT 
        d.passport,
        d.fullname,
        d.birthdate,
        d.cont_start,
        d.cont_end,
        -- Calculate age in years
        TRUNC(MONTHS_BETWEEN(SYSDATE, d.birthdate) / 12) AS age,
        -- Calculate seniority (contract length) in years. 
        -- Use NVL to handle NULL end dates, if no end date, then use SYSDATE
        TRUNC(MONTHS_BETWEEN(NVL(d.cont_end, SYSDATE), d.cont_start) / 12) AS seniority_years,
        -- Dont get what's the difference between this and the one above, so add it here as the same thing
        TRUNC(MONTHS_BETWEEN(NVL(d.cont_end, SYSDATE), d.cont_start) / 12) AS active_years
    FROM 
        drivers d
),
driver_stops AS (
  SELECT 
        d.passport,
        COUNT(DISTINCT s.town || s.province) AS total_stops
    FROM 
        drivers d
    LEFT JOIN 
        assign_drv ad ON d.passport = ad.passport
    LEFT JOIN 
        services s ON ad.passport = s.passport AND ad.taskdate = s.taskdate
    GROUP BY 
        d.passport
),
-- Get the stops per active year for each driver
driver_stops_average AS(
SELECT
    ds.passport,
    db.fullname,
    db.active_years,
    ds.total_stops / db.active_years AS stops_per_active_year
FROM 
    driver_stops ds
LEFT JOIN
    driver_base db ON ds.passport = db.passport
)
-- Count loans and unreturned loans for each driver
SELECT
    d.passport,
    COUNT(l.signature) AS total_loans,
    COUNT(CASE WHEN l.return IS NULL THEN 1 END) AS unreturned_loans
FROM 
    drivers d
LEFT JOIN 
    assign_drv ad ON d.passport = ad.passport
LEFT JOIN 
    services s ON ad.passport = s.passport AND ad.taskdate = s.taskdate
LEFT JOIN 
    loans l ON s.town = l.town AND s.province = l.province AND s.taskdate = l.stopdate
GROUP BY 
    d.passport
;
