CREATE OR REPLACE PACKAGE foundicu AS
  current_user_id VARCHAR2(20);
  PROCEDURE set_current_user(p_userid VARCHAR2);
  FUNCTION get_current_user RETURN VARCHAR2;
  PROCEDURE insert_loan(p_signature VARCHAR2);
  PROCEDURE insert_reservation(p_isbn VARCHAR2, p_date DATE);
  PROCEDURE record_return(p_signature VARCHAR2);
END foundicu;
/



CREATE OR REPLACE PACKAGE BODY foundicu AS

    PROCEDURE set_current_user(p_userid VARCHAR2) IS
    BEGIN
    current_user_id := p_userid;
    END;

    FUNCTION get_current_user RETURN VARCHAR2 IS
    BEGIN
    RETURN current_user_id;
    END;
    
    -- INSERT LOAN
    --Insert Loan Procedure: receives a signature; checks current USER exists, and that there is
    --a hold on the copy (signature) for the current user as of today, and turns that reservation
    --into a loan; otherwise (no reservation), checks that the copy is available for two weeks,
    --and that the current user has not reached the upper limit for loans (nor they are
    --sanctioned); when loan is possible inserts a new loan row, else reports about the problem.

    PROCEDURE insert_loan(p_signature VARCHAR2) IS
    v_exists     INTEGER;
    v_ban_date   DATE;
    v_loans      INTEGER;
    v_signature_reservation  VARCHAR2(5);
    v_conflicting_loans INTEGER;
    v_town       users.town%TYPE;
    v_province   users.province%TYPE;
    
    BEGIN
    -- We first do all the checks to ensure that the user can turn the reservation into a loan or just 
    -- make a new loan
    -- Check that the user exists
    SELECT COUNT(*) INTO v_exists FROM USERS WHERE USER_ID = current_user_id;
    IF v_exists = 0 THEN
    -- If the user does not exist, raise an error
      RAISE_APPLICATION_ERROR(-20101, 'User does not exist');
    END IF;
    -- Check if the user is banned
    SELECT BAN_UP2 INTO v_ban_date FROM USERS WHERE USER_ID = current_user_id;
    -- Use trunc to compare dates
    IF v_ban_date IS NOT NULL AND v_ban_date > TRUNC(SYSDATE) THEN
    -- If the user is banned, raise an error
      RAISE_APPLICATION_ERROR(-20102, 'User is banned');
    END IF;
    -- Check if the user has fewer than 2 active loans
    SELECT COUNT(*) INTO v_loans
    FROM LOANS
    WHERE USER_ID = current_user_id
      AND TYPE = 'L'
      AND RETURN IS NULL;

    IF v_loans >= 2 THEN
    -- If the user has 2 or more active loans then they cannot make a new loan
      RAISE_APPLICATION_ERROR(-20103, 'Loan limit reached');
    END IF;

    -- Check that the copy exists and is not deregistered
    SELECT COUNT(*) INTO v_exists
    FROM COPIES
    WHERE SIGNATURE = p_signature
      AND DEREGISTERED IS NULL;

    IF v_exists = 0 THEN
    -- If the copy does not exist or is deregistered, raise an error
      RAISE_APPLICATION_ERROR(-20104, 'Copy does not exist or is deregistered');
    END IF;

    -- Check if the copy is reserved for the current user and the stopdate is greater than today
    SELECT COUNT(*) INTO v_signature_reservation
    FROM LOANS
    WHERE SIGNATURE = p_signature
      AND USER_ID = current_user_id
      AND TYPE = 'R'
      AND RETURN IS NULL
        -- Use TRUNC to compare dates 
      AND STOPDATE >= TRUNC(SYSDATE);
    
    IF v_signature_reservation = 0 THEN
    -- IF the user has not reserved the copy, check if it is available for two weeks
    -- Check that there are no active loans for the copy in the next two weeks
      SELECT COUNT(*) INTO v_conflicting_loans
      FROM LOANS
      WHERE SIGNATURE = p_signature
        AND TYPE = 'L'
    -- Add 14 days to the current date to check for availability
        AND STOPDATE BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE + 14);
    
      IF v_conflicting_loans > 0 THEN
        -- If the copy is reserved for another user, raise an error
        RAISE_APPLICATION_ERROR(-20105, 'Copy is reserved for another user');
      END IF;
    END IF;
    
    -- The copy is aviable, insert the loan
    -- First get the town and province from the user table
    SELECT TOWN, PROVINCE INTO v_town, v_province
    FROM USERS
    WHERE USER_ID = current_user_id;

    -- Finally, insert the loan
    -- The minutes are calculated as the current hour in 24h format multiplied by 60 plus the current minutes to obtain
    -- the minutes that passed on that day since midnight
    INSERT INTO LOANS(SIGNATURE, USER_ID, STOPDATE, TOWN, PROVINCE, TYPE, TIME,RETURN)
    VALUES (p_signature, current_user_id, NULL, v_town, v_province, 'L',  (TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) * 60) + TO_NUMBER(TO_CHAR(SYSDATE, 'MI')), TRUNC(SYSDATE + 14));
    END insert_loan;

    -- INSERT RESERVATION
    PROCEDURE insert_reservation(p_isbn VARCHAR2, p_date DATE) IS
    v_exists     INTEGER;
    v_ban_date   DATE;
    v_loans      INTEGER;
    v_signature  VARCHAR2(5);
    BEGIN
    -- Check that the user exists
    SELECT COUNT(*) INTO v_exists FROM USERS WHERE USER_ID = current_user_id;
    IF v_exists = 0 THEN
      RAISE_APPLICATION_ERROR(-20101, 'User does not exist');
    END IF;

    -- Check if the user is banned
    SELECT BAN_UP2 INTO v_ban_date FROM USERS WHERE USER_ID = current_user_id;
    IF v_ban_date IS NOT NULL AND v_ban_date > SYSDATE THEN
      RAISE_APPLICATION_ERROR(-20102, 'User is banned');
    END IF;

    -- Check if the user has fewer than 2 active loans
    SELECT COUNT(*) INTO v_loans
    FROM LOANS
    WHERE USER_ID = current_user_id
      AND TYPE = 'L'
      AND RETURN IS NULL;

    IF v_loans >= 2 THEN
      RAISE_APPLICATION_ERROR(-20103, 'Loan limit reached');
    END IF;

    -- Search for an available copy of the ISBN
    SELECT c.SIGNATURE INTO v_signature
    FROM COPIES c
    WHERE c.ISBN = p_isbn
      AND c.CONDITION != 'D'
      AND NOT EXISTS (
        SELECT 1 FROM LOANS l
        WHERE l.SIGNATURE = c.SIGNATURE
          AND l.STOPDATE BETWEEN p_date AND p_date + 14
      )
      AND ROWNUM = 1;

    -- Insert the reservation
    INSERT INTO LOANS(SIGNATURE, USER_ID, TYPE, STOPDATE)
    VALUES(v_signature, current_user_id, 'R', p_date);

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20104, 'No available copy to reserve');
    END insert_reservation;

    -- RECORD RETURN
    PROCEDURE record_return(p_signature VARCHAR2) IS
    v_exists INTEGER;
    BEGIN
    -- Check if there is an active loan
    SELECT COUNT(*) INTO v_exists
    FROM LOANS
    WHERE SIGNATURE = p_signature
      AND USER_ID = current_user_id
      AND TYPE = 'L'
      AND RETURN IS NULL;

    IF v_exists = 0 THEN
      RAISE_APPLICATION_ERROR(-20201, 'No active loan found');
    END IF;

    -- Register the return
    UPDATE LOANS
    SET RETURN = SYSDATE
    WHERE SIGNATURE = p_signature
      AND USER_ID = current_user_id
      AND TYPE = 'L'
      AND RETURN IS NULL;
    END record_return;

END foundicu;
/
