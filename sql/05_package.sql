CREATE OR REPLACE PACKAGE airport_mgmt_pkg AS
    -- Custom Exception Declarations
    e_no_seats_available EXCEPTION;
    e_invalid_flight EXCEPTION;
    e_invalid_booking EXCEPTION;
    e_invalid_airline EXCEPTION;
    e_invalid_airport EXCEPTION;
    
    -- Type Declarations
    TYPE flight_record IS RECORD (
        flight_id NUMBER,
        airline_name VARCHAR2(100),
        route VARCHAR2(200),
        departure_time TIMESTAMP,
        available_seats NUMBER,
        fare NUMBER
    );
    
    TYPE passenger_record IS RECORD (
        passenger_name VARCHAR2(100),
        seat_no VARCHAR2(10),
        booking_date DATE,
        ticket_amount NUMBER
    );

    TYPE revenue_record IS RECORD (
        airline_name VARCHAR2(100),
        total_flights NUMBER,
        total_bookings NUMBER,
        total_revenue NUMBER
    );
    
    -- Cursor Declarations
    CURSOR cur_upcoming_flights(p_airport_id NUMBER) RETURN flight_record;
    CURSOR cur_passengers_by_flight(p_flight_id NUMBER) RETURN passenger_record;
    
    -- Function Declarations
    FUNCTION get_available_seats(p_flight_id IN NUMBER) RETURN NUMBER;
    FUNCTION calculate_flight_duration(p_flight_id IN NUMBER) RETURN NUMBER;
    FUNCTION get_total_revenue(p_airline_id IN NUMBER) RETURN NUMBER;
    FUNCTION get_booking_count(p_flight_id IN NUMBER) RETURN NUMBER;
    FUNCTION is_seat_available(p_flight_id IN NUMBER, p_seat_no IN VARCHAR2) RETURN BOOLEAN;
    
    -- Procedure Declarations
    PROCEDURE add_flight(
        p_airline_id IN NUMBER,
        p_aircraft_id IN NUMBER,
        p_departure_airport IN NUMBER,
        p_arrival_airport IN NUMBER,
        p_departure_time IN TIMESTAMP,
        p_arrival_time IN TIMESTAMP,
        p_fare IN NUMBER
    );
    
    PROCEDURE book_ticket(
        p_passenger_id IN NUMBER,
        p_flight_id IN NUMBER,
        p_seat_no IN VARCHAR2,
        p_payment_mode IN VARCHAR2
    );
    
    PROCEDURE cancel_booking(p_booking_id IN NUMBER);
    
    PROCEDURE update_flight_details(
        p_flight_id IN NUMBER,
        p_new_departure_time IN TIMESTAMP,
        p_new_arrival_time IN TIMESTAMP
    );
    
    PROCEDURE list_flights_from_airport(p_airport_id IN NUMBER);
    PROCEDURE passenger_flight_summary;
    PROCEDURE show_upcoming_flights(p_airport_id IN NUMBER);
    PROCEDURE show_flight_passengers(p_flight_id IN NUMBER);
    PROCEDURE generate_revenue_report;
    
END airport_mgmt_pkg;
/


