CREATE TABLE "BRANCH" (
    branch_id uuid NOT NULL,
    branch_name character varying(150) NOT NULL,
    branch_type character varying(30) NOT NULL,
    address character varying(255) NOT NULL,
    phone character varying(30),
    latitude numeric(10,7),
    longitude numeric(10,7),
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__BRANCH__E55E37DE2FFC4385" PRIMARY KEY (branch_id)
);


CREATE TABLE "BUDGET_ALLOCATION" (
    allocation_id uuid NOT NULL,
    category_name character varying(100) NOT NULL,
    percentage numeric(5,2) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_BUDGET_ALLOCATION" PRIMARY KEY (allocation_id)
);


CREATE TABLE "LIQUIDITY_FORECAST" (
    forecast_id uuid NOT NULL,
    forecast_date date NOT NULL,
    projected_inflow numeric(12,2) NOT NULL,
    projected_outflow numeric(12,2) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_LIQUIDITY_FORECAST" PRIMARY KEY (forecast_id)
);


CREATE TABLE "MEDICINE" (
    medicine_id uuid NOT NULL,
    medicine_name character varying(150) NOT NULL,
    category character varying(100),
    unit character varying(50) NOT NULL,
    standard_price numeric(12,2) NOT NULL,
    usage_description text,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__MEDICINE__E7148EBBD592791F" PRIMARY KEY (medicine_id)
);


CREATE TABLE "PAYMENT_GATEWAY" (
    gateway_id smallint NOT NULL,
    gateway_code character varying(50) NOT NULL,
    provider character varying(100) NOT NULL,
    is_active boolean NOT NULL DEFAULT TRUE,
    CONSTRAINT "PK__PAYMENT___0AF5B00B3EAC3274" PRIMARY KEY (gateway_id)
);


CREATE TABLE "ROLE" (
    role_id smallint NOT NULL,
    role_code character varying(50) NOT NULL,
    role_name character varying(100) NOT NULL,
    is_active boolean NOT NULL DEFAULT TRUE,
    CONSTRAINT "PK__ROLE__760965CC18C3E6A4" PRIMARY KEY (role_id)
);


CREATE TABLE "SUPPLIER" (
    supplier_id uuid NOT NULL,
    supplier_name character varying(150) NOT NULL,
    contact_person character varying(150),
    email character varying(150),
    phone character varying(30),
    address character varying(255),
    tax_code character varying(50),
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__SUPPLIER__6EE594E8CCD9CE8A" PRIMARY KEY (supplier_id)
);


CREATE TABLE "USER_SESSION" (
    session_id uuid NOT NULL,
    user_id uuid NOT NULL,
    refresh_token character varying(255) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    is_revoked boolean NOT NULL,
    revoked_at timestamp with time zone,
    replaced_by_token character varying(255),
    user_agent character varying(500),
    ip_address character varying(50),
    device_id character varying(100),
    CONSTRAINT "PK__USER_SES__session_id" PRIMARY KEY (session_id)
);


CREATE TABLE "STOCK_ISSUE" (
    issue_id uuid NOT NULL,
    request_no character varying(50) NOT NULL,
    branch_id uuid NOT NULL,
    issue_date timestamp with time zone NOT NULL,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_STOCK_ISSUE" PRIMARY KEY (issue_id),
    CONSTRAINT "FK_STOCK_ISSUE_BRANCH_branch_id" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id) ON DELETE CASCADE
);


CREATE TABLE "STOCKTAKE" (
    stocktake_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    created_by uuid NOT NULL,
    stocktake_date timestamp with time zone NOT NULL,
    status character varying(30) NOT NULL,
    notes text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_STOCKTAKE" PRIMARY KEY (stocktake_id),
    CONSTRAINT "FK_STOCKTAKE_BRANCH_branch_id" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id) ON DELETE CASCADE
);


CREATE TABLE "USER" (
    user_id uuid NOT NULL,
    "AccessFailedCount" integer NOT NULL,
    "LockoutEnd" timestamp with time zone,
    "PasswordResetToken" text,
    "ResetTokenExpiry" timestamp with time zone,
    role_id smallint NOT NULL,
    branch_id uuid,
    full_name character varying(150) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash character varying(255) NOT NULL,
    phone character varying(30),
    profile_photo_uri character varying(255),
    address character varying(255),
    date_of_birth timestamp with time zone,
    gender character varying(10),
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    must_change_password boolean NOT NULL,
    is_deleted boolean NOT NULL,
    CONSTRAINT "PK__USER__B9BE370FD5688795" PRIMARY KEY (user_id),
    CONSTRAINT "FK_USER_BRANCH" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_USER_ROLE" FOREIGN KEY (role_id) REFERENCES "ROLE" (role_id)
);


CREATE TABLE "MEDICINE_BATCH" (
    batch_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    supplier_id uuid NOT NULL,
    batch_number character varying(100) NOT NULL,
    manufacturing_date date,
    expiry_date date NOT NULL,
    qc_status character varying(30) NOT NULL,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__MEDICINE__DBFC0431E550911D" PRIMARY KEY (batch_id),
    CONSTRAINT "FK_BATCH_MEDICINE" FOREIGN KEY (medicine_id) REFERENCES "MEDICINE" (medicine_id),
    CONSTRAINT "FK_BATCH_SUPPLIER" FOREIGN KEY (supplier_id) REFERENCES "SUPPLIER" (supplier_id)
);


