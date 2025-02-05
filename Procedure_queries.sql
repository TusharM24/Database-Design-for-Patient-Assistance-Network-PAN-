

-- Drop existing procedures if they exist
DROP PROCEDURE IF EXISTS AddNewTeam;
GO
DROP PROCEDURE IF EXISTS AddNewClient;
GO
DROP PROCEDURE IF EXISTS AddNewVolunteer;
GO
DROP PROCEDURE IF EXISTS AddVolunteerHours;
GO
DROP PROCEDURE IF EXISTS AddNewEmployee;
GO
DROP PROCEDURE IF EXISTS AddEmployeeExpense;
GO
DROP PROCEDURE IF EXISTS AddNewDonorWithDonations;
GO
DROP PROCEDURE IF EXISTS GetDoctorInfo;
GO
DROP PROCEDURE IF EXISTS GetTotalExpenses;
GO
DROP PROCEDURE IF EXISTS GetVolunteersForClient;
GO
DROP PROCEDURE IF EXISTS GetTeamsFoundedAfter;
GO
DROP PROCEDURE IF EXISTS GetAllPeopleAndEmergencyContacts;
GO
DROP PROCEDURE IF EXISTS GetEmployeeDonors;
GO
DROP PROCEDURE IF EXISTS IncreaseSalaryForMultiTeamEmployees;
GO
DROP PROCEDURE IF EXISTS DeleteClientsWithoutHealthInsurance;
GO

--1.Procedure for adding new team
CREATE PROCEDURE AddNewTeam (
    @Name VARCHAR(100),
    @Type VARCHAR(50),
    @DateFormed DATE
)
AS
BEGIN
    INSERT INTO Teams (Name, Type, Date_formed) VALUES (@Name, @Type, @DateFormed);
END;
GO



-- 2. Enter a New Client and Associate with Teams
CREATE PROCEDURE AddNewClient (
    @SSN CHAR(11),
    @Name VARCHAR(100),
    @Gender CHAR(1),
    @Profession VARCHAR(100),
    @MailingAddress VARCHAR(255),
    @EmailAddress VARCHAR(255),
    @PhoneNumber VARCHAR(15),
    @DoctorName VARCHAR(100),
    @DoctorPhoneNo VARCHAR(15),
    @AssignedDate DATE,
    @TeamNames VARCHAR(100), -- List of team names, may or may not be comma-separated
    @mailinglist BIT,
    @active_status BIT
)
AS
BEGIN
    -- Check if the person already exists in the People table
    IF NOT EXISTS (SELECT 1 FROM People WHERE SSN = @SSN)
    BEGIN
        INSERT INTO People (SSN, Name, Gender, Profession, Mailing_Address, Email_Address, Phone_Number, Mailing_List)
        VALUES (@SSN, @Name, @Gender, @Profession, @MailingAddress, @EmailAddress, @PhoneNumber, @mailinglist);
        PRINT 'Inserted into People table';
    END

    -- Insert into Client table
    INSERT INTO Client (SSN, Doctor_name, Doctor_Phone_No, Assigned_date) 
    VALUES (@SSN, @DoctorName, @DoctorPhoneNo, @AssignedDate);
    PRINT 'Inserted into Client table';

    -- Associate client with teams
    DECLARE @TeamName VARCHAR(100);

    IF CHARINDEX(',', @TeamNames) > 0
    BEGIN
        WHILE CHARINDEX(',', @TeamNames) > 0
        BEGIN
            SET @TeamName = LEFT(@TeamNames, CHARINDEX(',', @TeamNames) - 1);
            SET @TeamNames = RIGHT(@TeamNames, LEN(@TeamNames) - CHARINDEX(',', @TeamNames));
            INSERT INTO Care (Team_Name, Client_SSN, Active_Status) VALUES (@TeamName, @SSN, @active_status);
            PRINT 'Inserted into Care table for Team: ' + @TeamName;
        END
        INSERT INTO Care (Team_Name, Client_SSN, Active_Status) VALUES (@TeamNames, @SSN, @active_status );
        PRINT 'Inserted final team into Care table for Team: ' + @TeamNames;
    END
    ELSE
    BEGIN
        INSERT INTO Care (Team_Name, Client_SSN, Active_Status) VALUES (@TeamNames, @SSN, @active_status);
        PRINT 'Inserted single team into Care table for Team: ' + @TeamNames;
    END
