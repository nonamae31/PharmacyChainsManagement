-- PostgreSQL/Supabase development seed data.
INSERT INTO "ROLE" (role_id, role_code, role_name, is_active)
VALUES
    (1, 'BUSINESS_ADMIN', 'Business Admin', TRUE),
    (2, 'BRANCH_MANAGER', 'Branch Manager', TRUE),
    (3, 'STAFF', 'Staff', TRUE),
    (4, 'INVENTORY_MANAGER', 'Inventory Manager', TRUE)
ON CONFLICT (role_code) DO NOTHING;

-- BCrypt hash for password: 123456
INSERT INTO "USER" (
    user_id,
    role_id,
    full_name,
    email,
    password_hash,
    status,
    created_at,
    updated_at
)
VALUES
    ('11111111-1111-1111-1111-111111111111', 1, 'Admin User', 'businessadmin@pharmacy.com', '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', 'ACTIVE', NOW(), NOW()),
    ('22222222-2222-2222-2222-222222222222', 2, 'Manager User', 'manager@pharmacy.com', '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', 'ACTIVE', NOW(), NOW()),
    ('33333333-3333-3333-3333-333333333333', 3, 'Staff User', 'staff@pharmacy.com', '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', 'ACTIVE', NOW(), NOW()),
    ('44444444-4444-4444-4444-444444444444', 4, 'Inventory Manager', 'phanmanh14122000@gmail.com', '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', 'ACTIVE', NOW(), NOW())
ON CONFLICT (email) DO NOTHING;