CREATE TABLE "AUDIT_LOG" (
    audit_id uuid NOT NULL,
    actor_id uuid NOT NULL,
    entity_name character varying(100) NOT NULL,
    entity_id uuid NOT NULL,
    action character varying(50) NOT NULL,
    old_value text,
    new_value text,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__AUDIT_LO__5AF33E33EA16EB9D" PRIMARY KEY (audit_id),
    CONSTRAINT "FK_AUD_ACTOR" FOREIGN KEY (actor_id) REFERENCES "USER" (user_id)
);


CREATE TABLE "PRESCRIPTION" (
    prescription_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    customer_name character varying(150) NOT NULL,
    doctor_name character varying(150),
    prescription_date date NOT NULL,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__PRESCRIP__3EE444F81A0DC9F6" PRIMARY KEY (prescription_id),
    CONSTRAINT "FK_PRES_BRANCH" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_PRES_STAFF" FOREIGN KEY (staff_id) REFERENCES "USER" (user_id)
);


CREATE TABLE "PURCHASE_ORDER" (
    po_id uuid NOT NULL,
    supplier_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    created_by uuid NOT NULL,
    approved_by uuid,
    po_status character varying(30) NOT NULL,
    order_date date NOT NULL,
    expected_date date,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__PURCHASE__368DA7F09A44F7AA" PRIMARY KEY (po_id),
    CONSTRAINT "FK_PO_APPROVED_BY" FOREIGN KEY (approved_by) REFERENCES "USER" (user_id),
    CONSTRAINT "FK_PO_BRANCH" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_PO_CREATED_BY" FOREIGN KEY (created_by) REFERENCES "USER" (user_id),
    CONSTRAINT "FK_PO_SUPPLIER" FOREIGN KEY (supplier_id) REFERENCES "SUPPLIER" (supplier_id)
);


CREATE TABLE "REPORT" (
    report_id uuid NOT NULL,
    report_type character varying(50) NOT NULL,
    from_date date,
    to_date date,
    generated_by uuid NOT NULL,
    file_uri character varying(255),
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__REPORT__779B7C58AB9D0C61" PRIMARY KEY (report_id),
    CONSTRAINT "FK_REP_GENERATED_BY" FOREIGN KEY (generated_by) REFERENCES "USER" (user_id)
);


CREATE TABLE "STAFF_ASSESSMENT" (
    assessment_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    assessed_by uuid NOT NULL,
    assessment_date date NOT NULL,
    sales_target numeric(12,2) NOT NULL,
    customer_rating numeric(3,2) NOT NULL,
    attendance_percent numeric(5,2) NOT NULL,
    performance_score numeric(5,2) NOT NULL,
    notes character varying(1000),
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_STAFF_ASSESSMENT" PRIMARY KEY (assessment_id),
    CONSTRAINT "FK_STAFF_ASSESSMENT_BRANCH_branch_id" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_STAFF_ASSESSMENT_USER_assessed_by" FOREIGN KEY (assessed_by) REFERENCES "USER" (user_id),
    CONSTRAINT "FK_STAFF_ASSESSMENT_USER_staff_id" FOREIGN KEY (staff_id) REFERENCES "USER" (user_id)
);


CREATE TABLE "STAFF_ATTENDANCE" (
    attendance_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    attendance_date date NOT NULL,
    check_in_time timestamp with time zone NOT NULL,
    check_out_time timestamp with time zone,
    status character varying(20) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_STAFF_ATTENDANCE" PRIMARY KEY (attendance_id),
    CONSTRAINT "FK_STAFF_ATTENDANCE_BRANCH_branch_id" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_STAFF_ATTENDANCE_USER_staff_id" FOREIGN KEY (staff_id) REFERENCES "USER" (user_id)
);


CREATE TABLE "STAFF_PAY_RATE" (
    pay_rate_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    hourly_rate numeric(18,2) NOT NULL,
    effective_from date NOT NULL,
    updated_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_STAFF_PAY_RATE" PRIMARY KEY (pay_rate_id),
    CONSTRAINT "FK_STAFF_PAY_RATE_BRANCH_branch_id" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_STAFF_PAY_RATE_USER_staff_id" FOREIGN KEY (staff_id) REFERENCES "USER" (user_id),
    CONSTRAINT "FK_STAFF_PAY_RATE_USER_updated_by" FOREIGN KEY (updated_by) REFERENCES "USER" (user_id)
);


CREATE TABLE "STAFF_PAYROLL" (
    payroll_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    hourly_rate numeric(18,2) NOT NULL,
    completed_hours numeric(10,2) NOT NULL,
    base_pay numeric(18,2) NOT NULL,
    bonus numeric(18,2) NOT NULL,
    deduction numeric(18,2) NOT NULL,
    net_pay numeric(18,2) NOT NULL,
    status character varying(30) NOT NULL,
    notes character varying(500),
    calculated_by uuid NOT NULL,
    calculated_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_STAFF_PAYROLL" PRIMARY KEY (payroll_id),
    CONSTRAINT "FK_STAFF_PAYROLL_BRANCH_branch_id" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_STAFF_PAYROLL_USER_calculated_by" FOREIGN KEY (calculated_by) REFERENCES "USER" (user_id),
    CONSTRAINT "FK_STAFF_PAYROLL_USER_staff_id" FOREIGN KEY (staff_id) REFERENCES "USER" (user_id)
);


