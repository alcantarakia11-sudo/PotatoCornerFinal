-- ═══════════════════════════════════════════════════════════════════════════════
-- Add PaymentVerified Column to Orders Table
-- ═══════════════════════════════════════════════════════════════════════════════
-- This adds a flag to track if payment has been verified by admin
-- ═══════════════════════════════════════════════════════════════════════════════

USE PotatoCornerDB;
GO

-- Check if column already exists
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('Orders') 
    AND name = 'PaymentVerified'
)
BEGIN
    ALTER TABLE Orders
    ADD PaymentVerified BIT DEFAULT 1;
    
    PRINT 'PaymentVerified column added successfully.';
END
ELSE
BEGIN
    PRINT 'PaymentVerified column already exists.';
END
GO

-- Update existing orders
-- Points payment = already verified (1)
-- GCash/Maya/GoTyme with reference = needs verification (0)
UPDATE Orders
SET PaymentVerified = CASE 
    WHEN PaymentMethod = 'Points' THEN 1
    WHEN PaymentReference IS NOT NULL THEN 0
    ELSE 1
END
WHERE PaymentVerified IS NULL;
GO

PRINT 'Existing orders updated.';
GO
