-- Tests para el trigger trg_prevent_institutional_posts

-- insert into users a normal user (P) (user_ID, name, type) values (1, 'John Doe', 'P');
INSERT INTO USERS(USER_ID, ID_CARD, name, surname1,surname2,birthdate,town,province,address,email,phone,type) VALUES ("1","1",'John',"Doe","gomez",SYSDATE,"TOWN1","PROVINCE1","ADDRESS1","EMAIL1",999999999,'P');
-- insert into users a library user (L) (user_ID, name, type) values (2, 'Library User', 'L');
INSERT INTO USERS(USER_ID, ID_CARD, name, surname1,surname2,birthdate,town,province,address,email,phone,type) VALUES ("2","2",'Library',"Doe","gomez",SYSDATE,"TOWN2","PROVINCE2","ADDRESS2","EMAIL2",999999999,'L');
-- insert a post with a normal user (P) (signature, user_ID, stopdate, post_date, text) values ('A1', 1, '2023-10-01', '2023-10-02', 'This is a post from a normal user.'); -> This should work
-- insert a post with a library user (L) (signature, user_ID, stopdate, post_date, text) values ('A2', 2, '2023-10-01', '2023-10-02', 'This is a post from a library user.'); -> This should raise an error
