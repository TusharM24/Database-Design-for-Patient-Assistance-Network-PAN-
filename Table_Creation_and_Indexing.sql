-- Dropping tables in reverse dependency order to avoid foreign key constraint errors
DROP TABLE IF EXISTS CreditCard;
DROP TABLE IF EXISTS Cheque;
DROP TABLE IF EXISTS Expenses;
DROP TABLE IF EXISTS Reports;
DROP TABLE IF EXISTS Care;
DROP TABLE IF EXISTS TeamLeader;
DROP TABLE IF EXISTS HoursNMonths;
DROP TABLE IF EXISTS Combines;
DROP TABLE IF EXISTS Volunteer;
DROP TABLE IF EXISTS Needs;
DROP TABLE IF EXISTS InsurancePolicy;
DROP TABLE IF EXISTS Client;
DROP TABLE IF EXISTS Donor;
DROP TABLE IF EXISTS EmergencyContact;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS People;

-- Create People Table
CREATE TABLE People (
    SSN CHAR(11) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Gender CHAR(1),
    Profession VARCHAR(100),
    Mailing_Address VARCHAR(255),
    Email_Address VARCHAR(255),
    Phone_Number VARCHAR(15),
    Mailing_List BIT DEFAULT 0 -- 1 for subscribed, 0 for not subscribed
);


-- Create Emergency Contact Table
CREATE TABLE EmergencyContact (
    People_SSN CHAR(11),
    Name VARCHAR(100) NOT NULL,
    Phone_No VARCHAR(15),
    Relation VARCHAR(50),
    PRIMARY KEY (People_SSN, Phone_No),
    FOREIGN KEY (People_SSN) REFERENCES People(SSN)
);

-- Index on People_SSN for dynamic hashing in EmergencyContact table
CREATE INDEX IDX_EmergencyContact_People_SSN ON EmergencyContact(People_SSN);

-- Create Client Table
CREATE TABLE Client (
    SSN CHAR(11) PRIMARY KEY,
    Doctor_name VARCHAR(100),
    Doctor_Phone_No VARCHAR(15),
    Assigned_date DATE,
    FOREIGN KEY (SSN) REFERENCES People(SSN)
);


-- Create Needs Table
CREATE TABLE Needs (
    Client_SSN CHAR(11),
    Importance_type VARCHAR(50),
    Importance_score INT CHECK (Importance_score BETWEEN 1 AND 10),
    PRIMARY KEY (Client_SSN, Importance_type,Importance_score),
    FOREIGN KEY (Client_SSN) REFERENCES Client(SSN)
);
-- Index on Importance_score for range search optimization in Needs table
CREATE NONCLUSTERED INDEX IDX_Needs_Importance_Score ON Needs(Importance_score);

-- Create Insurance Policy Table
CREATE TABLE InsurancePolicy (
    Policy_id INT PRIMARY KEY,
    Client_SSN CHAR(11),
    Name VARCHAR(100),
    Address VARCHAR(255),
    Type VARCHAR(50),
    FOREIGN KEY (Client_SSN) REFERENCES Client(SSN) -- Foreign key reference to Client table
);

-- Index on Type for sequential file organization in InsurancePolicy table
CREATE NONCLUSTERED INDEX IDX_InsurancePolicy_Type ON InsurancePolicy(Type);




-- Create Volunteer Table
CREATE TABLE Volunteer (
    SSN CHAR(11) PRIMARY KEY,
    Join_date DATE,
    Training_date DATE,
    Training_Location VARCHAR(100),
    FOREIGN KEY (SSN) REFERENCES People(SSN)
);

-- Create Teams Table
CREATE TABLE Teams (
    Name VARCHAR(100) PRIMARY KEY,
    Type VARCHAR(50),
    Date_formed DATE
);
-- Index on Date_formed for sequential file organization in Teams table
CREATE NONCLUSTERED INDEX IDX_Teams_Date_Formed ON Teams(Date_formed);

-- Create Combines Table with extra attribute `month`
CREATE TABLE Combines (
    Team_Name VARCHAR(100),
    Volunteer_SSN CHAR(11),
    Status BIT DEFAULT 1, -- 1 for active, 0 for inactive
    PRIMARY KEY (Team_Name, Volunteer_SSN),
    FOREIGN KEY (Team_Name) REFERENCES Teams(Name),
    FOREIGN KEY (Volunteer_SSN) REFERENCES Volunteer(SSN)
);
-- B+ Tree index on Team_Name in Combines table
CREATE NONCLUSTERED INDEX IDX_Combines_Team_Name ON Combines(Team_Name);

-- Create HoursNMonths Table
CREATE TABLE HoursNMonths (
    Team_Name VARCHAR(100),
    Volunteer_SSN CHAR(11),
    Hours INT,
    Month VARCHAR(20),
    PRIMARY KEY (Team_Name, Volunteer_SSN, Hours,Month),
    FOREIGN KEY (Team_Name,Volunteer_SSN) REFERENCES Combines(Team_Name,Volunteer_SSN)
);

