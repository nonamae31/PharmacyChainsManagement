-- Seed_TestUser.sql
-- Insert 4 Roles
IF NOT EXISTS (SELECT 1 FROM [ROLE] WHERE role_code = 'BUSINESS_ADMIN')
    INSERT INTO [ROLE] (role_id, role_code, role_name, is_active) VALUES (2, 'BUSINESS_ADMIN', 'Business Admin', 1);

IF NOT EXISTS (SELECT 1 FROM [ROLE] WHERE role_code = 'BRANCH_MANAGER')
    INSERT INTO [ROLE] (role_id, role_code, role_name, is_active) VALUES (3, 'BRANCH_MANAGER', 'Branch Manager', 1);

IF NOT EXISTS (SELECT 1 FROM [ROLE] WHERE role_code = 'STAFF')
    INSERT INTO [ROLE] (role_id, role_code, role_name, is_active) VALUES (4, 'STAFF', 'Staff', 1);

IF NOT EXISTS (SELECT 1 FROM [ROLE] WHERE role_code = 'INVENTORY_MANAGER')
    INSERT INTO [ROLE] (role_id, role_code, role_name, is_active) VALUES (5, 'INVENTORY_MANAGER', 'Inventory Manager', 1);

DECLARE @admin_id SMALLINT, @manager_id SMALLINT, @staff_id SMALLINT, @inventory_id SMALLINT;
SELECT @admin_id = role_id FROM [ROLE] WHERE role_code = 'BUSINESS_ADMIN';
SELECT @manager_id = role_id FROM [ROLE] WHERE role_code = 'BRANCH_MANAGER';
SELECT @staff_id = role_id FROM [ROLE] WHERE role_code = 'STAFF';
SELECT @inventory_id = role_id FROM [ROLE] WHERE role_code = 'INVENTORY_MANAGER';

DECLARE @hash NVARCHAR(255) = '$2a$11$7v1b1lK3v6e5G9w1Y7z2A.B3c4D5e6F7g8H9i0J1k2L3m4N5o6P'; -- User@123

IF NOT EXISTS (SELECT 1 FROM [USER] WHERE email = 'admin@pharmacy.com')
    INSERT INTO [USER] (user_id, role_id, full_name, email, password_hash, status, created_at, updated_at)
    VALUES (NEWID(), @admin_id, 'Business Admin', 'admin@pharmacy.com', @hash, 'ACTIVE', GETUTCDATE(), GETUTCDATE());

IF NOT EXISTS (SELECT 1 FROM [USER] WHERE email = 'manager@pharmacy.com')
    INSERT INTO [USER] (user_id, role_id, full_name, email, password_hash, status, created_at, updated_at)
    VALUES (NEWID(), @manager_id, 'Branch Manager', 'manager@pharmacy.com', @hash, 'ACTIVE', GETUTCDATE(), GETUTCDATE());

IF NOT EXISTS (SELECT 1 FROM [USER] WHERE email = 'staff@pharmacy.com')
    INSERT INTO [USER] (user_id, role_id, full_name, email, password_hash, status, created_at, updated_at)
    VALUES (NEWID(), @staff_id, 'Staff', 'staff@pharmacy.com', @hash, 'ACTIVE', GETUTCDATE(), GETUTCDATE());

IF NOT EXISTS (SELECT 1 FROM [USER] WHERE email = 'phanmanh14122000@gmail.com')
    INSERT INTO [USER] (user_id, role_id, full_name, email, password_hash, status, created_at, updated_at)
    VALUES (NEWID(), @inventory_id, 'Inventory Manager', 'phanmanh14122000@gmail.com', @hash, 'ACTIVE', GETUTCDATE(), GETUTCDATE());
GO