CREATE TABLE "STAFF_SHIFT" (
    shift_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    shift_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    status character varying(30) NOT NULL,
    notes character varying(500),
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_STAFF_SHIFT" PRIMARY KEY (shift_id),
    CONSTRAINT "FK_STAFF_SHIFT_BRANCH_branch_id" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_STAFF_SHIFT_USER_created_by" FOREIGN KEY (created_by) REFERENCES "USER" (user_id),
    CONSTRAINT "FK_STAFF_SHIFT_USER_staff_id" FOREIGN KEY (staff_id) REFERENCES "USER" (user_id)
);


CREATE TABLE "STAFF_WEEKLY_SCHEDULE" (
    weekly_schedule_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    updated_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_STAFF_WEEKLY_SCHEDULE" PRIMARY KEY (weekly_schedule_id),
    CONSTRAINT "FK_STAFF_WEEKLY_SCHEDULE_BRANCH_branch_id" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_STAFF_WEEKLY_SCHEDULE_USER_staff_id" FOREIGN KEY (staff_id) REFERENCES "USER" (user_id),
    CONSTRAINT "FK_STAFF_WEEKLY_SCHEDULE_USER_updated_by" FOREIGN KEY (updated_by) REFERENCES "USER" (user_id)
);


CREATE TABLE "STOCK_TRANSFER" (
    transfer_id uuid NOT NULL,
    from_branch_id uuid NOT NULL,
    to_branch_id uuid NOT NULL,
    requested_by uuid NOT NULL,
    approved_by uuid,
    transfer_status character varying(30) NOT NULL,
    request_date date NOT NULL,
    approved_date date,
    notes text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__STOCK_TR__78E6FD33FAF72D38" PRIMARY KEY (transfer_id),
    CONSTRAINT "FK_ST_APPROVED_BY" FOREIGN KEY (approved_by) REFERENCES "USER" (user_id),
    CONSTRAINT "FK_ST_FROM_BRANCH" FOREIGN KEY (from_branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_ST_REQUESTED_BY" FOREIGN KEY (requested_by) REFERENCES "USER" (user_id),
    CONSTRAINT "FK_ST_TO_BRANCH" FOREIGN KEY (to_branch_id) REFERENCES "BRANCH" (branch_id)
);


CREATE TABLE "DAMAGE_REPORT" (
    damage_report_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    batch_id uuid NOT NULL,
    quantity integer NOT NULL,
    damage_reason text NOT NULL,
    status character varying(30) NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_DAMAGE_REPORT" PRIMARY KEY (damage_report_id),
    CONSTRAINT "FK_DAMAGE_REPORT_BRANCH_branch_id" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id) ON DELETE CASCADE,
    CONSTRAINT "FK_DAMAGE_REPORT_MEDICINE_BATCH_batch_id" FOREIGN KEY (batch_id) REFERENCES "MEDICINE_BATCH" (batch_id) ON DELETE CASCADE,
    CONSTRAINT "FK_DAMAGE_REPORT_MEDICINE_medicine_id" FOREIGN KEY (medicine_id) REFERENCES "MEDICINE" (medicine_id) ON DELETE CASCADE
);


CREATE TABLE "INVENTORY" (
    inventory_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    batch_id uuid NOT NULL,
    quantity_on_hand integer NOT NULL,
    safety_stock_level integer NOT NULL,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    row_version bytea NOT NULL,
    CONSTRAINT "PK__INVENTOR__B59ACC4968023E2D" PRIMARY KEY (inventory_id),
    CONSTRAINT "FK_INV_BATCH" FOREIGN KEY (batch_id) REFERENCES "MEDICINE_BATCH" (batch_id),
    CONSTRAINT "FK_INV_BRANCH" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_INV_MEDICINE" FOREIGN KEY (medicine_id) REFERENCES "MEDICINE" (medicine_id)
);


CREATE TABLE "STOCK_ISSUE_DETAIL" (
    issue_detail_id uuid NOT NULL,
    issue_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    batch_id uuid NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT "PK_STOCK_ISSUE_DETAIL" PRIMARY KEY (issue_detail_id),
    CONSTRAINT "FK_STOCK_ISSUE_DETAIL_MEDICINE_BATCH_batch_id" FOREIGN KEY (batch_id) REFERENCES "MEDICINE_BATCH" (batch_id) ON DELETE CASCADE,
    CONSTRAINT "FK_STOCK_ISSUE_DETAIL_MEDICINE_medicine_id" FOREIGN KEY (medicine_id) REFERENCES "MEDICINE" (medicine_id) ON DELETE CASCADE,
    CONSTRAINT "FK_STOCK_ISSUE_DETAIL_STOCK_ISSUE_issue_id" FOREIGN KEY (issue_id) REFERENCES "STOCK_ISSUE" (issue_id) ON DELETE CASCADE
);


