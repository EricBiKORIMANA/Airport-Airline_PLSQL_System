# ✈️ Airport and Airline Management System – Data Dictionary

## Airports

| Attribute    | Data Type | Key | Description               |
| ------------ | --------- | --- | ------------------------- |
| airport_id   | NUMBER    | PK  | Unique airport identifier |
| airport_name | VARCHAR   |     | Name of the airport       |
| location     | VARCHAR   |     | City or region            |
| country      | VARCHAR   |     | Country of the airport    |

## Airlines

| Attribute    | Data Type | Key | Description                   |
| ------------ | --------- | --- | ----------------------------- |
| airline_id   | NUMBER    | PK  | Unique airline identifier     |
| airline_name | VARCHAR   |     | Name of the airline           |
| headquarter  | VARCHAR   |     | Airline headquarters location |

## Aircrafts

| Attribute   | Data Type | Key | Description                |
| ----------- | --------- | --- | -------------------------- |
| aircraft_id | NUMBER    | PK  | Unique aircraft identifier |
| model       | VARCHAR   |     | Aircraft model             |
| capacity    | VARCHAR   |     | Seating capacity           |
| airline_id  | NUMBER    | FK  | References Airlines        |

## Flights

| Attribute         | Data Type | Key | Description              |
| ----------------- | --------- | --- | ------------------------ |
| flight_id         | NUMBER    | PK  | Unique flight identifier |
| airline_id        | NUMBER    | FK  | References Airlines      |
| aircraft_id       | NUMBER    | FK  | References Aircrafts     |
| departure_airport | VARCHAR   | FK  | References Airports      |
| arrival_airport   | VARCHAR   | FK  | References Airports      |
| departure_time    | TIMESTAMP |     | Scheduled departure time |
| arrival_time      | TIMESTAMP |     | Scheduled arrival time   |
| fare              | NUMBER    |     | Ticket fare              |
| available_seats   | NUMBER    |     | Remaining seats          |

## Booking

| Attribute    | Data Type | Key | Description                      |
| ------------ | --------- | --- | -------------------------------- |
| booking_id   | NUMBER    | PK  | Unique booking identifier        |
| passenger_id | NUMBER    | FK  | References Passenger             |
| flight_id    | NUMBER    | FK  | References Flights               |
| seat_no      | VARCHAR   |     | Assigned seat number             |
| booking_date | DATE      |     | Date of booking                  |
| status       | VARCHAR   |     | Booking status (e.g., confirmed) |

## Tickets

| Attribute    | Data Type | Key | Description              |
| ------------ | --------- | --- | ------------------------ |
| ticket_id    | NUMBER    | PK  | Unique ticket identifier |
| booking_id   | NUMBER    | FK  | References Booking       |
| issue_date   | DATE      |     | Date ticket was issued   |
| payment_mode | VARCHAR   |     | Payment method used      |
| total_amount | NUMBER    |     | Total fare amount        |

## Passenger

| Attribute    | Data Type | Key | Description                 |
| ------------ | --------- | --- | --------------------------- |
| passenger_id | NUMBER    | PK  | Unique passenger identifier |
| full_name    | VARCHAR   |     | Passenger's full name       |
| passport     | VARCHAR   |     | Passport number             |
| nationality  | VARCHAR   |     | Country of citizenship      |
| contact      | VARCHAR   |     | Contact info (phone/email)  |

## Flight Audit Log

| Attribute          | Data Type | Key | Description                 |
| ------------------ | --------- | --- | --------------------------- |
| log_id             | NUMBER    | PK  | Unique audit log identifier |
| flight_id          | NUMBER    | FK  | References Flights          |
| old_departure_time | TIMESTAMP |     | Original departure time     |
| new_departure_time | TIMESTAMP |     | Updated departure time      |
| old_arrival_time   | TIMESTAMP |     | Original arrival time       |
| new_arrival_time   | TIMESTAMP |     | Updated arrival time        |
| modified_date      | TIMESTAMP |     | Date of modification        |
| modified_by        | VARCHAR   |     | Modifier username           |

