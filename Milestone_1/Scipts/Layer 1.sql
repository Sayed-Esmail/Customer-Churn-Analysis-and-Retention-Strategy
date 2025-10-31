
-----------------------------------------------------------------------
-- PHASE 1: DATA EXTRACTION (Full Absolute Path)
-----------------------------------------------------------------------

-- 1. Dim_Customer.csv
BULK INSERT Staging.Stage_Customer_Data 
FROM 'C:\Users\doaaa\Downloads\DEPI Project\Dim_Customer.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);


-- 2. Dim_Plan.csv
BULK INSERT Staging.Stage_Plan_Details 
FROM 'C:\Users\doaaa\Downloads\DEPI Project\Dim_Plan.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

-- 3. Dim_PaymentMethod.csv
BULK INSERT Staging.Stage_PaymentMethod 
FROM 'C:\Users\doaaa\Downloads\DEPI Project\Dim_PaymentMethod.csv'
WITH (
    FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n'
);

-- 4. Dim_Date.csv
BULK INSERT Staging.Stage_Date_Raw 
FROM 'C:\Users\doaaa\Downloads\DEPI Project\Dim_Date.csv'
WITH (
    FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n'
);

-- 5. Fact_Customer_Activity.csv
BULK INSERT Staging.Stage_Customer_Activity 
FROM 'C:\Users\doaaa\Downloads\DEPI Project\Fact_Customer_Activity.csv'
WITH (
    FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n'
);
