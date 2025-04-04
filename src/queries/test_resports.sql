-- insert a driver with the same cont start and end date
insert into drivers 
(passport, email, fullname, birthdate, phone, address, cont_start, cont_end)
VALUES ('000000000000', 'test1@email.com', 'Test1', 
        TO_DATE('15-05-2025', 'DD-MM-YYYY'), 600111222, 
        'Calle Mayor 10, Madrid', 
        TO_DATE('15-05-2025', 'DD-MM-YYYY'), NULL);