CREATE TABLE "STOCKTAKE_DETAIL" (
    stocktake_detail_id uuid NOT NULL,
    stocktake_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    batch_id uuid NOT NULL,
    system_quantity integer NOT NULL,
    physical_quantity integer NOT NULL,
    CONSTRAINT "PK_STOCKTAKE_DETAIL" PRIMARY KEY (stocktake_detail_id),
    CONSTRAINT "FK_STOCKTAKE_DETAIL_MEDICINE_BATCH_batch_id" FOREIGN KEY (batch_id) REFERENCES "MEDICINE_BATCH" (batch_id) ON DELETE CASCADE,
    CONSTRAINT "FK_STOCKTAKE_DETAIL_MEDICINE_medicine_id" FOREIGN KEY (medicine_id) REFERENCES "MEDICINE" (medicine_id) ON DELETE CASCADE,
    CONSTRAINT "FK_STOCKTAKE_DETAIL_STOCKTAKE_stocktake_id" FOREIGN KEY (stocktake_id) REFERENCES "STOCKTAKE" (stocktake_id) ON DELETE CASCADE
);


CREATE TABLE "INVOICE" (
    invoice_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    staff_id uuid NOT NULL,
    prescription_id uuid,
    invoice_code character varying(50) NOT NULL,
    invoice_date date NOT NULL,
    total_amount numeric(12,2) NOT NULL,
    payment_status character varying(30) NOT NULL,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__INVOICE__F58DFD49258ACF2C" PRIMARY KEY (invoice_id),
    CONSTRAINT "FK_INV_BRANCH_2" FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
    CONSTRAINT "FK_INV_PRESCRIPTION" FOREIGN KEY (prescription_id) REFERENCES "PRESCRIPTION" (prescription_id),
    CONSTRAINT "FK_INV_STAFF" FOREIGN KEY (staff_id) REFERENCES "USER" (user_id)
);


CREATE TABLE "PRESCRIPTION_DETAIL" (
    prescription_detail_id uuid NOT NULL,
    prescription_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    dosage character varying(100),
    frequency character varying(100),
    duration character varying(100),
    quantity integer NOT NULL,
    CONSTRAINT "PK__PRESCRIP__CD190C8BB0BF34DD" PRIMARY KEY (prescription_detail_id),
    CONSTRAINT "FK_PRESD_MEDICINE" FOREIGN KEY (medicine_id) REFERENCES "MEDICINE" (medicine_id),
    CONSTRAINT "FK_PRESD_PRESCRIPTION" FOREIGN KEY (prescription_id) REFERENCES "PRESCRIPTION" (prescription_id)
);


CREATE TABLE "INVENTORY_RECEIPT" (
    receipt_id uuid NOT NULL,
    supplier_id uuid NOT NULL,
    po_id uuid,
    delivery_note_no character varying(100),
    received_date timestamp with time zone NOT NULL,
    status character varying(30) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_INVENTORY_RECEIPT" PRIMARY KEY (receipt_id),
    CONSTRAINT "FK_INVENTORY_RECEIPT_PURCHASE_ORDER_po_id" FOREIGN KEY (po_id) REFERENCES "PURCHASE_ORDER" (po_id),
    CONSTRAINT "FK_INVENTORY_RECEIPT_SUPPLIER_supplier_id" FOREIGN KEY (supplier_id) REFERENCES "SUPPLIER" (supplier_id) ON DELETE CASCADE
);


CREATE TABLE "PURCHASE_ORDER_DETAIL" (
    po_detail_id uuid NOT NULL,
    po_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    ordered_quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    line_total numeric(12,2) NOT NULL,
    CONSTRAINT "PK__PURCHASE__9E6103B2CC7E0FEF" PRIMARY KEY (po_detail_id),
    CONSTRAINT "FK_POD_MEDICINE" FOREIGN KEY (medicine_id) REFERENCES "MEDICINE" (medicine_id),
    CONSTRAINT "FK_POD_PO" FOREIGN KEY (po_id) REFERENCES "PURCHASE_ORDER" (po_id)
);


CREATE TABLE "STOCK_TRANSFER_DETAIL" (
    transfer_detail_id uuid NOT NULL,
    transfer_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    batch_id uuid NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT "PK__STOCK_TR__EC2B8CDB86128AC6" PRIMARY KEY (transfer_detail_id),
    CONSTRAINT "FK_STD_BATCH" FOREIGN KEY (batch_id) REFERENCES "MEDICINE_BATCH" (batch_id),
    CONSTRAINT "FK_STD_MEDICINE" FOREIGN KEY (medicine_id) REFERENCES "MEDICINE" (medicine_id),
    CONSTRAINT "FK_STD_TRANSFER" FOREIGN KEY (transfer_id) REFERENCES "STOCK_TRANSFER" (transfer_id)
);


