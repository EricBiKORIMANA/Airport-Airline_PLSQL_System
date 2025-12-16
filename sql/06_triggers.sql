-- ============================================================================
-- TRIGGER 1: UNIVERSAL AUDIT TRIGGER (ALL TABLES)
-- ============================================================================
-- Purpose: Logs ALL INSERT, UPDATE, DELETE operations on main tables
--          into the audit_log table
-- Tables Monitored: BOOKINGS, FLIGHTS, PASSENGERS, TICKETS, AIRCRAFTS, 
--                   AIRLINES, AIRPORTS, EMPLOYEES
-- ============================================================================

-- Trigger for BOOKINGS table
CREATE OR REPLACE TRIGGER trg_audit_bookings
AFTER INSERT OR UPDATE OR DELETE ON bookings
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_action VARCHAR2(20);
    v_row_id VARCHAR2(100);
    v_details VARCHAR2(4000);
BEGIN
    -- Determine action type
    IF INSERTING THEN
        v_action := 'INSERT';
        v_row_id := TO_CHAR(:NEW.booking_id);
        v_details := 'New Booking: Passenger=' || :NEW.passenger_id || 
                    ', Flight=' || :NEW.flight_id || 
                    ', Seat=' || :NEW.seat_no || 
                    ', Status=' || :NEW.status;
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        v_row_id := TO_CHAR(:NEW.booking_id);
        v_details := 'Updated Booking: ' || 
                    'Old Status=' || :OLD.status || ', New Status=' || :NEW.status || 
                    ', Old Seat=' || :OLD.seat_no || ', New Seat=' || :NEW.seat_no;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        v_row_id := TO_CHAR(:OLD.booking_id);
        v_details := 'Deleted Booking: Passenger=' || :OLD.passenger_id || 
                    ', Flight=' || :OLD.flight_id || 
                    ', Seat=' || :OLD.seat_no;
    END IF;
    
    -- Insert audit record
    INSERT INTO audit_log (audit_user, audit_action, audit_table, audit_row_id, details)
    VALUES (USER, v_action, 'BOOKINGS', v_row_id, v_details);
    
    COMMIT;
END;
/

-- Trigger for FLIGHTS table
CREATE OR REPLACE TRIGGER trg_audit_flights
AFTER INSERT OR UPDATE OR DELETE ON flights
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_action VARCHAR2(20);
    v_row_id VARCHAR2(100);
    v_details VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
        v_row_id := TO_CHAR(:NEW.flight_id);
        v_details := 'New Flight: Airline=' || :NEW.airline_id || 
                    ', Aircraft=' || :NEW.aircraft_id || 
                    ', Fare=' || :NEW.fare || 
                    ', Available Seats=' || :NEW.available_seats;
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        v_row_id := TO_CHAR(:NEW.flight_id);
        v_details := 'Updated Flight: ' ||
                    'Fare: ' || :OLD.fare || '->' || :NEW.fare || 
                    ', Seats: ' || :OLD.available_seats || '->' || :NEW.available_seats;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        v_row_id := TO_CHAR(:OLD.flight_id);
        v_details := 'Deleted Flight: Airline=' || :OLD.airline_id || 
                    ', Aircraft=' || :OLD.aircraft_id;
    END IF;
    
    INSERT INTO audit_log (audit_user, audit_action, audit_table, audit_row_id, details)
    VALUES (USER, v_action, 'FLIGHTS', v_row_id, v_details);
    
    COMMIT;
END;
/