-- Create TeamLeader Table
CREATE TABLE TeamLeader (
    Volunteer_SSN CHAR(11),
    Team_Name VARCHAR(100),
    PRIMARY KEY (Volunteer_SSN),
    FOREIGN KEY (Volunteer_SSN) REFERENCES Volunteer(SSN),
    FOREIGN KEY (Team_Name) REFERENCES Teams(Name)
);

-- Create Care Table with Active_Status indicator
CREATE TABLE Care (
    Team_Name VARCHAR(100),
    Client_SSN CHAR(11),
    Active_Status BIT DEFAULT 1, -- 1 for active, 0 for inactive
    PRIMARY KEY (Team_Name, Client_SSN),
    FOREIGN KEY (Team_Name) REFERENCES Teams(Name),
    FOREIGN KEY (Client_SSN) REFERENCES Client(SSN)
);
-- Index on Client_SSN for dynamic hashing equivalent in Care table
CREATE INDEX IDX_Care_Client_SSN ON Care(Client_SSN);

-- Create Employee Table
CREATE TABLE Employee (
    SSN CHAR(11) PRIMARY KEY,
    Salary DECIMAL(10, 2),
    Marital_Status VARCHAR(10),
    Hiring_Date DATE,
    FOREIGN KEY (SSN) REFERENCES People(SSN)
);
-- B+ Tree index on SSN in Employee table
CREATE INDEX IDX_Employee_SSN ON Employee(SSN);

-- Create Reports Table
CREATE TABLE Reports (
    Team_name VARCHAR(100),
    Employee_SSN CHAR(11),
    Reporting_Date DATE,
    Description TEXT,
    PRIMARY KEY (Team_name),
    FOREIGN KEY (Team_name) REFERENCES Teams(Name),
    FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN)
);
-- Index on Employee_SSN for dynamic hashing in Reports table
CREATE INDEX IDX_Reports_Employee_SSN ON Reports(Employee_SSN);

-- Create Expenses Table
CREATE TABLE Expenses (
    Employee_SSN CHAR(11),
    Expense_date DATE,
    Amount DECIMAL(10, 2),
    Description TEXT,
    PRIMARY KEY (Employee_SSN, Expense_date,Amount),
    FOREIGN KEY (Employee_SSN) REFERENCES Employee(SSN)
);
-- B+ Tree index on Expense_date in Expenses table
CREATE INDEX IDX_Expenses_Expense_Date ON Expenses(Expense_date);

-- Create Donor Table
CREATE TABLE Donor (
    SSN CHAR(11) PRIMARY KEY,
    Anonymous BIT,
    FOREIGN KEY (SSN) REFERENCES People(SSN)
);
-- Index on SSN for dynamic hashing in Donor table
CREATE INDEX IDX_Donor_SSN ON Donor(SSN);

-- Create Cheque Table
CREATE TABLE Cheque (
    Donor_SSN CHAR(11),
    Date DATE,
    Amount DECIMAL(10, 2),
    Donation_type VARCHAR(50),
    Campaign_name VARCHAR(100),
    Cheque_No VARCHAR(50),
    PRIMARY KEY (Donor_SSN, Date, Cheque_No),
    FOREIGN KEY (Donor_SSN) REFERENCES Donor(SSN)
);
-- Index on Donor_SSN for dynamic hashing in Cheque table
CREATE INDEX IDX_Cheque_Donor_SSN ON Cheque(Donor_SSN);

-- Create Credit_Card Table
CREATE TABLE CreditCard (
    Donor_SSN CHAR(11),
    Date DATE,
    Amount DECIMAL(10, 2),
    Donation_type VARCHAR(50),
    Campaign_name VARCHAR(100),
    Card_Number VARCHAR(20),
    Card_type VARCHAR(20),
    Expiry_date DATE,
    PRIMARY KEY (Donor_SSN, Date, Card_Number),
    FOREIGN KEY (Donor_SSN) REFERENCES Donor(SSN)
);
-- Index on Donor_SSN for dynamic hashing in CreditCard table
CREATE INDEX IDX_CreditCard_Donor_SSN ON CreditCard(Donor_SSN);




SELECT * FROM People;
SELECT * FROM Employee;
SELECT * FROM Teams;
SELECT * FROM InsurancePolicy;
SELECT * FROM EmergencyContact;
SELECT * FROM Donor;
SELECT * FROM Client;
SELECT * FROM Needs;
SELECT * FROM HoursNMonths;
SELECT * FROM Volunteer;
SELECT * FROM Combines;
SELECT * FROM TeamLeader;
SELECT * FROM Care;
SELECT * FROM Reports;
SELECT * FROM Expenses;
SELECT * FROM Cheque;
SELECT * FROM CreditCard;

