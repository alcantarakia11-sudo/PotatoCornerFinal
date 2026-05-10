-- ═══════════════════════════════════════════════════════════════════════════════
-- CREATE ACTIVITY LOG TABLE
-- ═══════════════════════════════════════════════════════════════════════════════
-- This table tracks all important system activities for admin monitoring

USE PotatoCornerDB;
GO

-- Create ActivityLog table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog')
BEGIN
    CREATE TABLE ActivityLog (
        LogID INT PRIMARY KEY IDENTITY(1,1),
        ActivityType VARCHAR(50) NOT NULL,  -- e.g., 'Order Status Change', 'User Registration', 'Admin Action'
        ActivityDescription NVARCHAR(500) NOT NULL,
        PerformedBy VARCHAR(100),  -- Username or 'System'
        TargetEntity VARCHAR(100),  -- e.g., 'Order #123', 'User: John Doe'
        IPAddress VARCHAR(50),
        Timestamp DATETIME DEFAULT GETDATE(),
        Severity VARCHAR(20) DEFAULT 'Info'  -- Info, Warning, Critical
    );
    
    PRINT 'ActivityLog table created successfully.';
END
ELSE
BEGIN
    PRINT 'ActivityLog table already exists.';
END
GO

-- Create index for faster queries
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ActivityLog_Timestamp')
BEGIN
    CREATE INDEX IX_ActivityLog_Timestamp ON ActivityLog(Timestamp DESC);
    PRINT 'Index IX_ActivityLog_Timestamp created.';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ActivityLog_ActivityType')
BEGIN
    CREATE INDEX IX_ActivityLog_ActivityType ON ActivityLog(ActivityType);
    PRINT 'Index IX_ActivityLog_ActivityType created.';
END
GO

-- Insert some sample data for testing
INSERT INTO ActivityLog (ActivityType, ActivityDescription, PerformedBy, TargetEntity, Severity)
VALUES 
    ('System', 'Activity Log system initialized', 'System', 'ActivityLog Table', 'Info'),
    ('Order Status Change', 'Order status changed from Pending to Confirmed', 'admin', 'Order #1', 'Info');

PRINT 'Sample activity logs inserted.';
GO

SELECT * FROM ActivityLog ORDER BY Timestamp DESC;
GO