-- Trigger for PASSENGERS table
CREATE OR REPLACE TRIGGER trg_audit_passengers
AFTER INSERT OR UPDATE OR DELETE ON passengers
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_action VARCHAR2(20);
    v_row_id VARCHAR2(100);
    v_details VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
        v_row_id := TO_CHAR(:NEW.passenger_id);
        v_details := 'New Passenger: ' || :NEW.full_name || 
                    ', Nationality=' || :NEW.nationality || 
                    ', Contact=' || :NEW.contact_no;
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        v_row_id := TO_CHAR(:NEW.passenger_id);
        v_details := 'Updated Passenger: Name=' || :NEW.full_name || 
                    ', Old Contact=' || :OLD.contact_no || 
                    ', New Contact=' || :NEW.contact_no;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        v_row_id := TO_CHAR(:OLD.passenger_id);
        v_details := 'Deleted Passenger: ' || :OLD.full_name;
    END IF;
    
    INSERT INTO audit_log (audit_user, audit_action, audit_table, audit_row_id, details)
    VALUES (USER, v_action, 'PASSENGERS', v_row_id, v_details);
    
    COMMIT;
END;
/

-- Trigger for TICKETS table
CREATE OR REPLACE TRIGGER trg_audit_tickets
AFTER INSERT OR UPDATE OR DELETE ON tickets
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_action VARCHAR2(20);
    v_row_id VARCHAR2(100);
    v_details VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
        v_row_id := TO_CHAR(:NEW.ticket_id);
        v_details := 'New Ticket: Booking=' || :NEW.booking_id || 
                    ', Amount=' || :NEW.total_amount || 
                    ', Payment=' || :NEW.payment_mode;
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        v_row_id := TO_CHAR(:NEW.ticket_id);
        v_details := 'Updated Ticket: Amount=' || :OLD.total_amount || 
                    '->' || :NEW.total_amount;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        v_row_id := TO_CHAR(:OLD.ticket_id);
        v_details := 'Deleted Ticket: Amount=' || :OLD.total_amount;
    END IF;
    
    INSERT INTO audit_log (audit_user, audit_action, audit_table, audit_row_id, details)
    VALUES (USER, v_action, 'TICKETS', v_row_id, v_details);
    
    COMMIT;
END;
/

-- Trigger for AIRCRAFTS table
CREATE OR REPLACE TRIGGER trg_audit_aircrafts
AFTER INSERT OR UPDATE OR DELETE ON aircrafts
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_action VARCHAR2(20);
    v_row_id VARCHAR2(100);
    v_details VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
        v_row_id := TO_CHAR(:NEW.aircraft_id);
        v_details := 'New Aircraft: Model=' || :NEW.model || 
                    ', Capacity=' || :NEW.capacity || 
                    ', Airline=' || :NEW.airline_id;
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        v_row_id := TO_CHAR(:NEW.aircraft_id);
        v_details := 'Updated Aircraft: Capacity=' || :OLD.capacity || 
                    '->' || :NEW.capacity;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        v_row_id := TO_CHAR(:OLD.aircraft_id);
        v_details := 'Deleted Aircraft: Model=' || :OLD.model;
    END IF;
    
    INSERT INTO audit_log (audit_user, audit_action, audit_table, audit_row_id, details)
    VALUES (USER, v_action, 'AIRCRAFTS', v_row_id, v_details);
    
    COMMIT;
END;
/

-- Trigger for AIRLINES table
CREATE OR REPLACE TRIGGER trg_audit_airlines
AFTER INSERT OR UPDATE OR DELETE ON airlines
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_action VARCHAR2(20);
    v_row_id VARCHAR2(100);
    v_details VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
        v_row_id := TO_CHAR(:NEW.airline_id);
        v_details := 'New Airline: Name=' || :NEW.name || 
                    ', HQ=' || :NEW.headquarters;
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        v_row_id := TO_CHAR(:NEW.airline_id);
        v_details := 'Updated Airline: Name=' || :NEW.name || 
                    ', Old HQ=' || :OLD.headquarters || 
                    ', New HQ=' || :NEW.headquarters;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        v_row_id := TO_CHAR(:OLD.airline_id);
        v_details := 'Deleted Airline: ' || :OLD.name;
    END IF;
    
    INSERT INTO audit_log (audit_user, audit_action, audit_table, audit_row_id, details)
    VALUES (USER, v_action, 'AIRLINES', v_row_id, v_details);
    
    COMMIT;
END;
/