CREATE OR REPLACE PACKAGE BODY airport_mgmt_pkg AS

    -- ========================================================================
    -- CURSOR DEFINITIONS
    -- ========================================================================
    
    -- Cursor 1: Upcoming flights from specific airport
    CURSOR cur_upcoming_flights(p_airport_id NUMBER) RETURN flight_record IS
        SELECT f.flight_id,
               al.name AS airline_name,
               ap_dep.name || ' -> ' || ap_arr.name AS route,
               f.departure_time,
               f.available_seats,
               f.fare
        FROM flights f
        INNER JOIN airlines al ON f.airline_id = al.airline_id
        INNER JOIN airports ap_dep ON f.departure_airport = ap_dep.airport_id
        INNER JOIN airports ap_arr ON f.arrival_airport = ap_arr.airport_id
        WHERE f.departure_airport = p_airport_id
        AND f.departure_time > SYSTIMESTAMP
        ORDER BY f.departure_time;
    
    -- Cursor 2: Passengers for specific flight
    CURSOR cur_passengers_by_flight(p_flight_id NUMBER) RETURN passenger_record IS
        SELECT p.full_name AS passenger_name,
               b.seat_no,
               b.booking_date,
               t.total_amount AS ticket_amount
        FROM passengers p
        INNER JOIN bookings b ON p.passenger_id = b.passenger_id
        INNER JOIN tickets t ON b.booking_id = t.booking_id
        WHERE b.flight_id = p_flight_id
        AND b.status = 'CONFIRMED'
        ORDER BY b.seat_no;

    -- ========================================================================
    -- FUNCTION IMPLEMENTATIONS
    -- ========================================================================
    
    -- Function 1: Get Available Seats
    FUNCTION get_available_seats(p_flight_id IN NUMBER) RETURN NUMBER AS
        v_available_seats NUMBER;
    BEGIN
        SELECT available_seats 
        INTO v_available_seats
        FROM flights
        WHERE flight_id = p_flight_id;
        
        RETURN v_available_seats;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No flight found with ID ' || p_flight_id);
        RETURN -1; 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
        RETURN -2;
    END get_available_seats;
    
    -- Function 2: Calculate Flight Duration
    FUNCTION calculate_flight_duration(p_flight_id IN NUMBER) RETURN NUMBER AS
        v_duration NUMBER;
    BEGIN
        SELECT ROUND((EXTRACT(DAY FROM (arrival_time - departure_time)) * 24 + 
                      EXTRACT(HOUR FROM (arrival_time - departure_time)) + 
                      EXTRACT(MINUTE FROM (arrival_time - departure_time)) / 60), 2)
        INTO v_duration
        FROM flights
        WHERE flight_id = p_flight_id;
        
        RETURN v_duration;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No flight found with ID ' || p_flight_id);
        RETURN -1;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
        RETURN -2;
    END calculate_flight_duration;
    
    -- Function 3: Get Total Revenue by Airline
    FUNCTION get_total_revenue(p_airline_id IN NUMBER) RETURN NUMBER AS
        v_total_revenue NUMBER;
    BEGIN
        SELECT NVL(SUM(t.total_amount), 0)
        INTO v_total_revenue
        FROM tickets t
        INNER JOIN bookings b ON t.booking_id = b.booking_id
        INNER JOIN flights f ON b.flight_id = f.flight_id
        WHERE f.airline_id = p_airline_id
        AND b.status = 'CONFIRMED';
        
        RETURN v_total_revenue;
    EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error calculating revenue for airline ' || p_airline_id || ': ' || SQLERRM);
        RETURN 0;
    END get_total_revenue;
    
    -- Function 4: Get Booking Count for Flight
    FUNCTION get_booking_count(p_flight_id IN NUMBER) RETURN NUMBER AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM bookings
        WHERE flight_id = p_flight_id
        AND status = 'CONFIRMED';
        
        RETURN v_count;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END get_booking_count;
    
    -- Function 5: Check if Seat is Available
    FUNCTION is_seat_available(p_flight_id IN NUMBER, p_seat_no IN VARCHAR2) RETURN BOOLEAN AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM bookings
        WHERE flight_id = p_flight_id
        AND seat_no = p_seat_no
        AND status = 'CONFIRMED';
        
        RETURN (v_count = 0);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END is_seat_available;

    -- ========================================================================
    -- PROCEDURE IMPLEMENTATIONS
    -- ========================================================================
    
    -- Procedure 1: Add Flight
    PROCEDURE add_flight(
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
        v_new_flight_id NUMBER;
    BEGIN
        -- Validate airline exists
        SELECT COUNT(*) INTO v_airline_exists
        FROM airlines WHERE airline_id = p_airline_id;
        
        IF v_airline_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid airline ID: ' || p_airline_id);
        END IF;
        
        -- Validate airports exist
        SELECT COUNT(*) INTO v_departure_exists
        FROM airports WHERE airport_id = p_departure_airport;

        IF v_departure_exists = 0 OR v_arrival_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Invalid airport ID: '|| p_departure_airport);
        END IF;

        -- Validate arrival airport exists
        SELECT COUNT(*) INTO v_arrival_exists
        FROM airports WHERE airport_id = p_arrival_airport;
        
        IF v_arrival_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid arrival airport ID: ' || p_arrival_airport);
        END IF;

        -- Validate airports are different
        IF p_departure_airport = p_arrival_airport THEN
            RAISE_APPLICATION_ERROR(-20004, 'Departure and arrival airports must be different.');
        END IF;
        
        -- Validate time constraint
        IF p_arrival_time <= p_departure_time THEN
            RAISE_APPLICATION_ERROR(-20005, 'Arrival time must be after departure time.');
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
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('Flight added successfully!');
        DBMS_OUTPUT.PUT_LINE('Flight ID: ' || v_new_flight_id);
        DBMS_OUTPUT.PUT_LINE('Capacity: ' || v_aircraft_capacity || ' seats');
        DBMS_OUTPUT.PUT_LINE('========================================');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Aircraft ID ' || p_aircraft_id || ' not found.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error adding flight: ' || SQLERRM);
    END add_flight;

        -- Procedure 2: Book Ticket
    PROCEDURE book_ticket(
            p_passenger_id IN NUMBER,
            p_flight_id IN NUMBER,
            p_seat_no IN VARCHAR2,
            p_payment_mode IN VARCHAR2
    ) AS
            v_available_seats NUMBER;
            v_fare NUMBER;
            v_booking_id NUMBER;
            v_passenger_name VARCHAR2(100);
            v_route VARCHAR2(200);
        BEGIN
            -- Check available seats
            v_available_seats := get_available_seats(p_flight_id);
            
            IF v_available_seats <= 0 THEN
                RAISE e_no_seats_available;
            END IF;
            
            IF NOT is_seat_available(p_flight_id, p_seat_no) THEN
                RAISE_APPLICATION_ERROR(-20010, 'Seat ' || p_seat_no || ' is already booked.');
            END IF;
            
            -- Get fare
            -- Get flight fare and route info
        SELECT f.fare, 
               ap_dep.name || ' -> ' || ap_arr.name
        INTO v_fare, v_route
        FROM flights f
        INNER JOIN airports ap_dep ON f.departure_airport = ap_dep.airport_id
        INNER JOIN airports ap_arr ON f.arrival_airport = ap_arr.airport_id
        WHERE f.flight_id = p_flight_id;

        -- Get passenger name
        SELECT full_name INTO v_passenger_name
        FROM passengers WHERE passenger_id = p_passenger_id;
            
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
            
        -- Success message
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('BOOKING SUCCESSFUL!');
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('Booking ID: ' || v_booking_id);
        DBMS_OUTPUT.PUT_LINE('Passenger: ' || v_passenger_name);
        DBMS_OUTPUT.PUT_LINE('Flight: ' || p_flight_id);
        DBMS_OUTPUT.PUT_LINE('Route: ' || v_route);
        DBMS_OUTPUT.PUT_LINE('Seat: ' || p_seat_no);
        DBMS_OUTPUT.PUT_LINE('Fare: $' || v_fare);
        DBMS_OUTPUT.PUT_LINE('Payment: ' || p_payment_mode);
        DBMS_OUTPUT.PUT_LINE('Remaining Seats: ' || (v_available_seats - 1));
        DBMS_OUTPUT.PUT_LINE('========================================');

        EXCEPTION
            WHEN e_no_seats_available THEN
                DBMS_OUTPUT.PUT_LINE('Error: No seats available on flight ID ' || p_flight_id);
            WHEN NO_DATA_FOUND THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Error: Invalid passenger ID or flight ID.');
            WHEN OTHERS THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Error booking ticket: ' || SQLERRM);
        END book_ticket;
        
        -- Procedure 3: Cancel Booking
        PROCEDURE cancel_booking(p_booking_id IN NUMBER) AS
            v_flight_id NUMBER;
            v_current_status VARCHAR2(20);
            v_passenger_name VARCHAR2(100);
            v_seat_no VARCHAR2(10);
        BEGIN
            -- Get booking details
            -- Get booking details
            SELECT b.flight_id, b.status, p.full_name, b.seat_no
            INTO v_flight_id, v_current_status, v_passenger_name, v_seat_no
            FROM bookings b
            INNER JOIN passengers p ON b.passenger_id = p.passenger_id
            WHERE b.booking_id = p_booking_id;

            IF v_current_status = 'CANCELLED' THEN
                DBMS_OUTPUT.PUT_LINE('Booking ID ' || p_booking_id || ' is already cancelled.');
                RETURN;
            END IF;

            -- Update booking status
            UPDATE bookings SET status = 'CANCELLED' WHERE booking_id = p_booking_id;

            -- Update available seats
            UPDATE flights SET available_seats = available_seats + 1
            WHERE flight_id = v_flight_id;

            COMMIT;
            -- Success message
            DBMS_OUTPUT.PUT_LINE('========================================');
            DBMS_OUTPUT.PUT_LINE('BOOKING CANCELLED SUCCESSFULLY');
            DBMS_OUTPUT.PUT_LINE('========================================');
            DBMS_OUTPUT.PUT_LINE('Booking ID: ' || p_booking_id);
            DBMS_OUTPUT.PUT_LINE('Passenger: ' || v_passenger_name);
            DBMS_OUTPUT.PUT_LINE('Flight ID: ' || v_flight_id);
            DBMS_OUTPUT.PUT_LINE('Seat ' || v_seat_no || ' has been released.');
            DBMS_OUTPUT.PUT_LINE('========================================');
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Error: Booking ID ' || p_booking_id || ' not found.');
            WHEN OTHERS THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Error cancelling booking: ' || SQLERRM);
        END cancel_booking;
        
        -- Procedure 4: Update Flight Details
    PROCEDURE update_flight_details(
        p_flight_id IN NUMBER,
        p_new_departure_time IN TIMESTAMP,
        p_new_arrival_time IN TIMESTAMP
    ) AS
        v_flight_exists NUMBER;
        v_old_departure TIMESTAMP;
        v_old_arrival TIMESTAMP;
        v_route VARCHAR2(200);
    BEGIN
        -- Get existing flight details
        SELECT departure_time, arrival_time,
               ap_dep.name || ' -> ' || ap_arr.name
        INTO v_old_departure, v_old_arrival, v_route
        FROM flights f
        INNER JOIN airports ap_dep ON f.departure_airport = ap_dep.airport_id
        INNER JOIN airports ap_arr ON f.arrival_airport = ap_arr.airport_id
        WHERE f.flight_id = p_flight_id;

        -- Validate time constraint
        IF p_new_arrival_time <= p_new_departure_time THEN
            RAISE_APPLICATION_ERROR(-20030, 'Arrival time must be after departure time.');
        END IF;

        -- Update flight schedule
        UPDATE flights 
        SET departure_time = p_new_departure_time, 
            arrival_time = p_new_arrival_time 
        WHERE flight_id = p_flight_id;

        COMMIT;
        
        -- Success message
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('FLIGHT SCHEDULE UPDATED');
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('Flight ID: ' || p_flight_id);
        DBMS_OUTPUT.PUT_LINE('Route: ' || v_route);
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('OLD Schedule:');
        DBMS_OUTPUT.PUT_LINE('  Departure: ' || TO_CHAR(v_old_departure, 'DD-MON-YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('  Arrival: ' || TO_CHAR(v_old_arrival, 'DD-MON-YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('NEW Schedule:');
        DBMS_OUTPUT.PUT_LINE('  Departure: ' || TO_CHAR(p_new_departure_time, 'DD-MON-YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('  Arrival: ' || TO_CHAR(p_new_arrival_time, 'DD-MON-YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('========================================');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Flight ID ' || p_flight_id || ' does not exist.');
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error updating flight: ' || SQLERRM);
    END update_flight_details;

        
        -- Procedure 5: List Flights from Airport
        PROCEDURE list_flights_from_airport(p_airport_id IN NUMBER) AS
        CURSOR flight_cursor IS
            SELECT f.flight_id, 
                   al.name AS airline, 
                   ap_dep.name AS departure_airport,
                   ap_arr.name AS arrival_airport,
                   f.departure_time, 
                   f.arrival_time,
                   f.available_seats,
                   f.fare
            FROM flights f
            INNER JOIN airlines al ON f.airline_id = al.airline_id
            INNER JOIN airports ap_dep ON f.departure_airport = ap_dep.airport_id
            INNER JOIN airports ap_arr ON f.arrival_airport = ap_arr.airport_id
            WHERE f.departure_airport = p_airport_id
            AND f.departure_time > SYSTIMESTAMP
            ORDER BY f.departure_time;
        
        v_flight flight_cursor%ROWTYPE;
        v_count NUMBER := 0;
        v_airport_name VARCHAR2(100);
        BEGIN
        -- Get airport name
        BEGIN
            SELECT name INTO v_airport_name
            FROM airports WHERE airport_id = p_airport_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Error: Airport ID ' || p_airport_id || ' not found.');
                RETURN;
        END;
        
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('UPCOMING FLIGHTS FROM: ' || v_airport_name);
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('');
        
        OPEN flight_cursor;
        LOOP
            FETCH flight_cursor INTO v_flight;
            EXIT WHEN flight_cursor%NOTFOUND;
            
            v_count := v_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('Flight #' || v_flight.flight_id);
            DBMS_OUTPUT.PUT_LINE('  Airline: ' || v_flight.airline);
            DBMS_OUTPUT.PUT_LINE('  Route: ' || v_flight.departure_airport || ' -> ' || v_flight.arrival_airport);
            DBMS_OUTPUT.PUT_LINE('  Departure: ' || TO_CHAR(v_flight.departure_time, 'DD-MON-YYYY HH24:MI'));
            DBMS_OUTPUT.PUT_LINE('  Arrival: ' || TO_CHAR(v_flight.arrival_time, 'DD-MON-YYYY HH24:MI'));
            DBMS_OUTPUT.PUT_LINE('  Available Seats: ' || v_flight.available_seats);
            DBMS_OUTPUT.PUT_LINE('  Fare: $' || v_flight.fare);
            DBMS_OUTPUT.PUT_LINE('  ----------------------------------------');
        END LOOP;
        CLOSE flight_cursor;
        
        IF v_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No upcoming flights found from this airport.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('Total Flights Found: ' || v_count);
        END IF;
        DBMS_OUTPUT.PUT_LINE('========================================');
        EXCEPTION
        WHEN OTHERS THEN
            IF flight_cursor%ISOPEN THEN
                CLOSE flight_cursor;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Error listing flights: ' || SQLERRM);
        END list_flights_from_airport;
        
        -- Procedure 6: Passenger Flight Summary
         PROCEDURE passenger_flight_summary AS
        v_grand_total_bookings NUMBER := 0;
        v_grand_total_revenue NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('  PASSENGER BOOKING SUMMARY BY FLIGHT  ');
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('');
        
        FOR flight_rec IN (
            SELECT f.flight_id, 
                   al.name AS airline,
                   ap_dep.name || ' -> ' || ap_arr.name AS route,
                   f.departure_time,
                   COUNT(b.booking_id) AS total_bookings,
                   NVL(SUM(t.total_amount), 0) AS total_revenue,
                   f.available_seats,
                   ac.capacity
            FROM flights f
            INNER JOIN airlines al ON f.airline_id = al.airline_id
            INNER JOIN aircrafts ac ON f.aircraft_id = ac.aircraft_id
            INNER JOIN airports ap_dep ON f.departure_airport = ap_dep.airport_id
            INNER JOIN airports ap_arr ON f.arrival_airport = ap_arr.airport_id
            LEFT JOIN bookings b ON f.flight_id = b.flight_id AND b.status = 'CONFIRMED'
            LEFT JOIN tickets t ON b.booking_id = t.booking_id
            GROUP BY f.flight_id, al.name, ap_dep.name, ap_arr.name, 
                     f.departure_time, f.available_seats, ac.capacity
            ORDER BY f.flight_id
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Flight ID: ' || flight_rec.flight_id);
            DBMS_OUTPUT.PUT_LINE('  Airline: ' || flight_rec.airline);
            DBMS_OUTPUT.PUT_LINE('  Route: ' || flight_rec.route);
            DBMS_OUTPUT.PUT_LINE('  Departure: ' || TO_CHAR(flight_rec.departure_time, 'DD-MON-YYYY HH24:MI'));
            DBMS_OUTPUT.PUT_LINE('  Total Bookings: ' || flight_rec.total_bookings);
            DBMS_OUTPUT.PUT_LINE('  Revenue: $' || TO_CHAR(flight_rec.total_revenue, '999,999.99'));
            DBMS_OUTPUT.PUT_LINE('  Capacity: ' || flight_rec.capacity || ' seats');
            DBMS_OUTPUT.PUT_LINE('  Occupied: ' || (flight_rec.capacity - flight_rec.available_seats) || ' seats');
            DBMS_OUTPUT.PUT_LINE('  Available: ' || flight_rec.available_seats || ' seats');
            DBMS_OUTPUT.PUT_LINE('  Occupancy Rate: ' || 
                ROUND((flight_rec.capacity - flight_rec.available_seats) / flight_rec.capacity * 100, 2) || '%');
            DBMS_OUTPUT.PUT_LINE('  ----------------------------------------');
            
            v_grand_total_bookings := v_grand_total_bookings + flight_rec.total_bookings;
            v_grand_total_revenue := v_grand_total_revenue + flight_rec.total_revenue;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('GRAND TOTALS:');
        DBMS_OUTPUT.PUT_LINE('  Total Bookings: ' || v_grand_total_bookings);
        DBMS_OUTPUT.PUT_LINE('  Total Revenue: $' || TO_CHAR(v_grand_total_revenue, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('========================================');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error generating summary: ' || SQLERRM);
    END passenger_flight_summary;
        
        --Procedure 7: Show Upcoming Flights
        PROCEDURE show_upcoming_flights(p_airport_id IN NUMBER) AS
        v_flight flight_record;
        v_count NUMBER := 0;
        v_airport_name VARCHAR2(100);
    BEGIN
        -- Get airport name
        BEGIN
            SELECT name INTO v_airport_name
            FROM airports WHERE airport_id = p_airport_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Error: Airport ID ' || p_airport_id || ' not found.');
                RETURN;
        END;
        
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('UPCOMING FLIGHTS - ' || v_airport_name);
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('');
        
        OPEN cur_upcoming_flights(p_airport_id);
        LOOP
            FETCH cur_upcoming_flights INTO v_flight;
            EXIT WHEN cur_upcoming_flights%NOTFOUND;
            
            v_count := v_count + 1;
            
            DBMS_OUTPUT.PUT_LINE('Flight #' || v_flight.flight_id || ' - ' || v_flight.airline_name);
            DBMS_OUTPUT.PUT_LINE('  Route: ' || v_flight.route);
            DBMS_OUTPUT.PUT_LINE('  Departs: ' || TO_CHAR(v_flight.departure_time, 'DD-MON-YYYY HH24:MI'));
            DBMS_OUTPUT.PUT_LINE('  Fare: $' || v_flight.fare || ' | Available: ' || v_flight.available_seats || ' seats');
            DBMS_OUTPUT.PUT_LINE('  ----------------------------------------');
        END LOOP;
        CLOSE cur_upcoming_flights;
        
        IF v_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No upcoming flights available from this airport.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('Total Flights: ' || v_count);
        END IF;
        DBMS_OUTPUT.PUT_LINE('========================================');
    EXCEPTION
        WHEN OTHERS THEN
            IF cur_upcoming_flights%ISOPEN THEN
                CLOSE cur_upcoming_flights;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Error showing flights: ' || SQLERRM);
    END show_upcoming_flights;
        
        --Procedure 8: Show Flight Passengers
        PROCEDURE show_flight_passengers(p_flight_id IN NUMBER) AS
        v_passenger passenger_record;
        v_count NUMBER := 0;
        v_total_revenue NUMBER := 0;
        v_route VARCHAR2(200);
        v_airline VARCHAR2(100);
        v_departure_time TIMESTAMP;
    BEGIN
        -- Get flight details
        BEGIN
            SELECT al.name, 
                   ap_dep.name || ' -> ' || ap_arr.name,
                   f.departure_time
            INTO v_airline, v_route, v_departure_time
            FROM flights f
            INNER JOIN airlines al ON f.airline_id = al.airline_id
            INNER JOIN airports ap_dep ON f.departure_airport = ap_dep.airport_id
            INNER JOIN airports ap_arr ON f.arrival_airport = ap_arr.airport_id
            WHERE f.flight_id = p_flight_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Error: Flight ID ' || p_flight_id || ' not found.');
                RETURN;
        END;
        
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('   PASSENGER MANIFEST - FLIGHT #' || p_flight_id);
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('Airline: ' || v_airline);
        DBMS_OUTPUT.PUT_LINE('Route: ' || v_route);
        DBMS_OUTPUT.PUT_LINE('Departure: ' || TO_CHAR(v_departure_time, 'DD-MON-YYYY HH24:MI'));
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('');
        
        FOR v_passenger IN cur_passengers_by_flight(p_flight_id) LOOP
            v_count := v_count + 1;
            v_total_revenue := v_total_revenue + v_passenger.ticket_amount;
            
            DBMS_OUTPUT.PUT_LINE(v_count || '. ' || v_passenger.passenger_name);
            DBMS_OUTPUT.PUT_LINE('   Seat: ' || v_passenger.seat_no);
            DBMS_OUTPUT.PUT_LINE('   Booked: ' || TO_CHAR(v_passenger.booking_date, 'DD-MON-YYYY'));
            DBMS_OUTPUT.PUT_LINE('   Paid:  ' || TO_CHAR(v_passenger.ticket_amount, '999,999.99'));
            DBMS_OUTPUT.PUT_LINE('   ---');
        END LOOP;
        
        IF v_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No confirmed passengers for this flight.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('========================================');
            DBMS_OUTPUT.PUT_LINE('SUMMARY:');
            DBMS_OUTPUT.PUT_LINE('  Total Passengers: ' || v_count);
            DBMS_OUTPUT.PUT_LINE('  Total Revenue: ' || TO_CHAR(v_total_revenue, '999,999.99'));
            DBMS_OUTPUT.PUT_LINE('========================================');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error showing passengers: ' || SQLERRM);
    END show_flight_passengers;
        
--Procedure 9: Generate Revenue Report
    PROCEDURE generate_revenue_report AS
        CURSOR revenue_cursor IS
            SELECT al.name AS airline_name,
                   COUNT(DISTINCT f.flight_id) AS total_flights,
                   COUNT(b.booking_id) AS total_bookings,
                   NVL(SUM(t.total_amount), 0) AS total_revenue,
                   NVL(AVG(t.total_amount), 0) AS avg_ticket_price
            FROM airlines al
            LEFT JOIN flights f ON al.airline_id = f.airline_id
            LEFT JOIN bookings b ON f.flight_id = b.flight_id AND b.status = 'CONFIRMED'
            LEFT JOIN tickets t ON b.booking_id = t.booking_id
            GROUP BY al.name
            ORDER BY total_revenue DESC;
        
        v_revenue revenue_cursor%ROWTYPE;
        v_total_revenue NUMBER := 0;
        v_total_bookings NUMBER := 0;
        v_count NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('      AIRLINE REVENUE REPORT           ');
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('Generated: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('');
        
        OPEN revenue_cursor;
        LOOP
            FETCH revenue_cursor INTO v_revenue;
            EXIT WHEN revenue_cursor%NOTFOUND;
            
            v_count := v_count + 1;
            v_total_revenue := v_total_revenue + v_revenue.total_revenue;
            v_total_bookings := v_total_bookings + v_revenue.total_bookings;
            
            DBMS_OUTPUT.PUT_LINE('Airline: ' || v_revenue.airline_name);
            DBMS_OUTPUT.PUT_LINE('  Total Flights: ' || v_revenue.total_flights);
            DBMS_OUTPUT.PUT_LINE('  Total Bookings: ' || v_revenue.total_bookings);
            DBMS_OUTPUT.PUT_LINE('  Total Revenue: ' || TO_CHAR(v_revenue.total_revenue, '999,999,999.99'));
            DBMS_OUTPUT.PUT_LINE('  Avg Ticket Price: ' || TO_CHAR(v_revenue.avg_ticket_price, '999,999.99'));
            
            -- Calculate market share
            IF v_total_revenue > 0 THEN
                DBMS_OUTPUT.PUT_LINE('  Market Share: ' || 
                    ROUND((v_revenue.total_revenue / v_total_revenue) * 100, 2) || '%');
            END IF;
            
            DBMS_OUTPUT.PUT_LINE('  ----------------------------------------');
        END LOOP;
        CLOSE revenue_cursor;
        
        -- Grand totals
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('INDUSTRY TOTALS:');
        DBMS_OUTPUT.PUT_LINE('  Total Airlines: ' || v_count);
        DBMS_OUTPUT.PUT_LINE('  Total Bookings: ' || v_total_bookings);
        DBMS_OUTPUT.PUT_LINE('  Total Revenue: ' || TO_CHAR(v_total_revenue, '999,999,999.99'));
        IF v_total_bookings > 0 THEN
            DBMS_OUTPUT.PUT_LINE('  Average Revenue per Booking: ' || 
                TO_CHAR(v_total_revenue / v_total_bookings, '999,999.99'));
        END IF;
        DBMS_OUTPUT.PUT_LINE('========================================');
    EXCEPTION
        WHEN OTHERS THEN
            IF revenue_cursor%ISOPEN THEN
                CLOSE revenue_cursor;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Error generating report: ' || SQLERRM);
    END generate_revenue_report;
    
    END airport_mgmt_pkg;
    /
    
