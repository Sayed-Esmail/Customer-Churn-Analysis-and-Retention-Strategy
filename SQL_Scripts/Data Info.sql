-- Check schemas in the db
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME;


-- Check all data types 
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH AS Max_Length,
    CASE WHEN IS_NULLABLE = 'YES' THEN 'NULLABLE' ELSE 'NOT NULL' END AS Nullability
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_SCHEMA = 'DWH'
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;


-- Unique values
-- Unique values for DWH.DimDate attributes
SELECT DISTINCT [Year] FROM DWH.DimDate;
SELECT DISTINCT [Quarter] FROM DWH.DimDate;
SELECT DISTINCT Month_Name FROM DWH.DimDate;
SELECT DISTINCT [Weekday] FROM DWH.DimDate;

-- Unique values for DWH.DimPaymentMethod attributes
SELECT DISTINCT Payment_Method FROM DWH.DimPaymentMethod;
SELECT DISTINCT Paperless_Billing FROM DWH.DimPaymentMethod; -- Expected: 0, 1
SELECT DISTINCT Auto_Payment FROM DWH.DimPaymentMethod;      -- Expected: 0, 1

-- Unique values for DWH.DimCustomer attributes
SELECT DISTINCT Gender FROM DWH.DimCustomer;
SELECT DISTINCT Senior_Citizen FROM DWH.DimCustomer; -- Expected: 0, 1
SELECT DISTINCT Partner FROM DWH.DimCustomer;        -- Expected: 0, 1
SELECT DISTINCT Dependents FROM DWH.DimCustomer;     -- Expected: 0, 1
SELECT DISTINCT Contract_Type FROM DWH.DimCustomer;
SELECT DISTINCT Churn_Flag FROM DWH.DimCustomer;     -- Expected: 0, 1

-- Unique values for DWH.DimPlan attributes
SELECT DISTINCT Internet_Service_Type FROM DWH.DimPlan;
SELECT DISTINCT Phone_Service FROM DWH.DimPlan;
SELECT DISTINCT Multiple_Lines FROM DWH.DimPlan;     -- Expected: 0, 1
SELECT DISTINCT Tech_Support FROM DWH.DimPlan;       -- Expected: 0, 1
SELECT DISTINCT Online_Security FROM DWH.DimPlan;    -- Expected: 0, 1
SELECT DISTINCT Online_Backup FROM DWH.DimPlan;      -- Expected: 0, 1
SELECT DISTINCT Device_Protection FROM DWH.DimPlan;  -- Expected: 0, 1
SELECT DISTINCT Streaming_TV FROM DWH.DimPlan;       -- Expected: 0, 1
SELECT DISTINCT Streaming_Movies FROM DWH.DimPlan;   -- Expected: 0, 1
SELECT DISTINCT Plan_Price_Tier FROM DWH.DimPlan;

