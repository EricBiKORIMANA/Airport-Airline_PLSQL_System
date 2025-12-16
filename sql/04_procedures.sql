-- Procedure 1: Add Flight
CREATE OR REPLACE PROCEDURE add_flight(
    p_airline_id IN NUMBER,
    p_aircraft_id IN NUMBER,
    p_departure_airport IN NUMBER,
    p_arrival_airport IN NUMBER,
    p_departure_time IN TIMESTAMP,
    p_arrival_time IN TIMESTAMP,
    p_fare IN NUMBER
) AS
    v_aircraft_capacity NUMBER;
    v_airline_exists NUMBER;
    v_departure_exists NUMBER;
    v_arrival_exists NUMBER;
BEGIN
    -- Validate airline exists
    SELECT COUNT(*) INTO v_airline_exists
    FROM airlines WHERE airline_id = p_airline_id;
    
    IF v_airline_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid airline ID.');
    END IF;
    
    -- Validate airports exist
    SELECT COUNT(*) INTO v_departure_exists
    FROM airports WHERE airport_id = p_departure_airport;
    
    SELECT COUNT(*) INTO v_arrival_exists
    FROM airports WHERE airport_id = p_arrival_airport;
    
    IF v_departure_exists = 0 OR v_arrival_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid airport ID.');
    END IF;
    
    -- Get aircraft capacity
    SELECT capacity INTO v_aircraft_capacity
    FROM aircrafts WHERE aircraft_id = p_aircraft_id;
    
    -- Insert flight
    INSERT INTO flights(airline_id, aircraft_id, departure_airport, 
                       arrival_airport, departure_time, arrival_time, fare, available_seats)
    VALUES (p_airline_id, p_aircraft_id, p_departure_airport,
            p_arrival_airport, p_departure_time, p_arrival_time, p_fare, v_aircraft_capacity);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Flight added successfully with ID: ' || seq_flight.CURRVAL);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Aircraft not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error adding flight: ' || SQLERRM);
END add_flight;
/

-- Procedure 2: Book Ticket
CREATE OR REPLACE PROCEDURE book_ticket(
    p_passenger_id IN NUMBER,
    p_flight_id IN NUMBER,
    p_seat_no IN VARCHAR2,
    p_payment_mode IN VARCHAR2
) AS
    v_available_seats NUMBER;
    v_fare NUMBER;
    v_booking_id NUMBER;
    seat_already_booked EXCEPTION;
    no_seats_available EXCEPTION;
BEGIN
    -- Check available seats
    v_available_seats := get_available_seats(p_flight_id);
    
    IF v_available_seats <= 0 THEN
        RAISE no_seats_available;
    END IF;
    
    -- Get fare
    SELECT fare INTO v_fare FROM flights WHERE flight_id = p_flight_id;
    
    -- Insert booking
    INSERT INTO bookings(passenger_id, flight_id, seat_no, booking_date, status)
    VALUES (p_passenger_id, p_flight_id, p_seat_no, SYSDATE, 'CONFIRMED')
    RETURNING booking_id INTO v_booking_id;
    
    -- Insert ticket
    INSERT INTO tickets(booking_id, issue_date, payment_mode, total_amount)
    VALUES (v_booking_id, SYSDATE, p_payment_mode, v_fare);
    
    -- Update available seats (trigger will handle this, but backup manual update)
    UPDATE flights SET available_seats = available_seats - 1
    WHERE flight_id = p_flight_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Booking successful! Booking ID: ' || v_booking_id);
    DBMS_OUTPUT.PUT_LINE('Ticket issued. Total amount: $' || v_fare);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: Seat ' || p_seat_no || ' is already booked for this flight.');
    WHEN no_seats_available THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: No seats available for this flight.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Booking error: ' || SQLERRM);
END book_ticket;
/

-- Procedure 3: Cancel Booking
CREATE OR REPLACE PROCEDURE cancel_booking(p_booking_id IN NUMBER) AS
    v_flight_id NUMBER;
    v_current_status VARCHAR2(20);
BEGIN
    -- Get booking details
    SELECT flight_id, status 
    INTO v_flight_id, v_current_status
    FROM bookings 
    WHERE booking_id = p_booking_id;
    
    IF v_current_status = 'CANCELLED' THEN
        DBMS_OUTPUT.PUT_LINE('Booking is already cancelled.');
        RETURN;
    END IF;
    
    -- Update booking status
    UPDATE bookings 
    SET status = 'CANCELLED'
    WHERE booking_id = p_booking_id;
    
    -- Restore available seats
    UPDATE flights 
    SET available_seats = available_seats + 1
    WHERE flight_id = v_flight_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Booking cancelled successfully. Seat restored.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Booking ID not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Cancellation error: ' || SQLERRM);
END cancel_booking;
/

-- Procedure 4: Update Flight Details
CREATE OR REPLACE PROCEDURE update_flight_details(
    p_flight_id IN NUMBER,
    p_new_departure_time IN TIMESTAMP,
    p_new_arrival_time IN TIMESTAMP
) AS
    v_flight_exists NUMBER;
BEGIN
    -- Validate flight exists
    SELECT COUNT(*) INTO v_flight_exists
    FROM flights WHERE flight_id = p_flight_id;
    
    IF v_flight_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Flight ID does not exist.');
    END IF;
    
    -- Validate time constraint
    IF p_new_arrival_time <= p_new_departure_time THEN
        RAISE_APPLICATION_ERROR(-20004, 'Arrival time must be after departure time.');
    END IF;
    
    -- Update flight
    UPDATE flights
    SET departure_time = p_new_departure_time,
        arrival_time = p_new_arrival_time
    WHERE flight_id = p_flight_id;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Flight schedule updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Update error: ' || SQLERRM);
END update_flight_details;
/