CREATE TABLE "INVENTORY_ADJUSTMENT" (
    adjustment_id uuid NOT NULL,
    stocktake_detail_id uuid,
    inventory_id uuid NOT NULL,
    adjustment_type character varying(30) NOT NULL,
    quantity integer NOT NULL,
    reason text,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK_INVENTORY_ADJUSTMENT" PRIMARY KEY (adjustment_id),
    CONSTRAINT "FK_INVENTORY_ADJUSTMENT_INVENTORY_inventory_id" FOREIGN KEY (inventory_id) REFERENCES "INVENTORY" (inventory_id) ON DELETE CASCADE,
    CONSTRAINT "FK_INVENTORY_ADJUSTMENT_STOCKTAKE_DETAIL_stocktake_detail_id" FOREIGN KEY (stocktake_detail_id) REFERENCES "STOCKTAKE_DETAIL" (stocktake_detail_id)
);


CREATE TABLE "INVOICE_DETAIL" (
    invoice_detail_id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    batch_id uuid NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    line_total numeric(12,2) NOT NULL,
    CONSTRAINT "PK__INVOICE___84908DB6027EFE8E" PRIMARY KEY (invoice_detail_id),
    CONSTRAINT "FK_INVD_BATCH" FOREIGN KEY (batch_id) REFERENCES "MEDICINE_BATCH" (batch_id),
    CONSTRAINT "FK_INVD_INVOICE" FOREIGN KEY (invoice_id) REFERENCES "INVOICE" (invoice_id),
    CONSTRAINT "FK_INVD_MEDICINE" FOREIGN KEY (medicine_id) REFERENCES "MEDICINE" (medicine_id)
);


CREATE TABLE "PAYMENT_TRANSACTION" (
    payment_id uuid NOT NULL,
    invoice_id uuid NOT NULL,
    gateway_id smallint,
    amount numeric(12,2) NOT NULL,
    exchange_rate numeric(18,4),
    expected_amount_vnd numeric(18,0),
    received_amount_vnd numeric(18,0),
    base_currency character varying(3) NOT NULL,
    settlement_currency character varying(3) NOT NULL,
    payment_method character varying(50) NOT NULL,
    payment_status character varying(30) NOT NULL,
    payment_date timestamp with time zone,
    gateway_reference character varying(150),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT "PK__PAYMENT___ED1FC9EA5BA1EC89" PRIMARY KEY (payment_id),
    CONSTRAINT "FK_PAY_GATEWAY" FOREIGN KEY (gateway_id) REFERENCES "PAYMENT_GATEWAY" (gateway_id),
    CONSTRAINT "FK_PAY_INVOICE" FOREIGN KEY (invoice_id) REFERENCES "INVOICE" (invoice_id)
);


CREATE TABLE "INVENTORY_RECEIPT_DETAIL" (
    receipt_detail_id uuid NOT NULL,
    receipt_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    batch_id uuid NOT NULL,
    quantity integer NOT NULL,
    CONSTRAINT "PK_INVENTORY_RECEIPT_DETAIL" PRIMARY KEY (receipt_detail_id),
    CONSTRAINT "FK_INVENTORY_RECEIPT_DETAIL_INVENTORY_RECEIPT_receipt_id" FOREIGN KEY (receipt_id) REFERENCES "INVENTORY_RECEIPT" (receipt_id) ON DELETE CASCADE,
    CONSTRAINT "FK_INVENTORY_RECEIPT_DETAIL_MEDICINE_BATCH_batch_id" FOREIGN KEY (batch_id) REFERENCES "MEDICINE_BATCH" (batch_id) ON DELETE CASCADE,
    CONSTRAINT "FK_INVENTORY_RECEIPT_DETAIL_MEDICINE_medicine_id" FOREIGN KEY (medicine_id) REFERENCES "MEDICINE" (medicine_id) ON DELETE CASCADE
);


INSERT INTO "ROLE" (role_id, is_active, role_code, role_name)
VALUES (1, TRUE, 'BUSINESS_ADMIN', 'Business Admin');
INSERT INTO "ROLE" (role_id, is_active, role_code, role_name)
VALUES (2, TRUE, 'BRANCH_MANAGER', 'Branch Manager');
INSERT INTO "ROLE" (role_id, is_active, role_code, role_name)
VALUES (3, TRUE, 'STAFF', 'Staff');
INSERT INTO "ROLE" (role_id, is_active, role_code, role_name)
VALUES (4, TRUE, 'INVENTORY_MANAGER', 'Inventory Manager');
INSERT INTO "ROLE" (role_id, is_active, role_code, role_name)
VALUES (5, TRUE, 'FOUNDER', 'Founder');


