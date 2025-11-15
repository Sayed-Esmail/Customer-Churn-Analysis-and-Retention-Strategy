-- =====================================================================
-- COMPLETE LAYER 1: STAGING LAYER (SETUP + DATA LOAD)
-- =====================================================================

-- STEP 1: Clean up existing objects
-- =====================================================================
IF OBJECT_ID('Staging.Stage_Customer_Activity', 'U') IS NOT NULL
    DROP TABLE Staging.Stage_Customer_Activity;

IF OBJECT_ID('Staging.Stage_Date_Raw', 'U') IS NOT NULL
    DROP TABLE Staging.Stage_Date_Raw;

IF OBJECT_ID('Staging.Stage_PaymentMethod', 'U') IS NOT NULL
    DROP TABLE Staging.Stage_PaymentMethod;

IF OBJECT_ID('Staging.Stage_Plan_Details', 'U') IS NOT NULL
    DROP TABLE Staging.Stage_Plan_Details;

IF OBJECT_ID('Staging.Stage_Customer_Data', 'U') IS NOT NULL
    DROP TABLE Staging.Stage_Customer_Data;
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'Staging')
    DROP SCHEMA Staging;
GO

-- STEP 2: Create Staging Schema
-- =====================================================================
CREATE SCHEMA Staging;
GO

-- STEP 3: Create Staging Tables
-- =====================================================================

-- A. Stage_Customer_Data
CREATE TABLE Staging.Stage_Customer_Data (
    Customer_ID VARCHAR(50) PRIMARY KEY, 
    Customer_Name TEXT,
    Gender TEXT,
    Senior_Citizen_Flag TEXT,
    Partner TEXT,
    Dependents TEXT,
    Contract_Type TEXT,
    Churn_Flag_Raw TEXT
);

-- B. Stage_Plan_Details
CREATE TABLE Staging.Stage_Plan_Details (
    Plan_ID VARCHAR(50) PRIMARY KEY, 
    Internet_Service_Type TEXT,
    Phone_Service TEXT,            
    Multiple_Lines TEXT,           
    Tech_Support TEXT,             
    Online_Security TEXT,          
    Online_Backup TEXT,           
    Device_Protection TEXT,        
    Streaming_TV TEXT,            
    Streaming_Movies TEXT,        
    Plan_Price_Tier TEXT
);

-- C. Stage_PaymentMethod
CREATE TABLE Staging.Stage_PaymentMethod (
    PaymentMethod_ID VARCHAR(50) PRIMARY KEY,
    Payment_Method TEXT,
    Paperless_Billing TEXT,
    Auto_Payment TEXT
);

-- D. Stage_Date_Raw
CREATE TABLE Staging.Stage_Date_Raw (
    Date_ID_Raw VARCHAR(50) PRIMARY KEY, 
    Full_Date_Raw TEXT, 
    Year_Raw TEXT, 
    Quarter_Raw TEXT,
    Month_Raw TEXT, 
    Month_Name_Raw TEXT, 
    Weekday_Raw TEXT
);

-- E. Stage_Customer_Activity
CREATE TABLE Staging.Stage_Customer_Activity (
    Activity_ID VARCHAR(50) PRIMARY KEY,
    Customer_ID TEXT,
    Plan_ID TEXT,
    PaymentMethod_ID TEXT,  
    Date_ID TEXT,           
    Monthly_Charges TEXT,
    Total_Charges TEXT,
    Tenure_Months TEXT,
    Internet_Usage_GB TEXT,
    Calls_Minutes TEXT,
    Customer_Satisfaction_Score TEXT
);
GO

-- STEP 4: Load Data using BULK INSERT
-- =====================================================================

-- 1. Load Dim_Customer.csv
BULK INSERT Staging.Stage_Customer_Data 
FROM 'D:\Project\Dim_Customer.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- 2. Load Dim_Plan.csv
BULK INSERT Staging.Stage_Plan_Details 
FROM 'D:\Project\Dim_Plan.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- 3. Load Dim_PaymentMethod.csv
BULK INSERT Staging.Stage_PaymentMethod 
FROM 'D:\Project\Dim_PaymentMethod.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- 4. Load Dim_Date.csv
BULK INSERT Staging.Stage_Date_Raw 
FROM 'D:\Project\Dim_Date.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- 5. Load Fact_Customer_Activity.csv
BULK INSERT Staging.Stage_Customer_Activity 
FROM 'D:\Project\Fact_Customer_Activity.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- STEP 5: Verification - Check row counts
-- =====================================================================
SELECT 'Stage_Customer_Data' AS TableName, COUNT(*) AS RecordCount FROM Staging.Stage_Customer_Data
UNION ALL
SELECT 'Stage_Plan_Details' AS TableName, COUNT(*) AS RecordCount FROM Staging.Stage_Plan_Details
UNION ALL
SELECT 'Stage_PaymentMethod' AS TableName, COUNT(*) AS RecordCount FROM Staging.Stage_PaymentMethod
UNION ALL
SELECT 'Stage_Date_Raw' AS TableName, COUNT(*) AS RecordCount FROM Staging.Stage_Date_Raw
UNION ALL
SELECT 'Stage_Customer_Activity' AS TableName, COUNT(*) AS RecordCount FROM Staging.Stage_Customer_Activity;
GO

