-- ═══════════════════════════════════════════════════════════════════════════════
-- Add "Pending Payment Verification" to OrderStatus CHECK Constraint
-- ═══════════════════════════════════════════════════════════════════════════════
-- This script updates the OrderStatus CHECK constraint to include the new
-- "Pending Payment Verification" status for payment reference verification.
-- ═══════════════════════════════════════════════════════════════════════════════

USE PotatoCornerDB;
GO

-- Step 1: Drop the existing CHECK constraint
DECLARE @ConstraintName NVARCHAR(200);

-- Find the constraint name (it might be CHK_OrderStatus or CK_Orders_OrderStatus)
SELECT @ConstraintName = name
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('Orders')
AND definition LIKE '%OrderStatus%';

IF @ConstraintName IS NOT NULL
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = 'ALTER TABLE Orders DROP CONSTRAINT ' + QUOTENAME(@ConstraintName);
    EXEC sp_executesql @SQL;
    PRINT 'Dropped constraint: ' + @ConstraintName;
END
ELSE
BEGIN
    PRINT 'No OrderStatus constraint found to drop.';
END
GO

-- Step 2: Add the updated CHECK constraint with the new status
ALTER TABLE Orders
ADD CONSTRAINT CHK_OrderStatus CHECK (OrderStatus IN (
    'Pending',
    'Pending Payment Verification',
    'Confirmed',
    'Out for Delivery',
    'Delivered',
    'Picked Up',
    'No Show',
    'Cancelled'
));
GO

PRINT 'Successfully added "Pending Payment Verification" to OrderStatus constraint.';
GO

-- Step 3: Verify the constraint was added
SELECT 
    name AS ConstraintName,
    definition AS ConstraintDefinition
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID('Orders')
AND definition LIKE '%OrderStatus%';
GO