INSERT INTO "USER" (user_id, "AccessFailedCount", address, branch_id, created_at, date_of_birth, email, full_name, gender, is_deleted, "LockoutEnd", must_change_password, password_hash, "PasswordResetToken", phone, profile_photo_uri, "ResetTokenExpiry", role_id, status, updated_at)
VALUES ('11111111-1111-1111-1111-111111111111', 0, NULL, NULL, TIMESTAMPTZ '2026-07-12T00:00:00Z', NULL, 'businessadmin@pharmacy.com', 'Admin User', NULL, FALSE, NULL, FALSE, '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', NULL, NULL, NULL, NULL, 1, 'ACTIVE', TIMESTAMPTZ '2026-07-12T00:00:00Z');
INSERT INTO "USER" (user_id, "AccessFailedCount", address, branch_id, created_at, date_of_birth, email, full_name, gender, is_deleted, "LockoutEnd", must_change_password, password_hash, "PasswordResetToken", phone, profile_photo_uri, "ResetTokenExpiry", role_id, status, updated_at)
VALUES ('11111111-1111-1111-1111-111111111112', 0, NULL, NULL, TIMESTAMPTZ '2026-07-12T00:00:00Z', NULL, 'businessadmin2@pharmacy.com', 'Admin User 2', NULL, FALSE, NULL, FALSE, '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', NULL, NULL, NULL, NULL, 1, 'ACTIVE', TIMESTAMPTZ '2026-07-12T00:00:00Z');
INSERT INTO "USER" (user_id, "AccessFailedCount", address, branch_id, created_at, date_of_birth, email, full_name, gender, is_deleted, "LockoutEnd", must_change_password, password_hash, "PasswordResetToken", phone, profile_photo_uri, "ResetTokenExpiry", role_id, status, updated_at)
VALUES ('11111111-1111-1111-1111-111111111113', 0, NULL, NULL, TIMESTAMPTZ '2026-07-12T00:00:00Z', NULL, 'businessadmin3@pharmacy.com', 'Admin User 3', NULL, FALSE, NULL, FALSE, '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', NULL, NULL, NULL, NULL, 1, 'ACTIVE', TIMESTAMPTZ '2026-07-12T00:00:00Z');
INSERT INTO "USER" (user_id, "AccessFailedCount", address, branch_id, created_at, date_of_birth, email, full_name, gender, is_deleted, "LockoutEnd", must_change_password, password_hash, "PasswordResetToken", phone, profile_photo_uri, "ResetTokenExpiry", role_id, status, updated_at)
VALUES ('11111111-1111-1111-1111-111111111114', 0, NULL, NULL, TIMESTAMPTZ '2026-07-12T00:00:00Z', NULL, 'businessadmin4@pharmacy.com', 'Admin User 4', NULL, FALSE, NULL, FALSE, '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', NULL, NULL, NULL, NULL, 1, 'ACTIVE', TIMESTAMPTZ '2026-07-12T00:00:00Z');
INSERT INTO "USER" (user_id, "AccessFailedCount", address, branch_id, created_at, date_of_birth, email, full_name, gender, is_deleted, "LockoutEnd", must_change_password, password_hash, "PasswordResetToken", phone, profile_photo_uri, "ResetTokenExpiry", role_id, status, updated_at)
VALUES ('11111111-1111-1111-1111-111111111115', 0, NULL, NULL, TIMESTAMPTZ '2026-07-12T00:00:00Z', NULL, 'businessadmin5@pharmacy.com', 'Admin User 5', NULL, FALSE, NULL, FALSE, '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', NULL, NULL, NULL, NULL, 1, 'ACTIVE', TIMESTAMPTZ '2026-07-12T00:00:00Z');
INSERT INTO "USER" (user_id, "AccessFailedCount", address, branch_id, created_at, date_of_birth, email, full_name, gender, is_deleted, "LockoutEnd", must_change_password, password_hash, "PasswordResetToken", phone, profile_photo_uri, "ResetTokenExpiry", role_id, status, updated_at)
VALUES ('22222222-2222-2222-2222-222222222222', 0, NULL, NULL, TIMESTAMPTZ '2026-07-12T00:00:00Z', NULL, 'manager@pharmacy.com', 'Manager User', NULL, FALSE, NULL, FALSE, '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', NULL, NULL, NULL, NULL, 2, 'ACTIVE', TIMESTAMPTZ '2026-07-12T00:00:00Z');
INSERT INTO "USER" (user_id, "AccessFailedCount", address, branch_id, created_at, date_of_birth, email, full_name, gender, is_deleted, "LockoutEnd", must_change_password, password_hash, "PasswordResetToken", phone, profile_photo_uri, "ResetTokenExpiry", role_id, status, updated_at)
VALUES ('33333333-3333-3333-3333-333333333333', 0, NULL, NULL, TIMESTAMPTZ '2026-07-12T00:00:00Z', NULL, 'staff@pharmacy.com', 'Staff User', NULL, FALSE, NULL, FALSE, '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', NULL, NULL, NULL, NULL, 3, 'ACTIVE', TIMESTAMPTZ '2026-07-12T00:00:00Z');
INSERT INTO "USER" (user_id, "AccessFailedCount", address, branch_id, created_at, date_of_birth, email, full_name, gender, is_deleted, "LockoutEnd", must_change_password, password_hash, "PasswordResetToken", phone, profile_photo_uri, "ResetTokenExpiry", role_id, status, updated_at)
VALUES ('44444444-4444-4444-4444-444444444444', 0, NULL, NULL, TIMESTAMPTZ '2026-07-12T00:00:00Z', NULL, 'phanmanh14122000@gmail.com', 'Inventory Manager', NULL, FALSE, NULL, FALSE, '$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a', NULL, NULL, NULL, NULL, 4, 'ACTIVE', TIMESTAMPTZ '2026-07-12T00:00:00Z');


CREATE INDEX "IX_AUDIT_LOG_actor_id" ON "AUDIT_LOG" (actor_id);


CREATE INDEX "IX_DAMAGE_REPORT_batch_id" ON "DAMAGE_REPORT" (batch_id);