END;
GO



GO

-- 3. Enter a New Volunteer and Associate with Teams
CREATE PROCEDURE AddNewVolunteer (
    @SSN CHAR(11),
    @Name VARCHAR(100),
    @Gender CHAR(1),
    @Profession VARCHAR(100),
    @MailingAddress VARCHAR(255),
    @EmailAddress VARCHAR(255),
    @PhoneNumber VARCHAR(15),
    @JoinDate DATE,
    @TrainingDate DATE,
    @TrainingLocation VARCHAR(100),
    @TeamNames VARCHAR(100), -- List of team names, may or may not be comma-separated
    @mailinglist BIT,
    @active_status BIT
)
AS
BEGIN
    -- Check if the person already exists in the People table
    IF NOT EXISTS (SELECT 1 FROM People WHERE SSN = @SSN)
    BEGIN
        -- Insert into People if the person does not exist
        INSERT INTO People (SSN, Name, Gender, Profession, Mailing_Address, Email_Address, Phone_Number, Mailing_List)
        VALUES (@SSN, @Name, @Gender, @Profession, @MailingAddress, @EmailAddress, @PhoneNumber, @mailinglist);
    END

    -- Insert into Volunteer table
    INSERT INTO Volunteer (SSN, Join_date, Training_date, Training_Location) VALUES (@SSN, @JoinDate, @TrainingDate, @TrainingLocation);

    -- Associate volunteer with teams
    DECLARE @TeamName VARCHAR(100);

    -- Check if there are commas in @TeamNames
    IF CHARINDEX(',', @TeamNames) > 0
    BEGIN
        -- Process each team name if there are commas
        WHILE CHARINDEX(',', @TeamNames) > 0
        BEGIN
            SET @TeamName = LEFT(@TeamNames, CHARINDEX(',', @TeamNames) - 1);
            SET @TeamNames = RIGHT(@TeamNames, LEN(@TeamNames) - CHARINDEX(',', @TeamNames));

            -- Insert into Combines with NULL values for Number_of_Hours and Month
            INSERT INTO Combines (Team_Name, Volunteer_SSN, Status)
            VALUES (@TeamName, @SSN, @active_status);
        END

        -- Insert the last team association after the loop
        INSERT INTO Combines (Team_Name, Volunteer_SSN, Status)
        VALUES (@TeamNames, @SSN, @active_status);
    END
    ELSE
    BEGIN
        -- If there are no commas, insert the single team directly
        INSERT INTO Combines (Team_Name, Volunteer_SSN, Status)
        VALUES (@TeamNames, @SSN, @active_status);
    END
END;
GO

GO
--DROP PROCEDURE IF EXISTS AddVolunteerHours;
--GO

-- 4. Enter Volunteer Hours Worked for a Team
-- Procedure to Add or Update Volunteer Hours for a Specific Month
CREATE PROCEDURE AddVolunteerHours(
    @TeamName VARCHAR(100),
    @VolunteerSSN CHAR(11),
    @HoursWorked INT,
    @Month VARCHAR(20)  -- Assuming month is passed as a number (1 for January, 2 for February, etc.)
)
AS
BEGIN
    -- Check if a similar record already exists
    IF EXISTS (
        SELECT 1 
        FROM HoursNMonths 
        WHERE Team_Name = @TeamName 
        AND Volunteer_SSN = @VolunteerSSN 
        AND Hours = @HoursWorked
        AND Month = @Month
    )
    BEGIN
        -- If an entry with the same volunteer, team, hours, and month exists, skip the insert
        PRINT 'Error: A similar record already exists for this volunteer, team, and month with the same number of hours.';
    END
    ELSE
    BEGIN
        -- Insert the new record if no duplicate exists
        INSERT INTO HoursNMonths (Team_Name, Volunteer_SSN, Hours, Month)
        VALUES (@TeamName, @VolunteerSSN, @HoursWorked, @Month);

        PRINT 'Volunteer hours added successfully.';
    END