## Audit Log

| Attribute    | Data Type | Key | Description                       |
| ------------ | --------- | --- | --------------------------------- |
| audit_id     | NUMBER    | PK  | Unique audit entry                |
| audit_user   | VARCHAR   |     | User who performed the action     |
| audit_action | VARCHAR   |     | Type of action (INSERT, UPDATE…) |
| audit_table  | VARCHAR   |     | Table affected                    |
| audit_row_id | VARCHAR   |     | Row identifier affected           |
| audit_time   | TIMESTAMP |     | Time of audit event               |
| details      | VARCHAR   |     | Additional audit details          |

## Employees

| Attribute | Data Type | Key | Description          |
| --------- | --------- | --- | -------------------- |
| emp_id    | NUMBER    | PK  | Unique employee ID   |
| username  | VARCHAR   |     | Login username       |
| full_name | VARCHAR   |     | Employee's full name |
| role      | VARCHAR   |     | Job role or title    |

## Holidays

| Attribute    | Data Type | Key | Description               |
| ------------ | --------- | --- | ------------------------- |
| holiday_id   | NUMBER    | PK  | Unique holiday identifier |
| holiday_name | VARCHAR   |     | Name of the holiday       |
| holiday_date | DATE      |     | Date of the holiday       |
| description  | VARCHAR   |     | Description or notes      |
| is_active    | CHAR      |     | Status flag (Y/N)         |


## Procedures Documentation

### 1. ADD_FLIGHT Procedure

**Package:** airport_mgmt_pkg

**Purpose:** Creates a new flight with validation

**Parameters:**

| Parameter           | Type      | Mode | Description                         |
| ------------------- | --------- | ---- | ----------------------------------- |
| p_airline_id        | NUMBER    | IN   | Foreign key to airlines table       |
| p_aircraft_id       | NUMBER    | IN   | Foreign key to aircrafts table      |
| p_departure_airport | NUMBER    | IN   | Foreign key to airports (departure) |
| p_arrival_airport   | NUMBER    | IN   | Foreign key to airports (arrival)   |
| p_departure_time    | TIMESTAMP | IN   | Scheduled departure time            |
| p_arrival_time      | TIMESTAMP | IN   | Scheduled arrival time              |
| p_fare              | NUMBER    | IN   | Flight ticket price                 |

**Logic:**

1. Validates airline exists
2. Validates both airports exist
3. Validates airports are different
4. Validates arrival time > departure time
5. Retrieves aircraft capacity
6. Inserts flight with full capacity as available seats
7. Returns new flight_id

**Example Usage:**

```sql
BEGIN
    airport_mgmt_pkg.add_flight(
        p_airline_id => 1,
        p_aircraft_id => 1,
        p_departure_airport => 1,
        p_arrival_airport => 2,
        p_departure_time => TIMESTAMP '2025-12-20 08:00:00',
        p_arrival_time => TIMESTAMP '2025-12-20 09:30:00',
        p_fare => 250.00
    );
END;
```

---

### 2. BOOK_TICKET Procedure

**Package:** airport_mgmt_pkg

**Purpose:** Complete booking workflow with ticket generation

**Parameters:**

| Parameter      | Type     | Mode | Description                   |
| -------------- | -------- | ---- | ----------------------------- |
| p_passenger_id | NUMBER   | IN   | Foreign key to passengers     |
| p_flight_id    | NUMBER   | IN   | Foreign key to flights        |
| p_seat_no      | VARCHAR2 | IN   | Seat assignment (e.g., '12A') |
| p_payment_mode | VARCHAR2 | IN   | Payment method                |

**Logic:**

