CREATE SCHEMA Staging;
DROP SCHEMA IF EXISTS Staging;

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

CREATE TABLE Staging.Stage_PaymentMethod (
    PaymentMethod_ID VARCHAR(50) PRIMARY KEY,
    Payment_Method TEXT,
    Paperless_Billing TEXT,
    Auto_Payment TEXT
);

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

CREATE TABLE Staging.Stage_Date_Raw (
    Date_ID_Raw VARCHAR(50) PRIMARY KEY, 
    Full_Date_Raw TEXT, 
	Year_Raw TEXT, 
	Quarter_Raw TEXT,
    Month_Raw TEXT, 
	Month_Name_Raw TEXT, 
	Weekday_Raw TEXT
);

