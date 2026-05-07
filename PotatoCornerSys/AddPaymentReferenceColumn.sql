-- Add PaymentReference column to Orders table
-- This stores the unique reference number for simulated payment verification

USE PotatoCornerDB;
GO

-- Check if column already exists
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('Orders') 
               AND name = 'PaymentReference')
BEGIN
    ALTER TABLE Orders
    ADD PaymentReference NVARCHAR(50) NULL;
    
    PRINT 'PaymentReference column added successfully!';
END
ELSE
BEGIN
    PRINT 'PaymentReference column already exists.';
END
GO

-- Verify the change
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Orders' AND COLUMN_NAME = 'PaymentReference';
GO