1. Checks available seats using function
2. Validates seat is not already booked
3. Retrieves flight fare
4. Inserts booking record (status: CONFIRMED)
5. Inserts ticket record with payment details
6. Decrements available_seats in flights table
7. Commits transaction

**Business Rules:**

* Seat must be available
* Duplicate seats prevented by UNIQUE constraint
* Triggers automatically log to audit_log

**Example Usage:**

```sql
BEGIN
    airport_mgmt_pkg.book_ticket(
        p_passenger_id => 1,
        p_flight_id => 1,
        p_seat_no => '15A',
        p_payment_mode => 'Credit Card'
    );
END;
```

---

### 3. CANCEL_BOOKING Procedure

**Package:** airport_mgmt_pkg

**Purpose:** Cancels booking and restores seat availability

**Parameters:**

| Parameter    | Type   | Mode | Description       |
| ------------ | ------ | ---- | ----------------- |
| p_booking_id | NUMBER | IN   | Booking to cancel |

**Logic:**

1. Retrieves booking details (flight_id, status)
2. Checks if already cancelled (returns if yes)
3. Updates booking status to 'CANCELLED'
4. Increments available_seats in flights table
5. Commits transaction

**Example Usage:**

```sql
BEGIN
    airport_mgmt_pkg.cancel_booking(1);
END;
```

---

### 4. UPDATE_FLIGHT_DETAILS Procedure

**Package:** airport_mgmt_pkg

**Purpose:** Modifies flight schedule

**Parameters:**

| Parameter            | Type      | Mode | Description        |
| -------------------- | --------- | ---- | ------------------ |
| p_flight_id          | NUMBER    | IN   | Flight to update   |
| p_new_departure_time | TIMESTAMP | IN   | New departure time |
| p_new_arrival_time   | TIMESTAMP | IN   | New arrival time   |

**Logic:**

1. Validates flight exists
2. Checks arrival time > departure time
3. Updates flight schedule
4. Trigger automatically logs changes to flight_audit_log

**Example Usage:**

```sql
BEGIN
    airport_mgmt_pkg.update_flight_details(
        p_flight_id => 1,
        p_new_departure_time => TIMESTAMP '2025-12-20 09:00:00',
        p_new_arrival_time => TIMESTAMP '2025-12-20 10:30:00'
    );
END;
```

---

### 5. LIST_FLIGHTS_FROM_AIRPORT Procedure

**Package:** airport_mgmt_pkg

**Purpose:** Displays upcoming flights from specified airport using explicit cursor

**Parameters:**

| Parameter    | Type   | Mode | Description      |
| ------------ | ------ | ---- | ---------------- |
| p_airport_id | NUMBER | IN   | Airport to query |

**Cursor Logic:**

```sql
CURSOR flight_cursor IS
    SELECT f.flight_id, al.name AS airline, 
           ap_dep.name AS departure_airport,
           ap_arr.name AS arrival_airport,
           f.departure_time, f.available_seats
    FROM flights f
    INNER JOIN airlines al ON f.airline_id = al.airline_id
    INNER JOIN airports ap_dep ON f.departure_airport = ap_dep.airport_id
    INNER JOIN airports ap_arr ON f.arrival_airport = ap_arr.airport_id
    WHERE f.departure_airport = p_airport_id
    AND f.departure_time > SYSTIMESTAMP;
```

**Example Usage:**

```sql
BEGIN
    airport_mgmt_pkg.list_flights_from_airport(1);
END;
```

---

### 6. PASSENGER_FLIGHT_SUMMARY Procedure

**Package:** airport_mgmt_pkg

**Purpose:** Generates booking summary using FOR LOOP cursor

**Parameters:** None

**Logic:**

* Uses FOR LOOP cursor for implicit cursor management
* Aggregates bookings per flight
* Calculates occupancy rates
* Displays grand totals

**Example Usage:**

```sql
BEGIN
    airport_mgmt_pkg.passenger_flight_summary();
END;
```

---

