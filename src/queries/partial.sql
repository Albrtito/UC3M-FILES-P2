
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
);