END;
GO




--DROP PROCEDURE IF EXISTS AddNewEmployee;
--GO

-- 5. Enter a New Employee and Associate with Teams
CREATE PROCEDURE AddNewEmployee (
    @SSN CHAR(11),
    @Name VARCHAR(100),
    @Gender CHAR(1),
    @Profession VARCHAR(100),
    @MailingAddress VARCHAR(255),
    @EmailAddress VARCHAR(255),
    @PhoneNumber VARCHAR(15),
    @Salary DECIMAL(10,2),
    @MaritalStatus VARCHAR(10),
    @HiringDate DATE,
    @TeamNames VARCHAR(100), -- List of team names, may or may not be comma-separated
    @mailinglist BIT,
    @Description VARCHAR(255),
    @ReportDate DATE
)
AS
BEGIN
    -- Check if the person already exists in the People table
    IF NOT EXISTS (SELECT 1 FROM People WHERE SSN = @SSN)
    BEGIN
        -- Insert into People if the person does not exist
        INSERT INTO People (SSN, Name, Gender, Profession, Mailing_Address, Email_Address, Phone_Number, Mailing_List)
        VALUES (@SSN, @Name, @Gender, @Profession, @MailingAddress, @EmailAddress, @PhoneNumber, @mailinglist);
    END

    -- Insert into Employee table
    INSERT INTO Employee (SSN, Salary, Marital_Status, Hiring_Date) 
    VALUES (@SSN, @Salary, @MaritalStatus, @HiringDate);

    -- Associate employee with teams
    DECLARE @TeamName VARCHAR(100);

    -- Check if there are commas in @TeamNames
    IF CHARINDEX(',', @TeamNames) > 0
    BEGIN
        -- Process each team name if there are commas
        WHILE CHARINDEX(',', @TeamNames) > 0
        BEGIN
            SET @TeamName = LEFT(@TeamNames, CHARINDEX(',', @TeamNames) - 1);
            SET @TeamNames = RIGHT(@TeamNames, LEN(@TeamNames) - CHARINDEX(',', @TeamNames));
            INSERT INTO Reports (Team_name, Employee_SSN, Reporting_Date, Description) 
            VALUES (@TeamName, @SSN, @ReportDate, @Description);
        END

        -- Insert the last team association after the loop
        INSERT INTO Reports (Team_name, Employee_SSN, Reporting_Date, Description) 
        VALUES (@TeamNames, @SSN, @ReportDate, @Description);
    END
    ELSE
    BEGIN
        -- If there are no commas, insert the single team directly
        INSERT INTO Reports (Team_name, Employee_SSN, Reporting_Date, Description) 
        VALUES (@TeamNames, @SSN, @ReportDate, @Description);
    END
END;
GO
--DROP PROCEDURE IF EXISTS AddEmployeeExpense;
--GO
-- 6. Enter an Employee Expense
CREATE PROCEDURE AddEmployeeExpense (
    @EmployeeSSN CHAR(11),
    @ExpenseDate DATE,
    @Amount DECIMAL(10,2),
    @Description TEXT
)
AS
BEGIN
    INSERT INTO Expenses (Employee_SSN, Expense_date, Amount, Description) VALUES (@EmployeeSSN, @ExpenseDate, @Amount, @Description);
END;
GO