### 7. SHOW_UPCOMING_FLIGHTS Procedure

**Package:** airport_mgmt_pkg

**Purpose:** Displays flights using package-level cursor

**Parameters:**

| Parameter    | Type   | Mode | Description      |
| ------------ | ------ | ---- | ---------------- |
| p_airport_id | NUMBER | IN   | Airport to query |

**Uses:** Package cursor `cur_upcoming_flights`

**Example Usage:**

```sql
BEGIN
    airport_mgmt_pkg.show_upcoming_flights(1);
END;
```

---

### 8. SHOW_FLIGHT_PASSENGERS Procedure

**Package:** airport_mgmt_pkg

**Purpose:** Displays passenger manifest for a flight

**Parameters:**

| Parameter   | Type   | Mode | Description     |
| ----------- | ------ | ---- | --------------- |
| p_flight_id | NUMBER | IN   | Flight to query |

**Uses:** Package cursor `cur_passengers_by_flight`

**Output:**

* Passenger names
* Seat assignments
* Booking dates
* Ticket amounts
* Total revenue

**Example Usage:**

```sql
BEGIN
    airport_mgmt_pkg.show_flight_passengers(1);
END;
```

---

### 9. GENERATE_REVENUE_REPORT Procedure

**Package:** airport_mgmt_pkg

**Purpose:** Generates comprehensive revenue report by airline

**Parameters:** None

**Cursor Logic:**

```sql
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
```

**Output:**

* Per-airline statistics
* Market share calculations
* Industry totals

**Example Usage:**

```sql
BEGIN
    airport_mgmt_pkg.generate_revenue_report();
END;
```

---

## Functions Documentation

### 1. GET_AVAILABLE_SEATS Function

**Package:** airport_mgmt_pkg

**Purpose:** Returns available seat count for a flight

**Parameters:**

| Parameter   | Type   | Mode | Description     |
| ----------- | ------ | ---- | --------------- |
| p_flight_id | NUMBER | IN   | Flight to check |

**Return Type:** NUMBER

**Return Values:**

* `>= 0`: Number of available seats
* `-1`: Flight not found
* `-2`: Other errors

**Logic:**

```sql
SELECT available_seats 
INTO v_available_seats
FROM flights
WHERE flight_id = p_flight_id;
RETURN v_available_seats;
```

**Example Usage:**

```sql
DECLARE
    v_seats NUMBER;
BEGIN
    v_seats := airport_mgmt_pkg.get_available_seats(1);
    DBMS_OUTPUT.PUT_LINE('Available seats: ' || v_seats);
END;
```

---

### 2. CALCULATE_FLIGHT_DURATION Function

**Package:** airport_mgmt_pkg

**Purpose:** Calculates flight duration in hours

**Parameters:**

| Parameter   | Type   | Mode | Description         |
| ----------- | ------ | ---- | ------------------- |
| p_flight_id | NUMBER | IN   | Flight to calculate |

**Return Type:** NUMBER (decimal hours)

**Logic:**

```sql
SELECT ROUND((
    EXTRACT(DAY FROM (arrival_time - departure_time)) * 24 + 
    EXTRACT(HOUR FROM (arrival_time - departure_time)) + 
    EXTRACT(MINUTE FROM (arrival_time - departure_time)) / 60
), 2)
INTO v_duration
FROM flights
WHERE flight_id = p_flight_id;
```

**Example Usage:**

```sql
DECLARE
    v_duration NUMBER;
BEGIN
    v_duration := airport_mgmt_pkg.calculate_flight_duration(1);
    DBMS_OUTPUT.PUT_LINE('Duration: ' || v_duration || ' hours');
END;
```

---

### 3. GET_TOTAL_REVENUE Function

**Package:** airport_mgmt_pkg

**Purpose:** Calculates total revenue for an airline

**Parameters:**

