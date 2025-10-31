-----------------------------------------------------------------------
-- PHASE 3: DWH DIMENSIONAL MODEL (DDL)
-----------------------------------------------------------------------

-- 1. Create the DWH Schema (assuming the previous safe cleanup script was run)
CREATE SCHEMA DWH;


-- 2. DWH.DimDate
CREATE TABLE DWH.DimDate (
    Date_ID INT PRIMARY KEY,
    Full_Date DATE NOT NULL,
    [Year] SMALLINT NOT NULL,
    [Quarter] VARCHAR(6) NOT NULL,
    [Month] TINYINT NOT NULL,
    Month_Name VARCHAR(10) NOT NULL,
    [Weekday] VARCHAR(10) NOT NULL
);

-- 3. DWH.DimPaymentMethod
CREATE TABLE DWH.DimPaymentMethod (
    PaymentMethod_ID VARCHAR(50) PRIMARY KEY,
    Payment_Method VARCHAR(100) NOT NULL,
    Paperless_Billing BIT NOT NULL,
    Auto_Payment BIT NOT NULL
);

-- 4. DWH.DimPlan
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

-- 5. DWH.DimCustomer
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

-- 6. DWH.FactCustomerActivity
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


-----------------------------------------------------------------------
-- PHASE 4: DWH DIMENSIONAL MODEL (DML - Simple Load from Cleansed)
-----------------------------------------------------------------------

-- A. Load DWH.DimDate
INSERT INTO DWH.DimDate 
SELECT Date_ID, Full_Date, [Year], [Quarter], [Month], Month_Name, [Weekday] 
FROM Cleansed.[Date];

-- B. Load DWH.DimPaymentMethod
INSERT INTO DWH.DimPaymentMethod 
SELECT PaymentMethod_ID, Payment_Method, Paperless_Billing, Auto_Payment 
FROM Cleansed.PaymentMethod;

-- C. Load DWH.DimCustomer
INSERT INTO DWH.DimCustomer 
SELECT Customer_ID, Customer_Name, Gender, Senior_Citizen, Partner, Dependents, Contract_Type, Churn_Flag 
FROM Cleansed.Customer;

-- D. Load DWH.DimPlan
INSERT INTO DWH.DimPlan 
SELECT Plan_ID, Internet_Service_Type, Phone_Service, Multiple_Lines, Tech_Support, Online_Security, Online_Backup, Device_Protection, Streaming_TV, Streaming_Movies, Plan_Price_Tier 
FROM Cleansed.Plan_Details;

-- E. Load DWH.FactCustomerActivity
INSERT INTO DWH.FactCustomerActivity 
SELECT Activity_ID, Customer_ID, Plan_ID, PaymentMethod_ID, Date_ID, Monthly_Charges, Total_Charges, Tenure_Months, Internet_Usage_GB, Calls_Minutes, Customer_Satisfaction_Score 
FROM Cleansed.Customer_Activity;