-- STEP 6: Preview data (optional)
-- =====================================================================
SELECT TOP 5 * FROM Staging.Stage_Customer_Data;
SELECT TOP 5 * FROM Staging.Stage_Plan_Details;
SELECT TOP 5 * FROM Staging.Stage_PaymentMethod;
SELECT TOP 5 * FROM Staging.Stage_Date_Raw;
SELECT TOP 5 * FROM Staging.Stage_Customer_Activity;
GO


-- PHASE 2: CLEANSING LAYER (DDL)
-----------------------------------------------------------------------
-- Create the Cleansed Schema
CREATE SCHEMA Cleansed;
GO

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
GO

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
GO

-- Load Cleansed.PaymentMethod 
INSERT INTO Cleansed.PaymentMethod (PaymentMethod_ID, Payment_Method, Paperless_Billing, Auto_Payment)
SELECT
    PaymentMethod_ID,
    Payment_Method,
    CASE WHEN CONVERT(VARCHAR(50), Paperless_Billing) = 'yes' THEN 1 ELSE 0 END AS Paperless_Billing,
    CASE WHEN CONVERT(VARCHAR(50), Auto_Payment) = 'Yes' THEN 1 ELSE 0 END AS Auto_Payment
FROM Staging.Stage_PaymentMethod;
GO

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
GO

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
GO

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
            '0'
        ) 
        AS DECIMAL(10, 2)
    ) AS Total_Charges,
    CAST(CONVERT(VARCHAR(50), Tenure_Months) AS SMALLINT),
    CAST(CONVERT(VARCHAR(50), Internet_Usage_GB) AS DECIMAL(10, 2)),
    CAST(CONVERT(VARCHAR(50), Calls_Minutes) AS DECIMAL(10, 2)),
    CAST(CONVERT(VARCHAR(50), Customer_Satisfaction_Score) AS DECIMAL(10, 2))
FROM Staging.Stage_Customer_Activity;
GO

-- Verification: Check row counts in Cleansed layer
SELECT 'Customer' AS TableName, COUNT(*) AS RecordCount FROM Cleansed.Customer
UNION ALL
SELECT 'Plan_Details' AS TableName, COUNT(*) AS RecordCount FROM Cleansed.Plan_Details
UNION ALL
SELECT 'PaymentMethod' AS TableName, COUNT(*) AS RecordCount FROM Cleansed.PaymentMethod
UNION ALL
SELECT 'Date' AS TableName, COUNT(*) AS RecordCount FROM Cleansed.[Date]
UNION ALL
SELECT 'Customer_Activity' AS TableName, COUNT(*) AS RecordCount FROM Cleansed.Customer_Activity;
GO


-- =====================================================================
-- LAYER 3: DATA WAREHOUSE DIMENSIONAL MODEL
-- =====================================================================

-- STEP 1: Clean up existing objects
-- =====================================================================
IF OBJECT_ID('DWH.FactCustomerActivity', 'U') IS NOT NULL
    DROP TABLE DWH.FactCustomerActivity;

IF OBJECT_ID('DWH.DimCustomer', 'U') IS NOT NULL
    DROP TABLE DWH.DimCustomer;

IF OBJECT_ID('DWH.DimPlan', 'U') IS NOT NULL
    DROP TABLE DWH.DimPlan;

IF OBJECT_ID('DWH.DimPaymentMethod', 'U') IS NOT NULL
    DROP TABLE DWH.DimPaymentMethod;

IF OBJECT_ID('DWH.DimDate', 'U') IS NOT NULL
    DROP TABLE DWH.DimDate;
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'DWH')
    DROP SCHEMA DWH;
GO

-- STEP 2: Create DWH Schema
-- =====================================================================
CREATE SCHEMA DWH;
GO

-- STEP 3: Create Dimension Tables
-- =====================================================================

-- 1. DWH.DimDate
CREATE TABLE DWH.DimDate (
    Date_ID INT PRIMARY KEY,
    Full_Date DATE NOT NULL,
    [Year] SMALLINT NOT NULL,
    [Quarter] VARCHAR(6) NOT NULL,
    [Month] TINYINT NOT NULL,
    Month_Name VARCHAR(10) NOT NULL,
    [Weekday] VARCHAR(10) NOT NULL
);

