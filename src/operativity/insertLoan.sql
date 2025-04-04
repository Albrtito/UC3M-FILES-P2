PROCEDURE insert_loan(p_signature IN copies.signature%TYPE) IS
        v_user_id users.user_id%TYPE;
        v_copy_available BOOLEAN := FALSE;
        v_has_reservation BOOLEAN := FALSE;
        v_town services.town%TYPE;
        v_province services.province%TYPE;
        v_taskdate services.taskdate%TYPE;
        v_is_copy_valid BOOLEAN := FALSE;
    BEGIN
        -- Get current user ID
        v_user_id := get_current_user_id();
        
        -- Check if user exists
        IF v_user_id IS NULL THEN
            DBMS_OUTPUT.PUT_LINE('Error: Current user not found.');
            RETURN;
        END IF;
        
        -- Check if user is banned
        IF is_user_banned(v_user_id) THEN
            DBMS_OUTPUT.PUT_LINE('Error: User is currently banned from borrowing.');
            RETURN;
        END IF;
        
        -- Validate copy exists
        BEGIN
            SELECT 1 INTO v_is_copy_valid
            FROM copies
            WHERE signature = p_signature
            AND deregistered IS NULL;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Error: Copy not found or deregistered.');
                RETURN;
        END;
        
        -- Check if there's a reservation for this user today
        BEGIN
            SELECT town, province, taskdate, TRUE
            INTO v_town, v_province, v_taskdate, v_has_reservation
            FROM services s
            WHERE taskdate = TRUNC(SYSDATE)
            AND EXISTS (
                SELECT 1
                FROM stops st
                WHERE st.town = s.town
                AND st.province = s.province
            )
            AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_has_reservation := FALSE;
        END;
        
        -- If reservation exists, convert it to loan
        IF v_has_reservation THEN
            -- Check if the user has loan quota
            IF NOT check_user_loan_limit(v_user_id) THEN
                DBMS_OUTPUT.PUT_LINE('Error: User has reached maximum loan limit.');
                RETURN;
            END IF;
            
            -- Insert the loan
            INSERT INTO loans (signature, user_id, stopdate, town, province, type, time, return)
            VALUES (p_signature, v_user_id, v_taskdate, v_town, v_province, 'B', 14, NULL);
            
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Success: Loan registered based on reservation.');
        ELSE
            -- No reservation exists, check copy availability for two weeks
            -- Check if this copy is currently loaned
            BEGIN
                SELECT 1 INTO v_is_copy_valid
                FROM copies c
                WHERE c.signature = p_signature
                AND c.deregistered IS NULL
                AND NOT EXISTS (
                    SELECT 1
                    FROM loans l
                    WHERE l.signature = c.signature
                    AND l.return IS NULL
                );
                
                v_copy_available := TRUE;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_copy_available := FALSE;
            END;
            
            -- If copy is available and user has quota
            IF v_copy_available AND check_user_loan_limit(v_user_id) THEN
                -- Find a valid service for today
                BEGIN
                    SELECT town, province, taskdate
                    INTO v_town, v_province, v_taskdate
                    FROM services
                    WHERE taskdate = TRUNC(SYSDATE)
                    AND ROWNUM = 1;
                    
                    -- Insert the loan
                    INSERT INTO loans (signature, user_id, stopdate, town, province, type, time, return)
                    VALUES (p_signature, v_user_id, v_taskdate, v_town, v_province, 'B', 14, NULL);
                    
                    COMMIT;
                    DBMS_OUTPUT.PUT_LINE('Success: Direct loan registered.');
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        DBMS_OUTPUT.PUT_LINE('Error: No service available for today.');
                END;
            ELSE
                IF NOT v_copy_available THEN
                    DBMS_OUTPUT.PUT_LINE('Error: Copy is not available for loan.');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('Error: User has reached maximum loan limit.');
                END IF;
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in insert_loan: ' || SQLERRM);
            ROLLBACK;
    END insert_loan;
