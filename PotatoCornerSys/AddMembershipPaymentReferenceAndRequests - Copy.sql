-- =============================================
-- Potato Corner Membership Payment Migration
-- Uses existing dbo.Membership table (idempotent)
-- =============================================

USE PotatoCorner_DB;
GO

-- Keep for order compatibility (if not yet added)
IF COL_LENGTH('dbo.Orders', 'PaymentReference') IS NULL
BEGIN
    ALTER TABLE dbo.Orders
    ADD PaymentReference NVARCHAR(50) NULL;
END
GO

-- Add required columns to existing Membership table
IF COL_LENGTH('dbo.Membership', 'PaymentMethod') IS NULL
BEGIN
    ALTER TABLE dbo.Membership
    ADD PaymentMethod NVARCHAR(50) NULL;
END
GO

IF COL_LENGTH('dbo.Membership', 'AmountPaid') IS NULL
BEGIN
    ALTER TABLE dbo.Membership
    ADD AmountPaid DECIMAL(10,2) NULL;
END
GO

IF COL_LENGTH('dbo.Membership', 'PaymentReference') IS NULL
BEGIN
    ALTER TABLE dbo.Membership
    ADD PaymentReference NVARCHAR(50) NULL;
END
GO

IF COL_LENGTH('dbo.Membership', 'RequestStatus') IS NULL
BEGIN
    ALTER TABLE dbo.Membership
    ADD RequestStatus NVARCHAR(30) NOT NULL
        CONSTRAINT DF_Membership_RequestStatus DEFAULT ('Confirmed');
END
GO

IF COL_LENGTH('dbo.Membership', 'RequestedDate') IS NULL
BEGIN
    ALTER TABLE dbo.Membership
    ADD RequestedDate DATETIME NOT NULL
        CONSTRAINT DF_Membership_RequestedDate DEFAULT (GETDATE());
END
GO

IF COL_LENGTH('dbo.Membership', 'ConfirmedDate') IS NULL
BEGIN
    ALTER TABLE dbo.Membership
    ADD ConfirmedDate DATETIME NULL;
END
GO

-- Backfill existing records to keep old members valid
UPDATE dbo.Membership
SET RequestStatus = 'Confirmed'
WHERE RequestStatus IS NULL;
GO

UPDATE dbo.Membership
SET RequestedDate = ISNULL(RegistrationDate, GETDATE())
WHERE RequestedDate IS NULL;
GO

UPDATE dbo.Membership
SET ConfirmedDate = ISNULL(ConfirmedDate, RegistrationDate)
WHERE RequestStatus = 'Confirmed' AND ConfirmedDate IS NULL;
GO

-- Helpful indexes
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Membership')
      AND name = 'IX_Membership_CustomerID'
)
BEGIN
    CREATE INDEX IX_Membership_CustomerID
    ON dbo.Membership(CustomerID);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Membership')
      AND name = 'IX_Membership_RequestStatus_RequestedDate'
)
BEGIN
    CREATE INDEX IX_Membership_RequestStatus_RequestedDate
    ON dbo.Membership(RequestStatus, RequestedDate);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Membership')
      AND name = 'IX_Membership_PaymentReference'
)
BEGIN
    CREATE INDEX IX_Membership_PaymentReference
    ON dbo.Membership(PaymentReference);
END
GO

PRINT 'Membership table migration completed successfully.';
GO