CREATE INDEX "IX_DAMAGE_REPORT_branch_id" ON "DAMAGE_REPORT" (branch_id);


CREATE INDEX "IX_DAMAGE_REPORT_medicine_id" ON "DAMAGE_REPORT" (medicine_id);


CREATE INDEX "IX_INVENTORY_batch_id" ON "INVENTORY" (batch_id);


CREATE INDEX "IX_INVENTORY_medicine_id" ON "INVENTORY" (medicine_id);


CREATE UNIQUE INDEX "UQ_INVENTORY_BranchBatch" ON "INVENTORY" (branch_id, batch_id);


CREATE INDEX "IX_INVENTORY_ADJUSTMENT_inventory_id" ON "INVENTORY_ADJUSTMENT" (inventory_id);


CREATE INDEX "IX_INVENTORY_ADJUSTMENT_stocktake_detail_id" ON "INVENTORY_ADJUSTMENT" (stocktake_detail_id);


CREATE INDEX "IX_INVENTORY_RECEIPT_po_id" ON "INVENTORY_RECEIPT" (po_id);


CREATE INDEX "IX_INVENTORY_RECEIPT_supplier_id" ON "INVENTORY_RECEIPT" (supplier_id);


CREATE INDEX "IX_INVENTORY_RECEIPT_DETAIL_batch_id" ON "INVENTORY_RECEIPT_DETAIL" (batch_id);


CREATE INDEX "IX_INVENTORY_RECEIPT_DETAIL_medicine_id" ON "INVENTORY_RECEIPT_DETAIL" (medicine_id);


CREATE INDEX "IX_INVENTORY_RECEIPT_DETAIL_receipt_id" ON "INVENTORY_RECEIPT_DETAIL" (receipt_id);


CREATE INDEX "IX_INVOICE_branch_id" ON "INVOICE" (branch_id);


CREATE INDEX "IX_INVOICE_prescription_id" ON "INVOICE" (prescription_id);


CREATE INDEX "IX_INVOICE_staff_id" ON "INVOICE" (staff_id);


CREATE UNIQUE INDEX "UQ__INVOICE__5ED70A35B0ECDDDB" ON "INVOICE" (invoice_code);


CREATE INDEX "IX_INVOICE_DETAIL_batch_id" ON "INVOICE_DETAIL" (batch_id);


CREATE INDEX "IX_INVOICE_DETAIL_invoice_id" ON "INVOICE_DETAIL" (invoice_id);


CREATE INDEX "IX_INVOICE_DETAIL_medicine_id" ON "INVOICE_DETAIL" (medicine_id);


CREATE INDEX "IX_MEDICINE_BATCH_supplier_id" ON "MEDICINE_BATCH" (supplier_id);


CREATE UNIQUE INDEX "UQ_MEDICINE_BATCH_Number" ON "MEDICINE_BATCH" (medicine_id, batch_number);


CREATE UNIQUE INDEX "UQ__PAYMENT___3AC42EB5324B5E97" ON "PAYMENT_GATEWAY" (gateway_code);


CREATE INDEX "IX_PAYMENT_TRANSACTION_gateway_id" ON "PAYMENT_TRANSACTION" (gateway_id);


CREATE INDEX "IX_PAYMENT_TRANSACTION_invoice_id" ON "PAYMENT_TRANSACTION" (invoice_id);


CREATE INDEX "IX_PRESCRIPTION_branch_id" ON "PRESCRIPTION" (branch_id);


CREATE INDEX "IX_PRESCRIPTION_staff_id" ON "PRESCRIPTION" (staff_id);


CREATE INDEX "IX_PRESCRIPTION_DETAIL_medicine_id" ON "PRESCRIPTION_DETAIL" (medicine_id);


CREATE INDEX "IX_PRESCRIPTION_DETAIL_prescription_id" ON "PRESCRIPTION_DETAIL" (prescription_id);


CREATE INDEX "IX_PURCHASE_ORDER_approved_by" ON "PURCHASE_ORDER" (approved_by);


CREATE INDEX "IX_PURCHASE_ORDER_branch_id" ON "PURCHASE_ORDER" (branch_id);


CREATE INDEX "IX_PURCHASE_ORDER_created_by" ON "PURCHASE_ORDER" (created_by);


CREATE INDEX "IX_PURCHASE_ORDER_supplier_id" ON "PURCHASE_ORDER" (supplier_id);


CREATE INDEX "IX_PURCHASE_ORDER_DETAIL_medicine_id" ON "PURCHASE_ORDER_DETAIL" (medicine_id);


CREATE INDEX "IX_PURCHASE_ORDER_DETAIL_po_id" ON "PURCHASE_ORDER_DETAIL" (po_id);


CREATE INDEX "IX_REPORT_generated_by" ON "REPORT" (generated_by);


CREATE UNIQUE INDEX "UQ__ROLE__BAE6307522F2B53F" ON "ROLE" (role_code);


CREATE INDEX "IX_STAFF_ASSESSMENT_assessed_by" ON "STAFF_ASSESSMENT" (assessed_by);