-- 7. Enter a New Donor and Associate with Donations
GO
-- Procedure to Add a New Donor and Associate with Multiple Donations (Cheque or Credit Card)
CREATE PROCEDURE AddNewDonorWithDonations (
    @SSN CHAR(11),
    @Name VARCHAR(100),
    @Gender CHAR(1),
    @Profession VARCHAR(100),
    @MailingAddress VARCHAR(255),
    @EmailAddress VARCHAR(255),
    @PhoneNumber VARCHAR(15),
    @mailinglist BIT,
    @Anonymous BIT,
    @Donations NVARCHAR(MAX) -- JSON array with donations
)
AS
BEGIN
    -- Check if the person already exists in the People table
    IF NOT EXISTS (SELECT 1 FROM People WHERE SSN = @SSN)
    BEGIN
        -- Insert into People if the person does not exist
        INSERT INTO People (SSN, Name, Gender, Profession, Mailing_Address, Email_Address, Phone_Number, Mailing_List)
        VALUES (@SSN, @Name, @Gender, @Profession, @MailingAddress, @EmailAddress, @PhoneNumber, @mailinglist);
    END

    -- Insert into Donor table if not already exists
    IF NOT EXISTS (SELECT 1 FROM Donor WHERE SSN = @SSN)
    BEGIN
        INSERT INTO Donor (SSN, Anonymous) VALUES (@SSN, @Anonymous);
    END

    -- Declare variables to store individual donation details
    DECLARE @DonationDate DATE, @Amount DECIMAL(10,2), @CampaignName VARCHAR(100);
    DECLARE @DonationType VARCHAR(50), @ChequeNo VARCHAR(50), @CardNumber VARCHAR(20), @CardType VARCHAR(20), @ExpiryDate DATE;

    -- Process each donation in the JSON array
    DECLARE DonationCursor CURSOR FOR
    SELECT *
    FROM OPENJSON(@Donations)
    WITH (
        Donation_type VARCHAR(50),
        Date DATE,
        Amount DECIMAL(10,2),
        Campaign_name VARCHAR(100),
        Cheque_No VARCHAR(50) ,
        Card_Number VARCHAR(20) ,
        Card_type VARCHAR(20) ,
        Expiry_date DATE 
    );

    OPEN DonationCursor;
    FETCH NEXT FROM DonationCursor INTO @DonationType, @DonationDate, @Amount, @CampaignName, @ChequeNo, @CardNumber, @CardType, @ExpiryDate;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Insert into either Cheque or CreditCard table based on DonationType
        IF @DonationType = 'Cheque'
        BEGIN
            -- Insert into Cheque table
            INSERT INTO Cheque (Donor_SSN, Date, Amount, Donation_type, Campaign_name, Cheque_No)
            VALUES (@SSN, @DonationDate, @Amount, @DonationType, @CampaignName, @ChequeNo);
        END
        ELSE IF @DonationType = 'Credit Card'
        BEGIN
            -- Insert into CreditCard table
            INSERT INTO CreditCard (Donor_SSN, Date, Amount, Donation_type, Campaign_name, Card_Number, Card_type, Expiry_date)
            VALUES (@SSN, @DonationDate, @Amount, @DonationType, @CampaignName, @CardNumber, @CardType, @ExpiryDate);
        END
        ELSE
        BEGIN
            -- Invalid DonationType handling
            RAISERROR('Invalid Donation Type. Please specify either "Cheque" or "Credit Card".', 16, 1);
            RETURN;
        END

        -- Fetch the next donation from the JSON array
        FETCH NEXT FROM DonationCursor INTO @DonationType, @DonationDate, @Amount, @CampaignName, @ChequeNo, @CardNumber, @CardType, @ExpiryDate;
    END

    CLOSE DonationCursor;
    DEALLOCATE DonationCursor;
END;
GO


-- 8. Retrieve Doctor’s Name and Phone Number of a Client
CREATE PROCEDURE GetDoctorInfo (
    @ClientSSN CHAR(11)
)
AS
BEGIN
    SELECT Doctor_name, Doctor_Phone_No
    FROM Client
    WHERE SSN = @ClientSSN;
END;
GO

-- 9. Retrieve Total Expenses Charged by Each Employee in a Time Period
CREATE PROCEDURE GetTotalExpenses (
    @StartDate DATE,
    @EndDate DATE
)
AS
BEGIN
    SELECT Employee_SSN, SUM(Amount) AS Total_Expenses
    FROM Expenses
    WHERE Expense_date BETWEEN @StartDate AND @EndDate
    GROUP BY Employee_SSN
    ORDER BY Total_Expenses DESC;
