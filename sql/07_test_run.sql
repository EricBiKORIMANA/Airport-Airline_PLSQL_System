SET SERVEROUTPUT ON;
-- Test 1: Get Available Seats
DECLARE
    v_seats NUMBER;
BEGIN
    v_seats := airport_mgmt_pkg.get_available_seats(1);
    DBMS_OUTPUT.PUT_LINE('Available seats for Flight 1: ' || v_seats);
    
    -- Test with invalid flight ID
    v_seats := airport_mgmt_pkg.get_available_seats(999);
    IF v_seats = -1 THEN
        DBMS_OUTPUT.PUT_LINE('Correctly handled invalid flight ID (returned -1)');
    END IF;
END;
/

-- Test 2: calculate_flight_duration
DECLARE
    v_duration NUMBER;
BEGIN
    v_duration := airport_mgmt_pkg.calculate_flight_duration(1);
    DBMS_OUTPUT.PUT_LINE('Duration of Flight 1: ' || v_duration || ' hours');
    
    v_duration := airport_mgmt_pkg.calculate_flight_duration(2);
    DBMS_OUTPUT.PUT_LINE('Duration of Flight 2: ' || v_duration || ' hours');
END;
/

-- Test 3: Get Total Revenue by Airline 
DECLARE
    v_revenue NUMBER;
BEGIN
    FOR airline_rec IN (SELECT airline_id, name FROM airlines) LOOP
        v_revenue := airport_mgmt_pkg.get_total_revenue(airline_rec.airline_id);
        DBMS_OUTPUT.PUT_LINE('Revenue for ' || airline_rec.name || ': $' || v_revenue);
    END LOOP;
END;
/

-- Test 4: get_booking_count
DECLARE
    v_count NUMBER;
BEGIN
    FOR flight_rec IN (SELECT flight_id FROM flights WHERE ROWNUM <= 3) LOOP
        v_count := airport_mgmt_pkg.get_booking_count(flight_rec.flight_id);
        DBMS_OUTPUT.PUT_LINE('Bookings for Flight ' || flight_rec.flight_id || ': ' || v_count);
    END LOOP;
END;
/

-- Test 5: Check Seat Availability
DECLARE
    v_available BOOLEAN;
BEGIN
    v_available := airport_mgmt_pkg.is_seat_available(1, '10A');
    IF v_available THEN
        DBMS_OUTPUT.PUT_LINE('Seat 10A on Flight 1: AVAILABLE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Seat 10A on Flight 1: NOT AVAILABLE');
    END IF;
    
    v_available := airport_mgmt_pkg.is_seat_available(1, '15A');
    IF v_available THEN
        DBMS_OUTPUT.PUT_LINE('Seat 15A on Flight 1: AVAILABLE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Seat 15A on Flight 1: NOT AVAILABLE');
    END IF;
END;
/



-- Test 1: Add Valid Flight 
BEGIN
    airport_mgmt_pkg.add_flight(
        p_airline_id => 1,
        p_aircraft_id => 1,
        p_departure_airport => 1,
        p_arrival_airport => 3,
        p_departure_time => TIMESTAMP '2025-12-20 10:00:00',
        p_arrival_time => TIMESTAMP '2025-12-20 11:30:00',
        p_fare => 300.00
    );
END;
/

