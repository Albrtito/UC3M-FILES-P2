-- 1. Primero, creamos municipios
INSERT INTO municipalities(TOWN, PROVINCE, POPULATION)
VALUES ('MADRID', 'MADRID', 50000);

INSERT INTO municipalities(TOWN, PROVINCE, POPULATION)
VALUES ('BARCELONA', 'BARCELONA', 45000);

INSERT INTO municipalities(TOWN, PROVINCE, POPULATION)
VALUES ('VALENCIA', 'VALENCIA', 35000);

-- 2. Creamos rutas
INSERT INTO routes(ROUTE_ID)
VALUES ('R001');

-- 3. Creamos conductores
INSERT INTO drivers(PASSPORT, EMAIL, FULLNAME, BIRTHDATE, PHONE, ADDRESS, CONT_START, CONT_END)
VALUES ('ABC123456789', 'conductor1@email.com', 'Juan Pérez García', 
        TO_DATE('15-05-1980', 'DD-MM-YYYY'), 600111222, 
        'Calle Mayor 10, Madrid', 
        TO_DATE('01-01-2020', 'DD-MM-YYYY'), NULL);

-- 4. Creamos bibuses
INSERT INTO bibuses(PLATE, LAST_ITV, NEXT_ITV)
VALUES ('1234ABC', TO_DATE('01-01-2023', 'DD-MM-YYYY'), 
        TO_DATE('01-01-2024', 'DD-MM-YYYY'));

-- 5. Creamos asignaciones de conductores
INSERT INTO assign_drv(PASSPORT, TASKDATE, ROUTE_ID)
VALUES ('ABC123456789', TO_DATE('10-02-2023', 'DD-MM-YYYY'), 'R001');

-- 6. Creamos asignaciones de bibuses
INSERT INTO assign_bus(PLATE, TASKDATE, ROUTE_ID)
VALUES ('1234ABC', TO_DATE('10-02-2023', 'DD-MM-YYYY'), 'R001');

-- 7. Creamos paradas
INSERT INTO stops(TOWN, PROVINCE, ADDRESS, ROUTE_ID, STOPTIME)
VALUES ('MADRID', 'MADRID', 'Plaza Mayor 1', 'R001', 1000);

INSERT INTO stops(TOWN, PROVINCE, ADDRESS, ROUTE_ID, STOPTIME)
VALUES ('BARCELONA', 'BARCELONA', 'Rambla 25', 'R001', 1200);

-- 8. Creamos servicios
INSERT INTO services(TOWN, PROVINCE, BUS, TASKDATE, PASSPORT)
VALUES ('MADRID', 'MADRID', '1234ABC', TO_DATE('10-02-2023', 'DD-MM-YYYY'), 'ABC123456789');

-- 9. Creamos usuarios (uno tipo P y otro tipo L)
INSERT INTO users(USER_ID, ID_CARD, NAME, SURNAME1, SURNAME2, BIRTHDATE, TOWN, PROVINCE, ADDRESS, EMAIL, PHONE, TYPE)
VALUES ('USR001', '12345678A', 'Ana', 'López', 'Martínez', 
        TO_DATE('20-03-1990', 'DD-MM-YYYY'), 'MADRID', 'MADRID', 
        'Calle Gran Vía 25', 'ana.lopez@email.com', 600222333, 'P');

INSERT INTO users(USER_ID, ID_CARD, NAME, SURNAME1, SURNAME2, BIRTHDATE, TOWN, PROVINCE, ADDRESS, EMAIL, PHONE, TYPE)
VALUES ('USR002', '87654321B', 'Carlos', 'García', 'Rodríguez', 
        TO_DATE('15-07-1985', 'DD-MM-YYYY'), 'BARCELONA', 'BARCELONA', 
        'Paseo de Gracia 40', 'carlos.garcia@email.com', 600333444, 'L');

-- 10. Creamos libros
INSERT INTO books(TITLE, AUTHOR, COUNTRY, LANGUAGE, PUB_DATE, TOPIC, CONTENT)
VALUES ('Don Quijote de la Mancha', 'Miguel de Cervantes', 'España', 'Español', 
        1605, 'Novela de caballería', 'En un lugar de la Mancha, de cuyo nombre no quiero acordarme...');

-- 11. Creamos ediciones
INSERT INTO editions(ISBN, TITLE, AUTHOR, LANGUAGE, PUBLISHER, NATIONAL_LIB_ID)
VALUES ('9788424105662', 'Don Quijote de la Mancha', 'Miguel de Cervantes', 'Español', 
        'Editorial Cátedra', 'BNE123456');

-- 12. Creamos copias
INSERT INTO copies(SIGNATURE, ISBN, CONDITION)
VALUES ('CP001', '9788424105662', 'G');

INSERT INTO copies(SIGNATURE, ISBN, CONDITION)
VALUES ('CP002', '9788424105662', 'G');

-- 13. Creamos préstamos (uno para usuario P y otro para usuario L)
INSERT INTO loans(SIGNATURE, USER_ID, STOPDATE, TOWN, PROVINCE, TYPE, TIME, RETURN)
VALUES ('CP001', 'USR001', TO_DATE('10-02-2023', 'DD-MM-YYYY'), 
        'MADRID', 'MADRID', 'P', 30, TO_DATE('10-03-2023', 'DD-MM-YYYY'));

INSERT INTO loans(SIGNATURE, USER_ID, STOPDATE, TOWN, PROVINCE, TYPE, TIME, RETURN)
VALUES ('CP002', 'USR002', TO_DATE('10-02-2023', 'DD-MM-YYYY'), 
        'MADRID', 'MADRID', 'L', 30, TO_DATE('10-03-2023', 'DD-MM-YYYY'));

-- 14. Finalmente, creamos posts (uno para usuario P y otro para usuario L)
INSERT INTO posts(SIGNATURE, USER_ID, STOPDATE, POST_DATE, TEXT, LIKES, DISLIKES)
VALUES ('CP001', 'USR001', TO_DATE('10-02-2023', 'DD-MM-YYYY'), 
        TO_DATE('20-02-2023', 'DD-MM-YYYY'), 
        'Excelente libro. La prosa de Cervantes es magistral y la historia cautivadora. Muy recomendable para cualquier amante de la literatura.', 
        15, 2);

INSERT INTO posts(SIGNATURE, USER_ID, STOPDATE, POST_DATE, TEXT, LIKES, DISLIKES)
VALUES ('CP002', 'USR002', TO_DATE('10-02-2023', 'DD-MM-YYYY'), 
        TO_DATE('25-02-2023', 'DD-MM-YYYY'), 
        'Una obra esencial de la literatura universal. Los personajes están muy bien desarrollados y las aventuras son entretenidas e instructivas.', 
        20, 1);
