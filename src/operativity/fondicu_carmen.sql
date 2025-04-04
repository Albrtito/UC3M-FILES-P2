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

