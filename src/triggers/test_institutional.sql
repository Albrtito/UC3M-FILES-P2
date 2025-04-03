-- Tests para el trigger trg_prevent_institutional_posts
-- Creación de los municipios necesarios para los usuarios
INSERT INTO municipalities(TOWN, PROVINCE, POPULATION)
VALUES ('TOWN1', 'PROVINCE1', 15000);

INSERT INTO municipalities(TOWN, PROVINCE, POPULATION)
VALUES ('TOWN2', 'PROVINCE2', 28500);


-- insert into users a normal user (P) (user_ID, name, type) values (1, 'John Doe', 'P');
INSERT INTO USERS(USER_ID, ID_CARD, NAME, SURNAME1, SURNAME2, BIRTHDATE, TOWN, PROVINCE, ADDRESS, EMAIL, PHONE, TYPE) 
VALUES ('1', '12345678A', 'John', 'Doe', 'Gomez', TO_DATE('15-04-1985', 'DD-MM-YYYY'), 'TOWN1', 'PROVINCE1', 'ADDRESS1', 'john.doe@email.com', 123456789, 'P');

-- insert into users a library user (L) (user_ID, name, type) values (2, 'Library User', 'L');
INSERT INTO USERS(USER_ID, ID_CARD, NAME, SURNAME1, SURNAME2, BIRTHDATE, TOWN, PROVINCE, ADDRESS, EMAIL, PHONE, TYPE) 
VALUES ('2', '87654321B', 'Library', 'User', 'Smith', TO_DATE('22-07-1990', 'DD-MM-YYYY'), 'TOWN2', 'PROVINCE2', 'ADDRESS2', 'library.user@email.com', 987654321, 'L');
-- insert a post with a normal user (P) (signature, user_ID, stopdate, post_date, text) values ('A1', 1, '2023-10-01', '2023-10-02', 'This is a post from a normal user.'); -> This should work
-- insert a post with a library user (L) (signature, user_ID, stopdate, post_date, text) values ('A2', 2, '2023-10-01', '2023-10-02', 'This is a post from a library user.'); -> This should raise an error
