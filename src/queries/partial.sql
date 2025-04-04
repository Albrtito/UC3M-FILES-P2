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
;