-- Trigger for AIRPORTS table
CREATE OR REPLACE TRIGGER trg_audit_airports
AFTER INSERT OR UPDATE OR DELETE ON airports
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_action VARCHAR2(20);
    v_row_id VARCHAR2(100);
    v_details VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
        v_row_id := TO_CHAR(:NEW.airport_id);
        v_details := 'New Airport: Name=' || :NEW.name || 
                    ', Location=' || :NEW.location || 
                    ', Country=' || :NEW.country;
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        v_row_id := TO_CHAR(:NEW.airport_id);
        v_details := 'Updated Airport: ' || :NEW.name || 
                    ', Location=' || :NEW.location;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        v_row_id := TO_CHAR(:OLD.airport_id);
        v_details := 'Deleted Airport: ' || :OLD.name;
    END IF;
    
    INSERT INTO audit_log (audit_user, audit_action, audit_table, audit_row_id, details)
    VALUES (USER, v_action, 'AIRPORTS', v_row_id, v_details);
    
    COMMIT;
END;
/

-- Trigger for EMPLOYEES table
CREATE OR REPLACE TRIGGER trg_audit_employees
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_action VARCHAR2(20);
    v_row_id VARCHAR2(100);
    v_details VARCHAR2(4000);
BEGIN
    IF INSERTING THEN
        v_action := 'INSERT';
        v_row_id := TO_CHAR(:NEW.emp_id);
        v_details := 'New Employee: Username=' || :NEW.username || 
                    ', Name=' || :NEW.full_name || 
                    ', Role=' || :NEW.role;
    ELSIF UPDATING THEN
        v_action := 'UPDATE';
        v_row_id := TO_CHAR(:NEW.emp_id);
        v_details := 'Updated Employee: ' || :NEW.full_name || 
                    ', Old Role=' || :OLD.role || 
                    ', New Role=' || :NEW.role;
    ELSIF DELETING THEN
        v_action := 'DELETE';
        v_row_id := TO_CHAR(:OLD.emp_id);
        v_details := 'Deleted Employee: ' || :OLD.full_name;
    END IF;
    
    INSERT INTO audit_log (audit_user, audit_action, audit_table, audit_row_id, details)
    VALUES (USER, v_action, 'EMPLOYEES', v_row_id, v_details);
    
    COMMIT;
END;
/


-- ============================================================================
-- TRIGGER 2: FLIGHT-SPECIFIC AUDIT LOG TRIGGER
-- ============================================================================
-- Purpose: Logs flight schedule changes (departure/arrival times) into 
--          flight_audit_log table for detailed tracking
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_flight_schedule_audit
AFTER UPDATE OF departure_time, arrival_time ON flights
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    -- Only log if times actually changed
    IF (:OLD.departure_time != :NEW.departure_time) OR 
       (:OLD.arrival_time != :NEW.arrival_time) THEN
        
        INSERT INTO flight_audit_log (
            flight_id,
            old_departure_time,
            new_departure_time,
            old_arrival_time,
            new_arrival_time,
            modified_by
        ) VALUES (
            :NEW.flight_id,
            :OLD.departure_time,
            :NEW.departure_time,
            :OLD.arrival_time,
            :NEW.arrival_time,
            USER
        );
        
        COMMIT;
    END IF;
END;
/


-- ============================================================================
-- TRIGGER 3: AUDIT_LOG PROTECTION TRIGGER
-- ============================================================================
-- Purpose: Special trigger on audit_log table itself to:
--          1. Prevent unauthorized deletions
--          2. Prevent unauthorized updates
--          3. Log who attempts to modify audit records
--          4. Allow only ADMIN role to manage audit logs
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_protect_audit_log
BEFORE DELETE OR UPDATE ON audit_log
FOR EACH ROW
DECLARE
    v_user_role VARCHAR2(50);
    v_is_admin BOOLEAN := FALSE;