| Parameter    | Type   | Mode | Description          |
| ------------ | ------ | ---- | -------------------- |
| p_airline_id | NUMBER | IN   | Airline to calculate |

**Return Type:** NUMBER (currency amount)

**Logic:**

```sql
SELECT NVL(SUM(t.total_amount), 0)
INTO v_total_revenue
FROM tickets t
INNER JOIN bookings b ON t.booking_id = b.booking_id
INNER JOIN flights f ON b.flight_id = f.flight_id
WHERE f.airline_id = p_airline_id
AND b.status = 'CONFIRMED';
```

**Example Usage:**

```sql
DECLARE
    v_revenue NUMBER;
BEGIN
    v_revenue := airport_mgmt_pkg.get_total_revenue(1);
    DBMS_OUTPUT.PUT_LINE('Total Revenue: $' || v_revenue);
END;
```

---

### 4. GET_BOOKING_COUNT Function

**Package:** airport_mgmt_pkg

**Purpose:** Counts confirmed bookings for a flight

**Parameters:**

| Parameter   | Type   | Mode | Description     |
| ----------- | ------ | ---- | --------------- |
| p_flight_id | NUMBER | IN   | Flight to count |

**Return Type:** NUMBER

**Logic:**

```sql
SELECT COUNT(*)
INTO v_count
FROM bookings
WHERE flight_id = p_flight_id
AND status = 'CONFIRMED';
```

**Example Usage:**

```sql
DECLARE
    v_count NUMBER;
BEGIN
    v_count := airport_mgmt_pkg.get_booking_count(1);
    DBMS_OUTPUT.PUT_LINE('Total bookings: ' || v_count);
END;
```

---

### 5. IS_SEAT_AVAILABLE Function

**Package:** airport_mgmt_pkg

**Purpose:** Checks if specific seat is available on flight

**Parameters:**

| Parameter   | Type     | Mode | Description           |
| ----------- | -------- | ---- | --------------------- |
| p_flight_id | NUMBER   | IN   | Flight to check       |
| p_seat_no   | VARCHAR2 | IN   | Seat number to verify |

**Return Type:** BOOLEAN

**Logic:**

```sql
SELECT COUNT(*)
INTO v_count
FROM bookings
WHERE flight_id = p_flight_id
AND seat_no = p_seat_no
AND status = 'CONFIRMED';
RETURN (v_count = 0);
```

**Example Usage:**

```sql
DECLARE
    v_available BOOLEAN;
BEGIN
    v_available := airport_mgmt_pkg.is_seat_available(1, '12A');
    IF v_available THEN
        DBMS_OUTPUT.PUT_LINE('Seat is available');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Seat is booked');
    END IF;
END;
```

---

## Triggers Documentation

### 1. Universal Audit Triggers (8 triggers)

#### TRG_AUDIT_BOOKINGS

**Type:** AFTER INSERT OR UPDATE OR DELETE

**Table:** bookings

**Purpose:** Logs all booking operations to audit_log

**Logic:**

```sql
PRAGMA AUTONOMOUS_TRANSACTION; -- Independent transaction
IF INSERTING THEN
    -- Log new booking details
ELSIF UPDATING THEN
    -- Log old vs new values
ELSIF DELETING THEN
    -- Log deleted booking
END IF;
INSERT INTO audit_log (...);
COMMIT; -- Commits only audit, not main transaction
```

**Key Feature:** Uses `PRAGMA AUTONOMOUS_TRANSACTION` to ensure audit logs are preserved even if main transaction rolls back.

---

#### TRG_AUDIT_FLIGHTS

**Type:** AFTER INSERT OR UPDATE OR DELETE

**Table:** flights

**Purpose:** Logs all flight operations

**Logged Information:**

* INSERT: New flight details (airline, aircraft, fare, seats)
* UPDATE: Changes in fare and available seats
* DELETE: Deleted flight information

---

#### TRG_AUDIT_PASSENGERS