CREATE INDEX "IX_STAFF_ASSESSMENT_BranchStaffDate" ON "STAFF_ASSESSMENT" (branch_id, staff_id, assessment_date);


CREATE INDEX "IX_STAFF_ASSESSMENT_staff_id" ON "STAFF_ASSESSMENT" (staff_id);


CREATE INDEX "IX_STAFF_ATTENDANCE_BranchDate" ON "STAFF_ATTENDANCE" (branch_id, attendance_date);


CREATE UNIQUE INDEX "UQ_STAFF_ATTENDANCE_StaffDate" ON "STAFF_ATTENDANCE" (staff_id, attendance_date);


CREATE INDEX "IX_STAFF_PAY_RATE_staff_id" ON "STAFF_PAY_RATE" (staff_id);


CREATE INDEX "IX_STAFF_PAY_RATE_updated_by" ON "STAFF_PAY_RATE" (updated_by);


CREATE UNIQUE INDEX "UQ_STAFF_PAY_RATE_BranchStaff" ON "STAFF_PAY_RATE" (branch_id, staff_id);


CREATE INDEX "IX_STAFF_PAYROLL_calculated_by" ON "STAFF_PAYROLL" (calculated_by);


CREATE INDEX "IX_STAFF_PAYROLL_staff_id" ON "STAFF_PAYROLL" (staff_id);


CREATE UNIQUE INDEX "UQ_STAFF_PAYROLL_BranchStaffPeriod" ON "STAFF_PAYROLL" (branch_id, staff_id, period_start, period_end);


CREATE INDEX "IX_STAFF_SHIFT_created_by" ON "STAFF_SHIFT" (created_by);


CREATE INDEX "IX_STAFF_SHIFT_staff_id" ON "STAFF_SHIFT" (staff_id);


CREATE UNIQUE INDEX "UQ_STAFF_SHIFT_BranchStaffDate" ON "STAFF_SHIFT" (branch_id, staff_id, shift_date);


CREATE INDEX "IX_STAFF_WEEKLY_SCHEDULE_staff_id" ON "STAFF_WEEKLY_SCHEDULE" (staff_id);


CREATE INDEX "IX_STAFF_WEEKLY_SCHEDULE_updated_by" ON "STAFF_WEEKLY_SCHEDULE" (updated_by);


CREATE UNIQUE INDEX "UQ_STAFF_WEEKLY_SCHEDULE_BranchStaff" ON "STAFF_WEEKLY_SCHEDULE" (branch_id, staff_id);


CREATE INDEX "IX_STOCK_ISSUE_branch_id" ON "STOCK_ISSUE" (branch_id);


CREATE INDEX "IX_STOCK_ISSUE_DETAIL_batch_id" ON "STOCK_ISSUE_DETAIL" (batch_id);


CREATE INDEX "IX_STOCK_ISSUE_DETAIL_issue_id" ON "STOCK_ISSUE_DETAIL" (issue_id);


CREATE INDEX "IX_STOCK_ISSUE_DETAIL_medicine_id" ON "STOCK_ISSUE_DETAIL" (medicine_id);


CREATE INDEX "IX_STOCK_TRANSFER_approved_by" ON "STOCK_TRANSFER" (approved_by);


CREATE INDEX "IX_STOCK_TRANSFER_from_branch_id" ON "STOCK_TRANSFER" (from_branch_id);


CREATE INDEX "IX_STOCK_TRANSFER_requested_by" ON "STOCK_TRANSFER" (requested_by);


CREATE INDEX "IX_STOCK_TRANSFER_to_branch_id" ON "STOCK_TRANSFER" (to_branch_id);


CREATE INDEX "IX_STOCK_TRANSFER_DETAIL_batch_id" ON "STOCK_TRANSFER_DETAIL" (batch_id);


CREATE INDEX "IX_STOCK_TRANSFER_DETAIL_medicine_id" ON "STOCK_TRANSFER_DETAIL" (medicine_id);


CREATE INDEX "IX_STOCK_TRANSFER_DETAIL_transfer_id" ON "STOCK_TRANSFER_DETAIL" (transfer_id);


CREATE INDEX "IX_STOCKTAKE_branch_id" ON "STOCKTAKE" (branch_id);


CREATE INDEX "IX_STOCKTAKE_DETAIL_batch_id" ON "STOCKTAKE_DETAIL" (batch_id);


CREATE INDEX "IX_STOCKTAKE_DETAIL_medicine_id" ON "STOCKTAKE_DETAIL" (medicine_id);


CREATE INDEX "IX_STOCKTAKE_DETAIL_stocktake_id" ON "STOCKTAKE_DETAIL" (stocktake_id);


CREATE INDEX "IX_USER_branch_id" ON "USER" (branch_id);


CREATE INDEX "IX_User_IsDeleted_Filtered" ON "USER" (is_deleted) WHERE "is_deleted" = false;


CREATE INDEX "IX_USER_role_id" ON "USER" (role_id);


CREATE UNIQUE INDEX "UQ__USER__AB6E6164A2B157E7" ON "USER" (email);


CREATE INDEX "IX_USER_SESSION_refresh_token" ON "USER_SESSION" (refresh_token);


CREATE INDEX "IX_USER_SESSION_user_id" ON "USER_SESSION" (user_id);


