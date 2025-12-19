# Airport and Airline Management System(Oracle PL/SQL Capstone)

## 👤 Identification

**ID:** 27928     
**Name:** Eric BIKORIMANA     
**Course:** INSY 8311 - Database Development with PL/SQL   
**University:** Adventist University of Central Africa   
**Academic Year:** 2025-2026, SEM I   
**Group:** D (Thursday)   
**Instructor:** Eric Maniraguha(`eric.maniraguha@auca.ac.rw`)  

---

## 1. ⚙️ Requirement

| Tool | Category | Primary Purpose | Benefit |
| :--- | :--- | :--- | :--- |
| **Oracle 23c Database** | Database | The core database engine (use the **Free - Developer Release**). | Provides the latest features and the target environment for PL/SQL execution. |
| **Docker** | Virtualization/Containerization | Packages the database and its dependencies into a lightweight, portable container. | **Quick setup** of a consistent local Oracle environment (e.g., using the `container-registry.oracle.com/database/free` image).  |
| **SQL Developer** | IDE/GUI Tool | Graphical tool for database administration, development, and debugging. | **Best-in-class PL/SQL Debugger** and easy schema browsing. |
| **VS Code** | Code Editor/IDE | Lightweight, highly extensible source code editor. | Excellent for writing and version-controlling PL/SQL scripts, using extensions like **Oracle Developer Tools for VS Code**. |
| **draw.io (or diagrams.net)** | Diagramming | Cloud-based and desktop tool for creating visual diagrams. | **Visualizing database schemas** (ERDs), process flows, and PL/SQL package dependencies. |
| **MS PowerPoint** | Presentation | Tool for creating slide presentations. | **Documenting and presenting** PL/SQL designs, architectural diagrams (often generated from draw.io), and training materials. |

---

## Repository Structure

Folder and file Structure:
 * `sql/`: Contains the SQL codes(Tables + Data + Package + Triggers).
 *  `docs/`:
      * `data_dict.md`: Detailed metadata of all tables.
      *  `thu_27928_eric_airportMS_presentation.pptx`: Project Presentation.
 *  `images/`: Evidence of successful test runs.
     * `database_object/`: Contains images evidence for database objects.
     * `test_result`: Contains images evidence for test results.
     * `Database_Schema.png`: Database Schema Diagram.
     * `ER_Diagram.png`: Entity Relationship Diagram.
     * `ticket_booking_process.png`: Business Process Swimlane Diagrams.
  * `business_intelligence/`: Analytical queries
    

---

### Step 1: Create the Database Container

Run this as the SYS/SYSTEM user to set up the Pluggable Database (PDB):

```sql
-- Create PDB 
CREATE PLUGGABLE DATABASE thu_27928_eric_aiportMS_db
ADMIN USER eric IDENTIFIED BY eric
FILE_NAME_CONVERT = (
'/opt/oracle/oradata/FREE/pdbseed/',
' /opt/oracle/oradata/FREE/thu_27928_eric_aiportMS_db/'
);

ALTER PLUGGABLE DATABASE thu_27928_eric_aiportMS_db OPEN READ;

ALTER PLUGGABLE DATABASE thu_27928_eric_aiportMS_db SAVE;

-- Enter to thu_27928_eric_aiportMS_db PDB
ALTER SESSION SET CONTAINER = thu_27928_eric_aiportMS_db;

-- Grant Priviliges to user
GRANT ALL PRIVILEGES TO eric;

```

### Step 2: Deploy the Schema

1. Open SQL Developer.
2. Connect as `eric` (Password: `eric`).
3. Run the script located in: `sql/`.

---

## 2. 📝 Project Overview:

### **Title: Airport and Airline Management System**

The **Airport and Airline Management System** aims to design and implement an integrated PL/SQL-based system to manage airport and airlines operation including flights scheduling, passenger bookings, aircrafts details, and ticketing. It ensures data consistency, automates core airport processes, and provides accurate information retrieval for management and passengers.

### Problem statement

Airport operations require managing complex relationships between flights, passengers, aircraft, and bookings, which manual systems cannot efficiently handle, leading to errors and data inconsistency.

### Project Objectives

* Design a normalized relational database for airport operations
* Implement comprehensive PL/SQL components (packages, procedures, functions, triggers)
* Automate business processes using triggers and stored procedures

---

## 3. 📋 Quick Start Guide

To deploy this project, execute the scripts in the `sql/` folder in the following strict order:

1. `01_create_tables.sql`: Creates tables.
2. `02_insert_data.sql`: populates 60+ test records.
3. `05_package.sql`: Compiles the `airport_mgmt_pkg` package containing all Procedures and Functions.
4. `06_triggers.sql`: Contains database triggers that automatically execute actions when data changes occur (INSERT, UPDATE, DELETE) to enforce business rules and maintain data integrity in the system.
5. `07_test_run.sql`: Contains test scripts and sample data operations to verify that all database objects (tables, procedures, functions, triggers) are working correctly in the airport and airline management system.

---

## 4. 📑 Documentation Links

* [Entity-Relationship (ER) Diagram](images/ER_Diagram.png): Represents the conceptual data model for an Airport and Airline Management System.
* [Database Schema](images/Database_Schema.png): Represents the Physical Database Schema for the Airport and Airline Management System.
* [Business Process Model (BPMN)](images/ticket_booking_process.png):  Visual workflow of Ticket booking process.
* [PL/SQL System Presentation](docs/thu_27928_eric_airportMS_presentation.pptx): Project Presentation. 
* [Data dictionary](docs/data_dict.md): Documentation file that defines and describes all database tables, columns, data types and constraints.
* [Business Intelligence](business_intelligence/): Analytical queries
* [Image for Database Object](images/database_object): Directory containing organized SQL files that define and create all database components(tables, packages, procedures, functions, triggers).
* [Images for test result](images/test_results): Directory containing output files, logs, and results from executing test scripts to verify the functionality.