BEGIN
    -- Check if current user is an admin
    BEGIN
        SELECT role INTO v_user_role
        FROM employees
        WHERE username = USER;
        
        IF v_user_role = 'ADMIN' THEN
            v_is_admin := TRUE;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_is_admin := FALSE;
    END;
    
    -- If not admin, prevent the operation
    IF NOT v_is_admin THEN
        IF DELETING THEN
            RAISE_APPLICATION_ERROR(-20301, 
                'SECURITY VIOLATION: Only ADMIN users can delete audit log records. ' ||
                'User: ' || USER || ' attempted to delete Audit ID: ' || :OLD.audit_id);
        ELSIF UPDATING THEN
            RAISE_APPLICATION_ERROR(-20302, 
                'SECURITY VIOLATION: Only ADMIN users can modify audit log records. ' ||
                'User: ' || USER || ' attempted to modify Audit ID: ' || :OLD.audit_id);
        END IF;
    ELSE
        -- Admin is performing operation - log it
        DBMS_OUTPUT.PUT_LINE('ADMIN AUDIT ACCESS: User ' || USER || 
                           ' modified audit record ID: ' || :OLD.audit_id);
    END IF;
END;
/



-- ============================================================================
-- TRIGGER 4: WEEKEND & HOLIDAY RESTRICTION TRIGGER
-- ============================================================================
-- Purpose: Prevents employee operations on weekends and holidays
-- Applies to: BOOKINGS, FLIGHTS, TICKETS, PASSENGERS
-- Exemption: ADMIN role can work anytime
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_weekend_holiday_restriction
BEFORE INSERT OR UPDATE OR DELETE ON bookings
FOR EACH ROW
DECLARE
    v_user_role VARCHAR2(50);
    v_is_admin BOOLEAN := FALSE;
    v_day_of_week VARCHAR2(10);
    v_holiday_count NUMBER;
    v_holiday_name VARCHAR2(100);
BEGIN
    -- Check if current user is an admin (admins are exempt)
    BEGIN
        SELECT role INTO v_user_role
        FROM employees
        WHERE username = USER;
        
        IF v_user_role = 'ADMIN' THEN
            v_is_admin := TRUE;
            RETURN; -- Admin can proceed
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- User not in employees table, continue with checks
    END;
    
    -- Check if today is a weekend
    v_day_of_week := TRIM(TO_CHAR(SYSDATE, 'DAY'));
    
    IF v_day_of_week IN ('SATURDAY', 'SUNDAY') THEN
        RAISE_APPLICATION_ERROR(-20401, 
            'OPERATION RESTRICTED: Booking operations are not allowed on weekends. ' ||
            'Today is ' || v_day_of_week || '. ' ||
            'Contact your ADMIN for emergency operations.');
    END IF;
    
    -- Check if today is a holiday
    SELECT COUNT(*), MAX(holiday_name)
    INTO v_holiday_count, v_holiday_name
    FROM holidays
    WHERE TRUNC(holiday_date) = TRUNC(SYSDATE)
    AND is_active = 'Y';
    
    IF v_holiday_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20402, 
            'OPERATION RESTRICTED: Booking operations are not allowed on holidays. ' ||
            'Today is: ' || v_holiday_name || '. ' ||
            'Contact your ADMIN for emergency operations.');
    END IF;
END;
/

-- Apply same restriction to FLIGHTS table
CREATE OR REPLACE TRIGGER trg_flights_weekend_holiday_restrict
BEFORE INSERT OR UPDATE OR DELETE ON flights
FOR EACH ROW
DECLARE
    v_user_role VARCHAR2(50);
    v_is_admin BOOLEAN := FALSE;
    v_day_of_week VARCHAR2(10);
    v_holiday_count NUMBER;
    v_holiday_name VARCHAR2(100);
