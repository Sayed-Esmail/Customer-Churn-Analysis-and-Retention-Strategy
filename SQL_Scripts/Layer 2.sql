-- PHASE 2: CLEANSING LAYER (DDL)
-----------------------------------------------------------------------
-- Create the Cleansed Schema
CREATE SCHEMA Cleansed;

-- Cleansed.Customer
CREATE TABLE Cleansed.Customer (
    Customer_ID VARCHAR(50) PRIMARY KEY,
    Customer_Name VARCHAR(255),
    Gender VARCHAR(10),
    Senior_Citizen BIT,       
    Partner BIT,             
    Dependents BIT,           
    Contract_Type VARCHAR(50),
    Churn_Flag BIT NOT NULL   
);

-- Cleansed.Plan_Details
CREATE TABLE Cleansed.Plan_Details (
    Plan_ID VARCHAR(50) PRIMARY KEY,
    Internet_Service_Type VARCHAR(50),
    Phone_Service VARCHAR(50),
    Multiple_Lines BIT,
    Tech_Support BIT,
    Online_Security BIT,
    Online_Backup BIT,
    Device_Protection BIT,
    Streaming_TV BIT,
    Streaming_Movies BIT,
    Plan_Price_Tier VARCHAR(50)
);

-- Cleansed.PaymentMethod
CREATE TABLE Cleansed.PaymentMethod (
    PaymentMethod_ID VARCHAR(50) PRIMARY KEY,
    Payment_Method VARCHAR(100) NOT NULL,
    Paperless_Billing BIT NOT NULL,
    Auto_Payment BIT NOT NULL       
);

-- Cleansed.Date
CREATE TABLE Cleansed.[Date] ( 
    Date_ID INT PRIMARY KEY,
    Full_Date DATE NOT NULL,
    [Year] SMALLINT NOT NULL,
    [Quarter] VARCHAR(6) NOT NULL,
    [Month] TINYINT NOT NULL,
    Month_Name VARCHAR(10) NOT NULL,
    [Weekday] VARCHAR(10) NOT NULL
);

-- Cleansed.Customer_Activity (Fact table metrics)
CREATE TABLE Cleansed.Customer_Activity (
    Activity_ID VARCHAR(50) PRIMARY KEY,
    Customer_ID VARCHAR(50) NOT NULL,
    Plan_ID VARCHAR(50) NOT NULL,
    PaymentMethod_ID VARCHAR(50) NOT NULL,
    Date_ID INT NOT NULL,
    Monthly_Charges DECIMAL(10, 2) NOT NULL,
    Total_Charges DECIMAL(10, 2) NOT NULL,
    Tenure_Months SMALLINT NOT NULL,
    Internet_Usage_GB DECIMAL(10, 2),
    Calls_Minutes DECIMAL(10, 2),
    Customer_Satisfaction_Score DECIMAL(10, 2)
);

-- PHASE 2: CLEANSING LAYER (Transformation Logic Applied)
-----------------------------------------------------------------------

-- Load Cleansed.Date
INSERT INTO Cleansed.[Date] (Date_ID, Full_Date, [Year], [Quarter], [Month], Month_Name, [Weekday])
SELECT
    CAST(CONVERT(VARCHAR(50), Date_ID_Raw) AS INT), 
    CONVERT(DATE, CONVERT(VARCHAR(50), Full_Date_Raw), 103), 
    CAST(CONVERT(VARCHAR(50), Year_Raw) AS SMALLINT), 
    Quarter_Raw,
    CAST(CONVERT(VARCHAR(50), Month_Raw) AS TINYINT), 
    Month_Name_Raw,
    Weekday_Raw
FROM Staging.Stage_Date_Raw;

-- Load Cleansed.PaymentMethod 
INSERT INTO Cleansed.PaymentMethod (PaymentMethod_ID, Payment_Method, Paperless_Billing, Auto_Payment)
SELECT
    PaymentMethod_ID,
    Payment_Method,
    CASE WHEN CONVERT(VARCHAR(50), Paperless_Billing) = 'yes' THEN 1 ELSE 0 END AS Paperless_Billing,
    CASE WHEN CONVERT(VARCHAR(50), Auto_Payment) = 'Yes' THEN 1 ELSE 0 END AS Auto_Payment
