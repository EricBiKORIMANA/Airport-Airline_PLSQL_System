CREATE OR REPLACE FUNCTION get_available_seats(p_flight_id IN NUMBER)
RETURN NUMBER
AS
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
/

-- Function 2: Calculate Flight Duration
CREATE OR REPLACE FUNCTION calculate_flight_duration(p_flight_id IN NUMBER)
RETURN NUMBER
AS
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
/

-- Function 3: Get Total Revenue by Airline
CREATE OR REPLACE FUNCTION get_total_revenue(p_airline_id IN NUMBER)
RETURN NUMBER
AS
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
/

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
    
    -- Function 5: Check Seat Availability
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