BEGIN
    BEGIN
        SELECT role INTO v_user_role
        FROM employees
        WHERE username = USER;
        
        IF v_user_role = 'ADMIN' THEN
            RETURN;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
    END;
    
    v_day_of_week := TRIM(TO_CHAR(SYSDATE, 'DAY'));
    
    IF v_day_of_week IN ('SATURDAY', 'SUNDAY') THEN
        RAISE_APPLICATION_ERROR(-20403, 
            'OPERATION RESTRICTED: Flight operations are not allowed on weekends.');
    END IF;
    
    SELECT COUNT(*), MAX(holiday_name)
    INTO v_holiday_count, v_holiday_name
    FROM holidays
    WHERE TRUNC(holiday_date) = TRUNC(SYSDATE)
    AND is_active = 'Y';
    
    IF v_holiday_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20404, 
            'OPERATION RESTRICTED: Flight operations are not allowed on holidays. ' ||
            'Today is: ' || v_holiday_name);
    END IF;
END;
/

-- Apply same restriction to TICKETS table
CREATE OR REPLACE TRIGGER trg_tickets_weekend_holiday_restrict
BEFORE INSERT OR UPDATE OR DELETE ON tickets
FOR EACH ROW
DECLARE
    v_user_role VARCHAR2(50);
    v_day_of_week VARCHAR2(10);
    v_holiday_count NUMBER;
BEGIN
    -- Check if current user is an admin (admins are exempt)
    BEGIN
        SELECT role INTO v_user_role
        FROM employees
        WHERE username = USER;
        
        IF v_user_role = 'ADMIN' THEN
            RETURN; -- Admin can proceed
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- User not in employees table, continue with checks
    END;
    
    -- Check if today is a weekend
    v_day_of_week := TRIM(TO_CHAR(SYSDATE, 'DAY'));
    
    IF v_day_of_week IN ('SATURDAY', 'SUNDAY') THEN
        RAISE_APPLICATION_ERROR(-20405, 
            'OPERATION RESTRICTED: Ticket operations are not allowed on weekends. ' ||
            'Today is ' || v_day_of_week || '. ' ||
            'Contact your ADMIN for emergency operations.');
    END IF;
    
    -- Check if today is a holiday ( Using SELECT COUNT(*) to avoid unnecessary variable )
    SELECT COUNT(*)
    INTO v_holiday_count
    FROM holidays
    WHERE TRUNC(holiday_date) = TRUNC(SYSDATE)
    AND is_active = 'Y';
    
    IF v_holiday_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20405, 
            'OPERATION RESTRICTED: Ticket operations are not allowed on holidays. ' ||
            'Contact your ADMIN for emergency operations.');
    END IF;
END;
/

-- Apply same restriction to PASSENGERS table
CREATE OR REPLACE TRIGGER trg_passengers_weekend_holiday_restrict
BEFORE INSERT OR UPDATE OR DELETE ON passengers
FOR EACH ROW
DECLARE
    v_user_role VARCHAR2(50);
    v_day_of_week VARCHAR2(10);
    v_holiday_count NUMBER;
BEGIN
    -- Check if current user is an admin (admins are exempt)
    BEGIN
        SELECT role INTO v_user_role
        FROM employees
        WHERE username = USER;
        
        IF v_user_role = 'ADMIN' THEN
            RETURN; -- Admin can proceed
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- User not in employees table, continue with checks
    END;
    
    -- Check if today is a weekend
    v_day_of_week := TRIM(TO_CHAR(SYSDATE, 'DAY'));
    
    IF v_day_of_week IN ('SATURDAY', 'SUNDAY') THEN
        RAISE_APPLICATION_ERROR(-20406, 
            'OPERATION RESTRICTED: Passenger operations are not allowed on weekends. ' ||
            'Today is ' || v_day_of_week || '. ' ||
            'Contact your ADMIN for emergency operations.');
    END IF;
    
    -- Check if today is a holiday (Using SELECT COUNT(*) )
    SELECT COUNT(*)
    INTO v_holiday_count
    FROM holidays
    WHERE TRUNC(holiday_date) = TRUNC(SYSDATE)
    AND is_active = 'Y';
    
    IF v_holiday_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20406, 
            'OPERATION RESTRICTED: Passenger operations are not allowed on holidays. ' ||
            'Contact your ADMIN for emergency operations.');
    END IF;
END;
/