-- 2. DWH.DimPaymentMethod
CREATE TABLE DWH.DimPaymentMethod (
    PaymentMethod_ID VARCHAR(50) PRIMARY KEY,
    Payment_Method VARCHAR(100) NOT NULL,
    Paperless_Billing BIT NOT NULL,
    Auto_Payment BIT NOT NULL
);

-- 3. DWH.DimPlan
CREATE TABLE DWH.DimPlan (
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

-- 4. DWH.DimCustomer
CREATE TABLE DWH.DimCustomer (
    Customer_ID VARCHAR(50) PRIMARY KEY,
    Customer_Name VARCHAR(255),
    Gender VARCHAR(10),
    Senior_Citizen BIT,
    Partner BIT,
    Dependents BIT,
    Contract_Type VARCHAR(50),
    Churn_Flag BIT NOT NULL
);

-- 5. DWH.FactCustomerActivity (with Foreign Keys)
CREATE TABLE DWH.FactCustomerActivity (
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
    Customer_Satisfaction_Score DECIMAL(10, 2),

    -- Define Foreign Keys
    FOREIGN KEY (Customer_ID) REFERENCES DWH.DimCustomer(Customer_ID),
    FOREIGN KEY (Plan_ID) REFERENCES DWH.DimPlan(Plan_ID),
    FOREIGN KEY (PaymentMethod_ID) REFERENCES DWH.DimPaymentMethod(PaymentMethod_ID),
    FOREIGN KEY (Date_ID) REFERENCES DWH.DimDate(Date_ID)
);
GO

-- STEP 4: Load Dimension Tables from Cleansed Layer
-- =====================================================================

-- A. Load DWH.DimDate
INSERT INTO DWH.DimDate 
SELECT Date_ID, Full_Date, [Year], [Quarter], [Month], Month_Name, [Weekday] 
FROM Cleansed.[Date];
GO

-- B. Load DWH.DimPaymentMethod
INSERT INTO DWH.DimPaymentMethod 
SELECT PaymentMethod_ID, Payment_Method, Paperless_Billing, Auto_Payment 
FROM Cleansed.PaymentMethod;
GO

-- C. Load DWH.DimCustomer
INSERT INTO DWH.DimCustomer 
SELECT Customer_ID, Customer_Name, Gender, Senior_Citizen, Partner, Dependents, Contract_Type, Churn_Flag 
FROM Cleansed.Customer;
GO

-- D. Load DWH.DimPlan
INSERT INTO DWH.DimPlan 
SELECT Plan_ID, Internet_Service_Type, Phone_Service, Multiple_Lines, Tech_Support, Online_Security, Online_Backup, Device_Protection, Streaming_TV, Streaming_Movies, Plan_Price_Tier 
FROM Cleansed.Plan_Details;
GO

-- E. Load DWH.FactCustomerActivity
INSERT INTO DWH.FactCustomerActivity 
SELECT Activity_ID, Customer_ID, Plan_ID, PaymentMethod_ID, Date_ID, Monthly_Charges, Total_Charges, Tenure_Months, Internet_Usage_GB, Calls_Minutes, Customer_Satisfaction_Score 
FROM Cleansed.Customer_Activity;
GO

-- STEP 5: Verification - Check row counts
-- =====================================================================
SELECT 'DimDate' AS TableName, COUNT(*) AS RecordCount FROM DWH.DimDate
UNION ALL
SELECT 'DimPaymentMethod' AS TableName, COUNT(*) AS RecordCount FROM DWH.DimPaymentMethod
UNION ALL
SELECT 'DimCustomer' AS TableName, COUNT(*) AS RecordCount FROM DWH.DimCustomer
UNION ALL
SELECT 'DimPlan' AS TableName, COUNT(*) AS RecordCount FROM DWH.DimPlan
UNION ALL
SELECT 'FactCustomerActivity' AS TableName, COUNT(*) AS RecordCount FROM DWH.FactCustomerActivity;
GO

-- STEP 6: Verify Foreign Key Relationships
-- =====================================================================
SELECT 
    fk.name AS ForeignKeyName,
    tp.name AS ParentTable,
    cp.name AS ParentColumn,
    tr.name AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM sys.foreign_keys AS fk
INNER JOIN sys.tables AS tp ON fk.parent_object_id = tp.object_id
INNER JOIN sys.tables AS tr ON fk.referenced_object_id = tr.object_id
INNER JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns AS cp ON fkc.parent_column_id = cp.column_id AND fkc.parent_object_id = cp.object_id
INNER JOIN sys.columns AS cr ON fkc.referenced_column_id = cr.column_id AND fkc.referenced_object_id = cr.object_id
WHERE tp.schema_id = SCHEMA_ID('DWH');
GO