**Type:** AFTER INSERT OR UPDATE OR DELETE

**Table:** passengers

**Purpose:** Logs passenger data changes

---

#### TRG_AUDIT_TICKETS

**Type:** AFTER INSERT OR UPDATE OR DELETE

**Table:** tickets

**Purpose:** Logs ticket issuance and modifications

---

#### TRG_AUDIT_AIRCRAFTS

**Type:** AFTER INSERT OR UPDATE OR DELETE

**Table:** aircrafts

**Purpose:** Logs aircraft fleet changes

---

#### TRG_AUDIT_AIRLINES

**Type:** AFTER INSERT OR UPDATE OR DELETE

**Table:** airlines

**Purpose:** Logs airline company changes

---

#### TRG_AUDIT_AIRPORTS

**Type:** AFTER INSERT OR UPDATE OR DELETE

**Table:** airports

**Purpose:** Logs airport infrastructure changes

---

#### TRG_AUDIT_EMPLOYEES

**Type:** AFTER INSERT OR UPDATE OR DELETE

**Table:** employees

**Purpose:** Logs employee record changes

---

### 2. Flight Schedule Audit Trigger

#### TRG_FLIGHT_SCHEDULE_AUDIT

**Type:** AFTER UPDATE OF departure_time, arrival_time

**Table:** flights

**Purpose:** Specialized logging for flight time changes

**Logic:**

```sql
IF (:OLD.departure_time != :NEW.departure_time) OR 
   (:OLD.arrival_time != :NEW.arrival_time) THEN
    INSERT INTO flight_audit_log (
        flight_id,
        old_departure_time, new_departure_time,
        old_arrival_time, new_arrival_time,
        modified_by
    ) VALUES (...);
END IF;
```

**Key Feature:** Only logs when times actually change (not fare or other fields).

---

### 3. Audit Log Protection Trigger

#### TRG_PROTECT_AUDIT_LOG

**Type:** BEFORE DELETE OR UPDATE

**Table:** audit_log

**Purpose:** Prevents unauthorized audit log modifications

**Security Logic:**

```sql
-- Check if current user is ADMIN
SELECT role INTO v_user_role
FROM employees
WHERE username = USER;

IF v_user_role != 'ADMIN' THEN
    RAISE_APPLICATION_ERROR(-20301, 'Only ADMIN can modify audit logs');
END IF;
```

**Access Control:**

* ADMIN role: Allowed (operation logged)
* Other roles: BLOCKED with error
* Unknown users: BLOCKED

---
<!--
### 4. Weekend & Holiday Restriction Triggers (4 triggers)

#### TRG_WEEKEND_HOLIDAY_RESTRICTION (BOOKINGS)

**Type:** BEFORE INSERT OR UPDATE OR DELETE

**Table:** bookings

**Purpose:** Blocks operations on weekends and holidays

**Logic:**

```sql
-- Check if user is ADMIN (exempt from restrictions)
IF v_user_role = 'ADMIN' THEN
    RETURN; -- Allow operation
END IF;

-- Check if weekend
v_day_of_week := TRIM(TO_CHAR(SYSDATE, 'DAY'));
IF v_day_of_week IN ('SATURDAY', 'SUNDAY') THEN
    RAISE_APPLICATION_ERROR(-20401, 'Operations restricted on weekends');
END IF;

-- Check if holiday
SELECT COUNT(*) INTO v_holiday_count
FROM holidays
WHERE TRUNC(holiday_date) = TRUNC(SYSDATE)
AND is_active = 'Y';

IF v_holiday_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20402, 'Operations restricted on holidays');
END IF;
```

**Applies To:**

* TRG_WEEKEND_HOLIDAY_RESTRICTION (bookings)
* TRG_FLIGHTS_WEEKEND_HOLIDAY_RESTRICT (flights)
* TRG_TICKETS_WEEKEND_HOLIDAY -->