END;
GO

-- 10. Retrieve Volunteers in Teams Supporting a Particular Client
CREATE PROCEDURE GetVolunteersForClient (
    @ClientSSN CHAR(11)
)
AS
BEGIN
    SELECT DISTINCT p.Name, v.SSN
    FROM Volunteer v
    JOIN People p ON v.SSN = p.SSN  -- Join with People to get the Name
    JOIN Combines c ON v.SSN = c.Volunteer_SSN
    JOIN Care ca ON ca.Team_Name = c.Team_Name
    WHERE ca.Client_SSN = @ClientSSN;
END;
GO


-- 11. Retrieve Teams Founded After a Particular Date
CREATE PROCEDURE GetTeamsFoundedAfter (
    @Date DATE
)
AS
BEGIN
    SELECT Name
    FROM Teams
    WHERE Date_formed > @Date;
END;
GO

-- 12. Retrieve All People and Emergency Contact Information
CREATE PROCEDURE GetAllPeopleAndEmergencyContacts 
AS
BEGIN
    SELECT p.Name, p.SSN, p.Mailing_Address, p.Email_Address, p.Phone_Number,
           ec.Name AS Emergency_Contact_Name, ec.Phone_No AS Emergency_Contact_Phone, ec.Relation
    FROM People p
    LEFT JOIN EmergencyContact ec ON p.SSN = ec.People_SSN;
END;
GO

-- 13. Retrieve Donors Who Are Also Employees
CREATE PROCEDURE GetEmployeeDonors 
AS
BEGIN
    SELECT p.Name, d.SSN, d.Anonymous, SUM(c.Amount) AS Total_Donated
    FROM Donor d
    JOIN People p ON d.SSN = p.SSN  -- Join with People to get the Name
    JOIN Cheque c ON d.SSN = c.Donor_SSN
    JOIN Employee e ON d.SSN = e.SSN
    GROUP BY p.Name, d.SSN, d.Anonymous
    ORDER BY Total_Donated DESC;
END;
GO

-- 14. Increase Salary by 10% for Employees Reported by Multiple Teams
CREATE PROCEDURE IncreaseSalaryForMultiTeamEmployees 
AS
BEGIN
    UPDATE Employee
    SET Salary = Salary * 1.1
    WHERE SSN IN (
        SELECT Employee_SSN
        FROM Reports
        GROUP BY Employee_SSN
        HAVING COUNT(DISTINCT Team_name) > 1
    );
END;
GO

-- 15. Delete Clients Without Health Insurance and Low Transportation Importance
CREATE PROCEDURE DeleteClientsWithoutHealthInsurance 
AS
BEGIN
    -- First, delete records in `Care`, `Needs`, and `InsurancePolicy` tables that reference the clients to be deleted.
    DECLARE @ClientsToDelete TABLE (SSN CHAR(11));

    -- Identify clients to delete and store them in a temporary table
    INSERT INTO @ClientsToDelete (SSN)
    SELECT SSN 
    FROM Client
    WHERE SSN NOT IN (
        SELECT Client_SSN 
        FROM InsurancePolicy 
        WHERE Type = 'Health'
    )
    AND SSN IN (
        SELECT Client_SSN 
        FROM Needs 
        WHERE Importance_type = 'Transportation' AND Importance_score < 5
    );

    -- Delete related entries in `Care` table
    DELETE FROM Care
    WHERE Client_SSN IN (SELECT SSN FROM @ClientsToDelete);

    -- Delete related entries in `Needs` table
    DELETE FROM Needs
    WHERE Client_SSN IN (SELECT SSN FROM @ClientsToDelete);

    -- Delete related entries in `InsurancePolicy` table
    DELETE FROM InsurancePolicy
    WHERE Client_SSN IN (SELECT SSN FROM @ClientsToDelete);

    -- Finally, delete from `Client` table
    DELETE FROM Client
    WHERE SSN IN (SELECT SSN FROM @ClientsToDelete);

    PRINT 'Clients without health insurance and with low transportation importance have been deleted along with related records.';
END;
GO