-- Test error handling - invalid airline
-- Test 2: Add Flight with Invalid Airline (Should Fail) --
BEGIN
    airport_mgmt_pkg.add_flight(
        p_airline_id => 999,  -- Invalid ID
        p_aircraft_id => 1,
        p_departure_airport => 1,
        p_arrival_airport => 2,
        p_departure_time => TIMESTAMP '2025-12-21 10:00:00',
        p_arrival_time => TIMESTAMP '2025-12-21 11:00:00',
        p_fare => 200.00
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error caught as expected: ' || SQLERRM);
END;
/

-- Test error handling - same airports
-- Test 3: Add Flight with Same Departure/Arrival (Should Fail) --
BEGIN
    airport_mgmt_pkg.add_flight(
        p_airline_id => 1,
        p_aircraft_id => 1,
        p_departure_airport => 1,
        p_arrival_airport => 1,  -- Same as departure
        p_departure_time => TIMESTAMP '2025-12-21 10:00:00',
        p_arrival_time => TIMESTAMP '2025-12-21 11:00:00',
        p_fare => 200.00
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error caught as expected: ' || SQLERRM);
END;
/


-- ============================================================================
-- TEST PROCEDURE 2 - BOOK TICKET
-- ============================================================================


-- Get current seat availability before booking
-- Before Booking: Check Seat Status ---
DECLARE
    v_seats NUMBER;
BEGIN
    v_seats := airport_mgmt_pkg.get_available_seats(1);
    DBMS_OUTPUT.PUT_LINE('Available seats on Flight 1 BEFORE booking: ' || v_seats);
END;
/

-- Test successful booking
-- Test 1: Book Valid Ticket ---
BEGIN
    airport_mgmt_pkg.book_ticket(
        p_passenger_id => 1,
        p_flight_id => 1,
        p_seat_no => '21A',
        p_payment_mode => 'Credit Card'
    );
END;
/

-- Check seat availability after booking
-- After Booking: Check Seat Status ---
DECLARE
    v_seats NUMBER;
BEGIN
    v_seats := airport_mgmt_pkg.get_available_seats(1);
    DBMS_OUTPUT.PUT_LINE('Available seats on Flight 1 AFTER booking: ' || v_seats);
END;
/

-- Test duplicate seat booking (should fail)
-- Test 2: Try to Book Same Seat Again (Should Fail) --
BEGIN
    airport_mgmt_pkg.book_ticket(
        p_passenger_id => 2,
        p_flight_id => 1,
        p_seat_no => '21A',  -- Already booked
        p_payment_mode => 'Online'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error caught as expected: ' || SQLERRM);
END;
/

-- Book another ticket successfully
-- Test 3: Book Another Valid Ticket --
BEGIN
    airport_mgmt_pkg.book_ticket(
        p_passenger_id => 2,
        p_flight_id => 1,
        p_seat_no => '20B',
        p_payment_mode => 'Online'
    );
END;
/


-- ============================================================================
-- TEST PROCEDURE 3 - CANCEL BOOKING
-- ============================================================================


-- Get a booking ID to cancel
-- Get Recent Booking ID --
DECLARE
    v_booking_id NUMBER;
    v_seats_before NUMBER;
    v_seats_after NUMBER;
BEGIN
    -- Get the most recent booking
    SELECT booking_id INTO v_booking_id
    FROM bookings
    WHERE status = 'CONFIRMED'
    AND ROWNUM = 1
    ORDER BY booking_id DESC;
    
    DBMS_OUTPUT.PUT_LINE('Found Booking ID: ' || v_booking_id);
    
    -- Check seats before cancellation
    SELECT available_seats INTO v_seats_before
    FROM flights f
    INNER JOIN bookings b ON f.flight_id = b.flight_id
    WHERE b.booking_id = v_booking_id;
    
    DBMS_OUTPUT.PUT_LINE('Seats before cancellation: ' || v_seats_before);
    
    -- Cancel the booking
    airport_mgmt_pkg.cancel_booking(v_booking_id);
    
    -- Check seats after cancellation
    SELECT available_seats INTO v_seats_after
    FROM flights f
    INNER JOIN bookings b ON f.flight_id = b.flight_id
    WHERE b.booking_id = v_booking_id;
    
    DBMS_OUTPUT.PUT_LINE('Seats after cancellation: ' || v_seats_after);
    DBMS_OUTPUT.PUT_LINE('Seat was restored: ' || CASE WHEN v_seats_after = v_seats_before + 1 THEN 'YES' ELSE 'NO' END);
END;
/

-- Test cancelling already cancelled booking
-- Test 2: Try to Cancel Already Cancelled Booking --
BEGIN
    airport_mgmt_pkg.cancel_booking(1);
END;
/


-- ============================================================================
-- TEST PROCEDURE 4 - UPDATE FLIGHT DETAILS
-- ============================================================================


-- Test valid update
--- Test 1: Update Flight Schedule ---
BEGIN
    airport_mgmt_pkg.update_flight_details(
        p_flight_id => 1,
        p_new_departure_time => TIMESTAMP '2025-11-15 09:30:00',
        p_new_arrival_time => TIMESTAMP '2025-11-15 11:00:00'
    );
END;
/

-- Test invalid update (arrival before departure)
-- Test 2: Invalid Update - Arrival Before Departure (Should Fail) --
BEGIN
    airport_mgmt_pkg.update_flight_details(
        p_flight_id => 1,
        p_new_departure_time => TIMESTAMP '2025-11-15 10:00:00',
        p_new_arrival_time => TIMESTAMP '2025-11-15 09:00:00'  -- Before departure
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error caught as expected: ' || SQLERRM);
END;
/


-- ============================================================================
-- TEST PROCEDURE 5 - LIST FLIGHTS FROM AIRPORT
-- ============================================================================


BEGIN
    airport_mgmt_pkg.list_flights_from_airport(1);
END;
/

--- Test with Different Airport ---
BEGIN
    airport_mgmt_pkg.list_flights_from_airport(2);
END;
/


-- ============================================================================
-- TEST PROCEDURE 6 - PASSENGER FLIGHT SUMMARY
-- ============================================================================


BEGIN
    airport_mgmt_pkg.passenger_flight_summary();
END;
/


-- ============================================================================
-- TEST PROCEDURE 7 - SHOW UPCOMING FLIGHTS
-- ============================================================================


BEGIN
    airport_mgmt_pkg.show_upcoming_flights(1);
END;
/


-- ============================================================================
-- TEST PROCEDURE 8 - SHOW FLIGHT PASSENGERS
-- ============================================================================


BEGIN
    airport_mgmt_pkg.show_flight_passengers(1);
END;
/

-- Test with Flight that has No Passengers --
BEGIN
    airport_mgmt_pkg.show_flight_passengers(5);
END;
/


-- ============================================================================
-- TEST PROCEDURE 9 - GENERATE REVENUE REPORT
-- ============================================================================



BEGIN
    airport_mgmt_pkg.generate_revenue_report();
END;
/



-- Complete booking workflow
DECLARE
    v_passenger_id NUMBER := 3;
    v_flight_id NUMBER := 2;
    v_seat_no VARCHAR2(10) := '25C';
    v_booking_id NUMBER;
    v_seats_before NUMBER;
    v_seats_after NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('COMPLETE BOOKING WORKFLOW TEST');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Step 1: Check initial seat availability
    v_seats_before := airport_mgmt_pkg.get_available_seats(v_flight_id);
    DBMS_OUTPUT.PUT_LINE('Step 1: Initial seats available: ' || v_seats_before);
    
    -- Step 2: Check if specific seat is available
    IF airport_mgmt_pkg.is_seat_available(v_flight_id, v_seat_no) THEN
        DBMS_OUTPUT.PUT_LINE('Step 2: Seat ' || v_seat_no || ' is available');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Step 2: Seat ' || v_seat_no || ' is NOT available');
        RETURN;
    END IF;
    
    -- Step 3: Book the ticket
    DBMS_OUTPUT.PUT_LINE('Step 3: Booking ticket...');
    airport_mgmt_pkg.book_ticket(v_passenger_id, v_flight_id, v_seat_no, 'Credit Card');
    
    -- Step 4: Verify seat count decreased
    v_seats_after := airport_mgmt_pkg.get_available_seats(v_flight_id);
    DBMS_OUTPUT.PUT_LINE('Step 4: Seats after booking: ' || v_seats_after);
    DBMS_OUTPUT.PUT_LINE('Step 4: Seats decreased by: ' || (v_seats_before - v_seats_after));
    
    -- Step 5: Verify booking count increased
    DBMS_OUTPUT.PUT_LINE('Step 5: Total bookings on flight: ' || 
        airport_mgmt_pkg.get_booking_count(v_flight_id));
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('WORKFLOW TEST COMPLETE');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

--- Flight Statistics ---
SELECT f.flight_id,
       al.name AS airline,
       ap_dep.name || ' -> ' || ap_arr.name AS route,
       f.available_seats,
       COUNT(b.booking_id) AS confirmed_bookings,
       NVL(SUM(t.total_amount), 0) AS revenue
FROM flights f
INNER JOIN airlines al ON f.airline_id = al.airline_id
INNER JOIN airports ap_dep ON f.departure_airport = ap_dep.airport_id
INNER JOIN airports ap_arr ON f.arrival_airport = ap_arr.airport_id
LEFT JOIN bookings b ON f.flight_id = b.flight_id AND b.status = 'CONFIRMED'
LEFT JOIN tickets t ON b.booking_id = t.booking_id
GROUP BY f.flight_id, al.name, ap_dep.name, ap_arr.name, f.available_seats
ORDER BY f.flight_id;





-- ============================================================================
-- QUICK REFERENCE - INDIVIDUAL TEST COMMANDS
-- ============================================================================

-- To test individual components, use these commands:

-- TEST FUNCTIONS:
BEGIN
    DBMS_OUTPUT.PUT_LINE(airport_mgmt_pkg.get_available_seats(1));
    DBMS_OUTPUT.PUT_LINE(airport_mgmt_pkg.calculate_flight_duration(1));
    DBMS_OUTPUT.PUT_LINE(airport_mgmt_pkg.get_total_revenue(1));
    DBMS_OUTPUT.PUT_LINE(airport_mgmt_pkg.get_booking_count(1));
    IF airport_mgmt_pkg.is_seat_available(1, '10A') THEN
        DBMS_OUTPUT.PUT_LINE('Seat 10A is AVAILABLE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Seat 10A is NOT AVAILABLE');
    END IF;
END;
/

-- TEST PROCEDURES:
BEGIN
    airport_mgmt_pkg.add_flight(1, 1, 1, 2, TIMESTAMP '2025-12-15 10:00:00', TIMESTAMP '2025-12-15 12:00:00', 250.00);
    airport_mgmt_pkg.book_ticket(1, 1, '30A', 'Cash');
    airport_mgmt_pkg.cancel_booking(1);
    airport_mgmt_pkg.update_flight_details(1, TIMESTAMP '2025-11-20 09:00:00', TIMESTAMP '2025-11-20 11:00:00');
    airport_mgmt_pkg.list_flights_from_airport(1);
    airport_mgmt_pkg.passenger_flight_summary();
    airport_mgmt_pkg.show_upcoming_flights(1);
    airport_mgmt_pkg.show_flight_passengers(1);
    airport_mgmt_pkg.generate_revenue_report();
END;
/

