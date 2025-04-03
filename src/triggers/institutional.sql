-- Description: Prevents the insertion of posts of institutional users (municipal libraries). The trigger is used before the insertion of a new post in the posttable, checking the type of user by the userID provided for the insert.
-- If the user.type is 'L' then it is a library

CREATE OR REPLACE TRIGGER trg_prevent_institutional_posts
-- Before the insert
BEFORE INSERT ON posts
FOR EACH ROW

DECLARE
user_type users.type%TYPE;
BEGIN
-- Get the user type
    select type into user_type 
        from users 
        WHERE userID = :NEW.userID;

    -- Check if the user type is 'L' (library)
    IF user_type = 'L' THEN
        -- Raise an error if the user is a library
        RAISE_APPLICATION_ERROR(-20001, 'Institutional users cannot create posts.');
    END IF;
END;
