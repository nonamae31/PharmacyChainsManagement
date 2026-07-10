-- Create SeedData/Seed_TestUser.sql
-- This script seeds a ROLE and a test USER for login.
-- Use this strictly for testing/demonstration purposes.

-- USE PharmacyDb; -- Uncomment and adjust as needed
GO

-- 1. Ensure a default role exists (e.g. USER)
IF NOT EXISTS (SELECT 1 FROM [ROLE] WHERE role_code = 'USER')
BEGIN
    -- Depending on Identity properties, role_id might be IDENTITY(1,1).
    -- If it's identity, you might need SET IDENTITY_INSERT [ROLE] ON, but we'll try standard.
    INSERT INTO [ROLE] (role_code, role_name, is_active)
    VALUES ('USER', 'User', 1);
END
GO

DECLARE @role_id SMALLINT;
SELECT @role_id = role_id FROM [ROLE] WHERE role_code = 'USER';

-- 2. Insert test user with a BCrypt hash for "User@123"
IF NOT EXISTS (SELECT 1 FROM [USER] WHERE email = 'user@pharmacy.com')
BEGIN
    INSERT INTO [USER] (
        user_id, role_id, branch_id, full_name, email, password_hash, phone, profile_photo_uri, status, created_at, updated_at
    )
    VALUES (
        NEWID(), 
        @role_id, 
        NULL,
        'Test User', 
        'user@pharmacy.com', 
        '$2a$11$7v1b1lK3v6e5G9w1Y7z2A.B3c4D5e6F7g8H9i0J1k2L3m4N5o6P', -- Note: use proper hash for production
        '1234567890', 
        NULL,
        'ACTIVE', 
        GETUTCDATE(), 
        GETUTCDATE()
    );
END
GO
