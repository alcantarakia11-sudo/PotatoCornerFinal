-- ========================================
-- ADD ORDER WORKFLOW ENHANCEMENT
-- ========================================
-- This script ensures the Orders table supports the new workflow statuses
-- Run this script in SQL Server Management Studio
-- ========================================

USE PotatoCorner_DB;
GO

PRINT '========================================';
PRINT 'ORDER WORKFLOW ENHANCEMENT';
PRINT '========================================';
PRINT '';

-- Check if DeliveryTime column exists (for marking delivered timestamp)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'DeliveryTime')
BEGIN
    PRINT 'Adding DeliveryTime column...';
    ALTER TABLE Orders
    ADD DeliveryTime DATETIME NULL;
    PRINT 'DeliveryTime column added successfully!';
END
ELSE
BEGIN
    PRINT 'DeliveryTime column already exists. Skipping...';
END

PRINT '';

-- Check if PickupTime column exists (for walk-in pickup timestamp)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Orders') AND name = 'PickupTime')
BEGIN
    PRINT 'Adding PickupTime column...';
    ALTER TABLE Orders
    ADD PickupTime DATETIME NULL;
    PRINT 'PickupTime column added successfully!';
END
ELSE
BEGIN
    PRINT 'PickupTime column already exists. Skipping...';
END

PRINT '';
PRINT '========================================';
PRINT 'ORDER WORKFLOW STATUSES';
PRINT '========================================';
PRINT '';
PRINT 'The system now supports the following order statuses:';
PRINT '';
PRINT 'FOR DELIVERY ORDERS:';
PRINT '  1. Pending - New order placed by customer';
PRINT '  2. Confirmed - Admin confirmed the order';
PRINT '  3. Out for Delivery - Admin marked order as out for delivery';
PRINT '  4. Delivered - Customer marked order as delivered';
PRINT '  5. Cancelled - Order was cancelled';
PRINT '';
PRINT 'FOR WALK-IN ORDERS:';
PRINT '  1. Pending - New order placed by customer';
PRINT '  2. Confirmed - Admin confirmed the order';
PRINT '  3. Picked Up - Admin marked order as picked up by customer';
PRINT '  4. Cancelled - Order was cancelled';
PRINT '';

-- Update any old "Confirmed" delivery orders to show proper workflow
PRINT 'Checking for orders that need status updates...';

-- Count orders by status
SELECT 
    OrderStatus,
    DeliveryType,
    COUNT(*) AS OrderCount
FROM Orders
GROUP BY OrderStatus, DeliveryType
ORDER BY DeliveryType, OrderStatus;

PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION';
PRINT '========================================';
PRINT 'Checking Orders table structure...';
PRINT '';

-- Show the Orders table structure
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Orders'
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '========================================';
PRINT 'SETUP COMPLETE!';
PRINT '========================================';
PRINT 'The Orders table now supports:';
PRINT '- DeliveryTime column (timestamp when customer marks delivered)';
PRINT '- PickupTime column (timestamp when admin marks picked up)';
PRINT '- Enhanced order workflow with multiple statuses';
PRINT '';
PRINT 'Admin can now:';
PRINT '1. Confirm new orders';
PRINT '2. Mark delivery orders as "Out for Delivery"';
PRINT '3. Mark walk-in orders as "Picked Up"';
PRINT '';
PRINT 'Customers can now:';
PRINT '1. Mark delivery orders as "Delivered" when received';
PRINT '2. See real-time order status updates';
PRINT '3. Cancel orders within 10 minutes (if not yet out for delivery)';
PRINT '========================================';
GO