FROM Staging.Stage_PaymentMethod;

-- Load Cleansed.Customer 
INSERT INTO Cleansed.Customer (Customer_ID, Customer_Name, Gender, Senior_Citizen, Partner, Dependents, Contract_Type, Churn_Flag)
SELECT
    Customer_ID,
    Customer_Name,
    Gender,
    CAST(CONVERT(VARCHAR(50), Senior_Citizen_Flag) AS BIT), 
    CASE WHEN CONVERT(VARCHAR(50), Partner) = 'Yes' THEN 1 ELSE 0 END AS Partner,
    CASE WHEN CONVERT(VARCHAR(50), Dependents) = 'Yes' THEN 1 ELSE 0 END AS Dependents,
    Contract_Type,
    CASE WHEN CONVERT(VARCHAR(50), Churn_Flag_Raw) = 'Yes' THEN 1 ELSE 0 END AS Churn_Flag
FROM Staging.Stage_Customer_Data;


-- Load Cleansed.Plan_Details 
INSERT INTO Cleansed.Plan_Details (Plan_ID, Internet_Service_Type, Phone_Service, Multiple_Lines, Tech_Support, Online_Security, Online_Backup, Device_Protection, Streaming_TV, Streaming_Movies, Plan_Price_Tier)
SELECT
    Plan_ID,
    Internet_Service_Type,
    Phone_Service,
    CASE WHEN CONVERT(VARCHAR(50), Multiple_Lines) = 'yes' THEN 1 ELSE 0 END AS Multiple_Lines,
    CASE WHEN CONVERT(VARCHAR(50), Tech_Support) = 'yes' THEN 1 ELSE 0 END AS Tech_Support,
    CASE WHEN CONVERT(VARCHAR(50), Online_Security) = 'yes' THEN 1 ELSE 0 END AS Online_Security,
    CASE WHEN CONVERT(VARCHAR(50), Online_Backup) = 'yes' THEN 1 ELSE 0 END AS Online_Backup,
    CASE WHEN CONVERT(VARCHAR(50), Device_Protection) = 'yes' THEN 1 ELSE 0 END AS Device_Protection,
    CASE WHEN CONVERT(VARCHAR(50), Streaming_TV) = 'yes' THEN 1 ELSE 0 END AS Streaming_TV,
    CASE WHEN CONVERT(VARCHAR(50), Streaming_Movies) = 'yes' THEN 1 ELSE 0 END AS Streaming_Movies,
    Plan_Price_Tier
FROM Staging.Stage_Plan_Details;


-- Load Cleansed.Customer_Activity
INSERT INTO Cleansed.Customer_Activity (Activity_ID, Customer_ID, Plan_ID, PaymentMethod_ID, Date_ID, Monthly_Charges, Total_Charges, Tenure_Months, Internet_Usage_GB, Calls_Minutes, Customer_Satisfaction_Score)
SELECT
    Activity_ID,
    Customer_ID,
    Plan_ID,
    PaymentMethod_ID,
    CAST(CONVERT(VARCHAR(50), Date_ID) AS INT),
    CAST(CONVERT(VARCHAR(50), Monthly_Charges) AS DECIMAL(10, 2)),
    CAST(
        ISNULL(
            NULLIF(CONVERT(VARCHAR(50), Total_Charges), ''), 
        '0') 
    AS DECIMAL(10, 2)) AS Total_Charges,
    CAST(CONVERT(VARCHAR(50), Tenure_Months) AS SMALLINT),
    CAST(CONVERT(VARCHAR(50), Internet_Usage_GB) AS DECIMAL(10, 2)),
    CAST(CONVERT(VARCHAR(50), Calls_Minutes) AS DECIMAL(10, 2)),
    CAST(CONVERT(VARCHAR(50), Customer_Satisfaction_Score) AS DECIMAL(10, 2))
FROM Staging.Stage_Customer_Activity;