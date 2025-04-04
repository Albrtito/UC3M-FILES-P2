-- Get the stops per active year for each driver
driver_stops_average AS (
    SELECT
        ds.passport,
        db.fullname,
        db.active_years,
        ds.total_stops / db.active_years AS stops_per_active_year
    FROM 
        driver_stops ds
    LEFT JOIN
        driver_base db ON ds.passport = db.passport
