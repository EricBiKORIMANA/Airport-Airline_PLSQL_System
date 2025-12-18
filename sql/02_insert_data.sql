-- Insert Airports
INSERT ALL
  INTO airports VALUES (1,'Kigali International Airport', 'Kigali', 'Rwanda')
  INTO airports VALUES (2,'Jomo Kenyatta International', 'Nairobi', 'Kenya')
  INTO airports VALUES (3,'Julius Nyerere International', 'Dar es Salaam', 'Tanzania')
  INTO airports VALUES (4,'Addis Ababa Bole International Airport', 'Addis Ababa', 'Ethiopia')
  INTO airports VALUES (5,'Brussels Airport', 'Diegem', 'Belgium')
  INTO airports VALUES (6,'Dubai International Airport', 'Dubai', 'UAE')
  INTO airports VALUES (7,'Istanbul Airport ', 'Istanbul', 'Turkiye')
SELECT * FROM dual;

-- Insert Airlines

INSERT ALL
  INTO airlines VALUES (1,'RwandAir', 'Kigali, Rwanda')
  INTO airlines VALUES (2,'Kenya Airways', 'Nairobi, Kenya')
  INTO airlines VALUES (3,'Air Tanzania', 'Dar es Salaam, Tanzania')
  INTO airlines VALUES (4,'Ethiopian Airlines', 'Addis Ababa, Ethiopia')
  INTO airlines VALUES (5,'Brussels Airlines', 'Diegem, Belgium')
  INTO airlines VALUES (6,'Quatar Airways', 'Dubai, UAE')
  INTO airlines VALUES (7,'Turkish Airlines', 'Istanbul, Turkiye')
SELECT * FROM dual;

-- Insert Aircrafts
INSERT ALL
  INTO aircrafts VALUES (1,'Boeing 737-800', 189, 1)
  INTO aircrafts VALUES (2,'Airbus A330-300', 277, 1)
  INTO aircrafts VALUES (3,'Boeing 787-8', 234, 2)
  INTO aircrafts VALUES (4,'Airbus A350-900', 325, 3)
  INTO aircrafts VALUES (5,'Boeing 777-300ER', 427, 5)
  INTO aircrafts VALUES (6,'Bombardier CRJ-900', 70, 4)
  INTO aircrafts VALUES (7,'Embraer E-190', 100, 2)
  INTO aircrafts VALUES (8,'Airbus A220-300', 68, 3)
  INTO aircrafts VALUES (9,'Bombardier Q-400', 180, 3)
  INTO aircrafts VALUES (10,'Airbus A220-300', 130, 7)
  INTO aircrafts VALUES (11,'Boeing 787-8', 234, 5)
  INTO aircrafts VALUES (12,'Airbus A330-300', 277, 6)
  INTO aircrafts VALUES (13,'Boeing 737-800', 189, 6)
  INTO aircrafts VALUES (14,'Airbus A330-300', 277, 5)
  INTO aircrafts VALUES (15,'Boeing 787-8', 234, 5)
  INTO aircrafts VALUES (16,'Airbus A350-900', 325, 7)
SELECT * FROM dual;

-- Insert Flights
INSERT INTO flights VALUES (1, 1, 1, 2, 
    TIMESTAMP '2025-11-15 08:00:00', TIMESTAMP '2025-11-15 09:30:00', 250.00, 189);
INSERT INTO flights VALUES (1, 2, 1, 5, 
    TIMESTAMP '2025-11-16 14:00:00', TIMESTAMP '2025-11-16 20:30:00', 850.00, 277);
INSERT INTO flights VALUES (2, 3, 2, 3, 
    TIMESTAMP '2025-11-17 10:00:00', TIMESTAMP '2025-11-17 11:15:00', 180.00, 234);
INSERT INTO flights VALUES (3, 4, 1, 4, 
    TIMESTAMP '2025-11-18 06:30:00', TIMESTAMP '2025-11-18 07:45:00', 200.00, 325);
INSERT INTO flights VALUES (4, 5, 5, 6, 
    TIMESTAMP '2025-11-19 22:00:00', TIMESTAMP '2025-11-20 06:30:00', 1200.00, 427);


