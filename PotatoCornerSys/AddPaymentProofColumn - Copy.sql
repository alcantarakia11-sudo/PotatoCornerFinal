-- Add PaymentProofImage column to Orders table
-- This will store the uploaded QR code payment proof from customers

USE PotatoCornerDB;
GO

-- Check if column already exists
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('Orders') 
               AND name = 'PaymentProofImage')
BEGIN
    ALTER TABLE Orders
    ADD PaymentProofImage NVARCHAR(MAX) NULL;
    
    PRINT 'PaymentProofImage column added successfully!';
END
ELSE
BEGIN
    PRINT 'PaymentProofImage column already exists.';
END
GO

-- Verify the change
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Orders' AND COLUMN_NAME = 'PaymentProofImage';
GO
