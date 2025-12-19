# 📊 Business Intelligence Requirements

## Airport & Airline Management System (PL/SQL)


## 1. Introduction

The Airport and Airline Management System generates large volumes of transactional data related to **bookings, passengers, flights, tickets, and revenue**.
The Business Intelligence (BI) component transforms this operational data into **actionable insights** that support **strategic, tactical, and operational decision-making** for airport authorities and airline management.

The BI solution uses **Oracle Database with PL/SQL** as the primary data source and supports **analytical queries, and management reports**.

---

## 2. Business Objectives

The BI system aims to:

- Monitor **daily passenger traffic and booking volumes**
- Analyze **revenue performance by route and country**
- Identify **booking and cancellation trends**

---

## 3. Key actors

| Stakeholder     | BI Requirements                           |
| --------------- | ----------------------------------------- |
| Airport Manager | Passenger flow analysis, peak travel days |
| Airline Manager | Route profitability, pricing insights     |
| Finance Team    | Revenue tracking, ticket value analysis   |
| Agent Team      | Booking and cancellation trends           |

---

## 4. Business Intelligence Functional Requirements

### 🔹 Requirement 1: Daily Passenger Traffic Analysis

**Business Question:**
How many passengers and bookings occur each day?

**Metrics:**
- Travel Date
- Total Passengers
- Total Confirmed Bookings

**Business Value:**
- Identifies peak travel days
- Improves airport staffing and capacity planning

**Analytical Query:**

```sql
SELECT 
    TRUNC(f.departure_time) AS travel_date,
    COUNT(DISTINCT b.passenger_id) AS total_passengers,
    COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN flights f ON b.flight_id = f.flight_id
WHERE b.status = 'CONFIRMED'
GROUP BY TRUNC(f.departure_time)
ORDER BY travel_date DESC;
```


### 🔹 Requirement 2: Revenue per Route Analysis

**Business Question:**

Which flight routes generate the highest revenue?

**Metrics:**
* Total Revenue
* Total Bookings
* Average Ticket Price
* Minimum and Maximum Ticket Price

**Dimensions:**
* Departure Airport
* Arrival Airport
* Departure Country
* Arrival Country

**Business Value:**
* Identifies profitable routes
* Supports pricing and route planning decisions

**Analytical Query:**

```sql
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
```


### 🔹 Requirement 3: Booking Trends & Cancellation Analysis

**Business Question:**
What are the booking and cancellation patterns over time?

Metrics:
* Total Bookings
* Confirmed Bookings
* Cancelled Bookings
* Cancellation Rate (%)
* Total Revenue
* Average Booking Value

**Business Value:**
* Detects seasonal trends
* Helps reduce cancellations
* Improves marketing and promotions

**Analytical Query:**

```sql
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
```

---

 ## 5. Key Performance Indicators (KPIs)

| KPI                   | Description               |
| --------------------- | ------------------------- |
| Daily Passenger Count | Total passengers per day  |
| Booking Volume        | Total confirmed bookings  |
| Route Revenue         | Revenue per airport route |
| Cancellation Rate     | % of cancelled bookings   |
| Average Ticket Price  | Mean ticket value         |
| Peak Booking Days     | High-demand days          |