DECLARE
  v_airline_id   NUMBER;
  v_aircraft_id  NUMBER;
  v_capacity     NUMBER;
  v_dep_airport  NUMBER;
  v_arr_airport  NUMBER;
  v_departure    TIMESTAMP;
  v_arrival      TIMESTAMP;
  v_fare         NUMBER(10,2);
  v_avail        NUMBER;

  -- helper: random flight duration in minutes (1–480)
  FUNCTION rand_duration RETURN NUMBER IS
  BEGIN
    RETURN TRUNC(DBMS_RANDOM.VALUE(60, 480));
  END;
BEGIN
  FOR i IN 1..120 LOOP
    -- Random airline
    SELECT airline_id INTO v_airline_id
    FROM (SELECT airline_id FROM airlines ORDER BY DBMS_RANDOM.VALUE)
    WHERE ROWNUM = 1;

    -- Random aircraft (with capacity)
    SELECT aircraft_id, capacity INTO v_aircraft_id, v_capacity
    FROM (SELECT aircraft_id, capacity FROM aircrafts ORDER BY DBMS_RANDOM.VALUE)
    WHERE ROWNUM = 1;

    -- Random departure airport
    SELECT airport_id INTO v_dep_airport
    FROM (SELECT airport_id FROM airports ORDER BY DBMS_RANDOM.VALUE)
    WHERE ROWNUM = 1;

    -- Random arrival airport (different from departure)
    LOOP
      SELECT airport_id INTO v_arr_airport
      FROM (SELECT airport_id FROM airports ORDER BY DBMS_RANDOM.VALUE)
      WHERE ROWNUM = 1;
      EXIT WHEN v_arr_airport != v_dep_airport;
    END LOOP;

    -- Departure time: spread across next 30 days, random hour
    v_departure := TRUNC(SYSDATE) + TRUNC(DBMS_RANDOM.VALUE(1, 31))
                   + NUMTODSINTERVAL(TRUNC(DBMS_RANDOM.VALUE(6, 22)), 'HOUR');

    -- Arrival time: departure + random minutes
    v_arrival := v_departure + NUMTODSINTERVAL(rand_duration, 'MINUTE');

    -- Fare: 80–600 USD
    v_fare := ROUND(DBMS_RANDOM.VALUE(80, 600), 2);

    -- Available seats: 50–100% of aircraft capacity
    v_avail := TRUNC(DBMS_RANDOM.VALUE(0.5, 1) * v_capacity);

    -- Insert flight
    INSERT INTO flights(airline_id, aircraft_id, departure_airport, arrival_airport,
                        departure_time, arrival_time, fare, available_seats)
    VALUES (v_airline_id, v_aircraft_id, v_dep_airport, v_arr_airport,
            v_departure, v_arrival, v_fare, v_avail);
  END LOOP;

  COMMIT;
END;
/



