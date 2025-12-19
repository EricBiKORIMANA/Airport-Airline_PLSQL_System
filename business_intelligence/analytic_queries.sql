-- 1. DAILY PASSENGER TRAFFIC
-- Shows the number of passengers traveling each day
SELECT 
    TRUNC(f.departure_time) AS travel_date,
    COUNT(DISTINCT b.passenger_id) AS total_passengers,
    COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN flights f ON b.flight_id = f.flight_id
WHERE b.status = 'CONFIRMED'
GROUP BY TRUNC(f.departure_time)
ORDER BY travel_date DESC;


-- 2. REVENUE PER ROUTE
-- Calculates total revenue for each flight route
SELECT 
    dep.name AS departure_airport,
    arr.name AS arrival_airport,
    dep.country AS dep_country,
    arr.country AS arr_country,
    COUNT(b.booking_id) AS total_bookings,
    SUM(t.total_amount) AS total_revenue,
    AVG(t.total_amount) AS avg_ticket_price,
    MIN(t.total_amount) AS min_price,
    MAX(t.total_amount) AS max_price
FROM bookings b
JOIN tickets t ON b.booking_id = t.booking_id
JOIN flights f ON b.flight_id = f.flight_id
JOIN airports dep ON f.departure_airport = dep.airport_id
JOIN airports arr ON f.arrival_airport = arr.airport_id
WHERE b.status = 'CONFIRMED'
GROUP BY dep.name, arr.name, dep.country, arr.country
ORDER BY total_revenue DESC;

-- 3. BOOKING TRENDS ANALYSIS
-- Analyzes booking patterns by day of week and month
SELECT 
    TO_CHAR(b.booking_date, 'Day') AS day_of_week,
    TO_CHAR(b.booking_date, 'Month') AS month_name,
    EXTRACT(MONTH FROM b.booking_date) AS month_number,
    COUNT(b.booking_id) AS total_bookings,
    SUM(CASE WHEN b.status = 'CONFIRMED' THEN 1 ELSE 0 END) AS confirmed_bookings,
    SUM(CASE WHEN b.status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_bookings,
    ROUND(SUM(CASE WHEN b.status = 'CANCELLED' THEN 1 ELSE 0 END) / COUNT(b.booking_id) * 100, 2) AS cancellation_rate,
    SUM(t.total_amount) AS total_revenue,
    ROUND(AVG(t.total_amount), 2) AS avg_booking_value
FROM bookings b
LEFT JOIN tickets t ON b.booking_id = t.booking_id
WHERE b.booking_date >= ADD_MONTHS(SYSDATE, -6)  -- Last 6 months
GROUP BY TO_CHAR(b.booking_date, 'Day'), TO_CHAR(b.booking_date, 'Month'), EXTRACT(MONTH FROM b.booking_date)
ORDER BY month_number, day_of_week;