-- Insert Passengers
INSERT ALL
  INTO passengers VALUES (1,'Cedric Shema', 'Male', 'RWA123456','Rwandan','+250788123456')
  INTO passengers VALUES (2,'Grace Uwera', 'Female', 'RWA234567','Rwandan','+250788234567')
  INTO passengers VALUES (3,'Peter Kamau', 'Male',  'KEN345678','Kenyan','+254722345678')
  INTO passengers VALUES (4,'Sarah Mutesi', 'Female', 'UGA456789', 'Ugandan','+256775456789')
  INTO passengers VALUES (5,'David Mwangi', 'Male',  'TZA567890','Tanzanian','+255768567890')
  INTO passengers VALUES (6,'Alice Niyonsaba', 'Female', 'RWA111222','Rwandan','+250788111222')
  INTO passengers VALUES (7,'Eric Mugisha', 'Male','RWA333444', 'Rwandan', '+250788333444')
  INTO passengers VALUES (8,'Mary Atieno', 'Female', 'KEN222333', 'Kenyan','+254711222333')
  INTO passengers VALUES (9,'Joseph Okello', 'Male','UGA333444', 'Ugandan', '+256772333444')
  INTO passengers VALUES (10,'Fatima Hassan', 'Female', 'TZA444555', 'Tanzanian','+255765444555')
  INTO passengers VALUES (11,'Pauline Uwase', 'Female', 'RWA555666', 'Rwandan','+250788555666')
  INTO passengers VALUES (12,'Samuel Nkurunziza', 'Male',  'RWA777888','Rwandan','+250788777888')
  INTO passengers VALUES (13,'James Kariuki', 'Male', 'KEN999000','Kenyan', '+254722999000')
  INTO passengers VALUES (14,'Linda Namutebi', 'Female', 'UGA111222', 'Ugandan','+256775111222')
  INTO passengers VALUES (15,'George Mushi', 'Male', 'TZA333444', 'Tanzanian','+255768333444')
  INTO passengers VALUES (16,'Claudine Mukamana', 'Female','RWA222333', 'Rwandan', '+250788222333')
  INTO passengers VALUES (17,'Patrick Ndungu', 'Male','KEN444555', 'Kenyan', '+254711444555')
  INTO passengers VALUES (18,'Stella Achieng', 'Female', 'UGA555666','Ugandan', '+256772555666')
  INTO passengers VALUES (19,'Michael Omondi', 'Male', 'KEN666777', 'Kenyan','+254722666777')
  INTO passengers VALUES (20,'Beatrice Uwimana', 'Female', 'RWA999111', 'Rwandan','+250788999111')
  INTO passengers VALUES (21,'Daniel Kato', 'Male', 'UGA888999', 'Ugandan','+256775888999')
  INTO passengers VALUES (22,'Rose Wanjiru', 'Female','KEN888999', 'Kenyan', '+254711888999')
  INTO passengers VALUES (23,'Innocent Habimana', 'Male','RWA444555', 'Rwandan', '+250788444555')
  INTO passengers VALUES (24,'Christine Mbabazi', 'Female','UGA111333', 'Ugandan', '+256772111333')
  INTO passengers VALUES (25,'Victor Mutesa', 'Male', 'RWA666777', 'Rwandan','+250788666777')
  INTO passengers VALUES (26,'Agnes Nansubuga', 'Female', 'UGA222444', 'Ugandan','+256775222444')
  INTO passengers VALUES (27,'Charles Otieno', 'Male', 'KEN333555','Kenyan', '+254722333555')
  INTO passengers VALUES (28,'Janet Uwase', 'Female','RWA555999', 'Rwandan', '+250788555999')
  INTO passengers VALUES (29,'Robert Mugabe', 'Male', 'TZA777888', 'Tanzanian','+255765777888')
  INTO passengers VALUES (30,'Sylvia Niyibizi', 'Female','RWA888000', 'Rwandan', '+250788888000')
SELECT * FROM dual;




-- SQL script to insert initial data into the employees table
INSERT ALL
  INTO employees VALUES ('admin', 'System Administrator', 'ADMIN')
  INTO employees VALUES ('eric_agent', 'Agent Eric', 'AGENT')
  INTO employees VALUES ('eric_manager', 'Manager Eric', 'MANAGER')
SELECT * FROM dual;

-- SQL script to insert initial data into the holidays table
INSERT ALL
  INTO holidays VALUES ('Happy New Year Day',DATE '2024-01-01', 'Happy New Year Day','Y')
  INTO holidays VALUES ('Genocide against the Tutsi Memorial Day',DATE '2024-04-07', 'Genocide against the Tutsi Memorial Day','Y')
  INTO holidays VALUES ('Labor Day',DATE '2024-05-01', 'Labor Day','Y')
  INTO holidays VALUES ('Independence Day',DATE '2024-07-01', 'Independence Day','Y')
  INTO holidays VALUES ('Liberation Day',DATE '2024-07-04', 'Liberation Day','Y')
  INTO holidays VALUES ('Assumption Day',DATE '2024-08-15', 'Assumption Day','Y')
  INTO holidays VALUES ('National Heroes Day',DATE '2024-02-01', 'National Heroes Day','Y')
  INTO holidays VALUES ('Umuganura Day',DATE '2024-08-01', 'Umuganura Day','Y')
  INTO holidays VALUES ('Christmas Day',DATE '2024-12-25', 'Christmas Day','Y')
  INTO holidays VALUES ('Boxing Day',DATE '2024-12-26', 'Boxing Day','Y')
SELECT * FROM dual;

COMMIT;
