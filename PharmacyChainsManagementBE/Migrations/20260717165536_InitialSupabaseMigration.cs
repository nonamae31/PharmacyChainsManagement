using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace PharmacyChainsManagementBE.Migrations
{
    /// <inheritdoc />
    public partial class InitialSupabaseMigration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BRANCH",
                columns: table => new
                {
                    branch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    branch_name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    address = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    phone = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: true),
                    latitude = table.Column<decimal>(type: "numeric(10,7)", nullable: true),
                    longitude = table.Column<decimal>(type: "numeric(10,7)", nullable: true),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__BRANCH__E55E37DE2FFC4385", x => x.branch_id);
                });

            migrationBuilder.CreateTable(
                name: "MEDICINE",
                columns: table => new
                {
                    medicine_id = table.Column<Guid>(type: "uuid", nullable: false),
                    medicine_name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    category = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    unit = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    standard_price = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    usage_description = table.Column<string>(type: "text", nullable: true),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__MEDICINE__E7148EBBD592791F", x => x.medicine_id);
                });

            migrationBuilder.CreateTable(
                name: "PAYMENT_GATEWAY",
                columns: table => new
                {
                    gateway_id = table.Column<short>(type: "smallint", nullable: false),
                    gateway_code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    provider = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__PAYMENT___0AF5B00B3EAC3274", x => x.gateway_id);
                });

            migrationBuilder.CreateTable(
                name: "ROLE",
                columns: table => new
                {
                    role_id = table.Column<short>(type: "smallint", nullable: false),
                    role_code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    role_name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    is_active = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__ROLE__760965CC18C3E6A4", x => x.role_id);
                });

            migrationBuilder.CreateTable(
                name: "SUPPLIER",
                columns: table => new
                {
                    supplier_id = table.Column<Guid>(type: "uuid", nullable: false),
                    supplier_name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    contact_person = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    email = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    phone = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: true),
                    address = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    tax_code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__SUPPLIER__6EE594E8CCD9CE8A", x => x.supplier_id);
                });

            migrationBuilder.CreateTable(
                name: "USER_SESSION",
                columns: table => new
                {
                    session_id = table.Column<Guid>(type: "uuid", nullable: false),
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    refresh_token = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    expires_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    is_revoked = table.Column<bool>(type: "boolean", nullable: false),
                    revoked_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    replaced_by_token = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    user_agent = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    ip_address = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    device_id = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__USER_SES__session_id", x => x.session_id);
                });

            migrationBuilder.CreateTable(
                name: "USER",
                columns: table => new
                {
                    user_id = table.Column<Guid>(type: "uuid", nullable: false),
                    AccessFailedCount = table.Column<int>(type: "integer", nullable: false),
                    LockoutEnd = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    PasswordResetToken = table.Column<string>(type: "text", nullable: true),
                    ResetTokenExpiry = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
                    role_id = table.Column<short>(type: "smallint", nullable: false),
                    branch_id = table.Column<Guid>(type: "uuid", nullable: true),
                    full_name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    email = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    password_hash = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    phone = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: true),
                    profile_photo_uri = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    must_change_password = table.Column<bool>(type: "boolean", nullable: false),
                    is_deleted = table.Column<bool>(type: "boolean", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__USER__B9BE370FD5688795", x => x.user_id);
                    table.ForeignKey(
                        name: "FK_USER_BRANCH",
                        column: x => x.branch_id,
                        principalTable: "BRANCH",
                        principalColumn: "branch_id");
                    table.ForeignKey(
                        name: "FK_USER_ROLE",
                        column: x => x.role_id,
                        principalTable: "ROLE",
                        principalColumn: "role_id");
                });

            migrationBuilder.CreateTable(
                name: "MEDICINE_BATCH",
                columns: table => new
                {
                    batch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    medicine_id = table.Column<Guid>(type: "uuid", nullable: false),
                    supplier_id = table.Column<Guid>(type: "uuid", nullable: false),
                    batch_number = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    manufacturing_date = table.Column<DateOnly>(type: "date", nullable: true),
                    expiry_date = table.Column<DateOnly>(type: "date", nullable: false),
                    qc_status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__MEDICINE__DBFC0431E550911D", x => x.batch_id);
                    table.ForeignKey(
                        name: "FK_BATCH_MEDICINE",
                        column: x => x.medicine_id,
                        principalTable: "MEDICINE",
                        principalColumn: "medicine_id");
                    table.ForeignKey(
                        name: "FK_BATCH_SUPPLIER",
                        column: x => x.supplier_id,
                        principalTable: "SUPPLIER",
                        principalColumn: "supplier_id");
                });

            migrationBuilder.CreateTable(
                name: "AUDIT_LOG",
                columns: table => new
                {
                    audit_id = table.Column<Guid>(type: "uuid", nullable: false),
                    actor_id = table.Column<Guid>(type: "uuid", nullable: false),
                    entity_name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    entity_id = table.Column<Guid>(type: "uuid", nullable: false),
                    action = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    old_value = table.Column<string>(type: "text", nullable: true),
                    new_value = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__AUDIT_LO__5AF33E33EA16EB9D", x => x.audit_id);
                    table.ForeignKey(
                        name: "FK_AUD_ACTOR",
                        column: x => x.actor_id,
                        principalTable: "USER",
                        principalColumn: "user_id");
                });

            migrationBuilder.CreateTable(
                name: "PRESCRIPTION",
                columns: table => new
                {
                    prescription_id = table.Column<Guid>(type: "uuid", nullable: false),
                    branch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    customer_name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: false),
                    doctor_name = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    prescription_date = table.Column<DateOnly>(type: "date", nullable: false),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__PRESCRIP__3EE444F81A0DC9F6", x => x.prescription_id);
                    table.ForeignKey(
                        name: "FK_PRES_BRANCH",
                        column: x => x.branch_id,
                        principalTable: "BRANCH",
                        principalColumn: "branch_id");
                    table.ForeignKey(
                        name: "FK_PRES_STAFF",
                        column: x => x.staff_id,
                        principalTable: "USER",
                        principalColumn: "user_id");
                });

            migrationBuilder.CreateTable(
                name: "PURCHASE_ORDER",
                columns: table => new
                {
                    po_id = table.Column<Guid>(type: "uuid", nullable: false),
                    supplier_id = table.Column<Guid>(type: "uuid", nullable: false),
                    branch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    created_by = table.Column<Guid>(type: "uuid", nullable: false),
                    approved_by = table.Column<Guid>(type: "uuid", nullable: true),
                    po_status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    order_date = table.Column<DateOnly>(type: "date", nullable: false),
                    expected_date = table.Column<DateOnly>(type: "date", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__PURCHASE__368DA7F09A44F7AA", x => x.po_id);
                    table.ForeignKey(
                        name: "FK_PO_APPROVED_BY",
                        column: x => x.approved_by,
                        principalTable: "USER",
                        principalColumn: "user_id");
                    table.ForeignKey(
                        name: "FK_PO_BRANCH",
                        column: x => x.branch_id,
                        principalTable: "BRANCH",
                        principalColumn: "branch_id");
                    table.ForeignKey(
                        name: "FK_PO_CREATED_BY",
                        column: x => x.created_by,
                        principalTable: "USER",
                        principalColumn: "user_id");
                    table.ForeignKey(
                        name: "FK_PO_SUPPLIER",
                        column: x => x.supplier_id,
                        principalTable: "SUPPLIER",
                        principalColumn: "supplier_id");
                });

            migrationBuilder.CreateTable(
                name: "REPORT",
                columns: table => new
                {
                    report_id = table.Column<Guid>(type: "uuid", nullable: false),
                    report_type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    from_date = table.Column<DateOnly>(type: "date", nullable: true),
                    to_date = table.Column<DateOnly>(type: "date", nullable: true),
                    generated_by = table.Column<Guid>(type: "uuid", nullable: false),
                    file_uri = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: true),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__REPORT__779B7C58AB9D0C61", x => x.report_id);
                    table.ForeignKey(
                        name: "FK_REP_GENERATED_BY",
                        column: x => x.generated_by,
                        principalTable: "USER",
                        principalColumn: "user_id");
                });

            migrationBuilder.CreateTable(
                name: "STOCK_TRANSFER",
                columns: table => new
                {
                    transfer_id = table.Column<Guid>(type: "uuid", nullable: false),
                    from_branch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    to_branch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    requested_by = table.Column<Guid>(type: "uuid", nullable: false),
                    approved_by = table.Column<Guid>(type: "uuid", nullable: true),
                    transfer_status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    request_date = table.Column<DateOnly>(type: "date", nullable: false),
                    approved_date = table.Column<DateOnly>(type: "date", nullable: true),
                    notes = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__STOCK_TR__78E6FD33FAF72D38", x => x.transfer_id);
                    table.ForeignKey(
                        name: "FK_ST_APPROVED_BY",
                        column: x => x.approved_by,
                        principalTable: "USER",
                        principalColumn: "user_id");
                    table.ForeignKey(
                        name: "FK_ST_FROM_BRANCH",
                        column: x => x.from_branch_id,
                        principalTable: "BRANCH",
                        principalColumn: "branch_id");
                    table.ForeignKey(
                        name: "FK_ST_REQUESTED_BY",
                        column: x => x.requested_by,
                        principalTable: "USER",
                        principalColumn: "user_id");
                    table.ForeignKey(
                        name: "FK_ST_TO_BRANCH",
                        column: x => x.to_branch_id,
                        principalTable: "BRANCH",
                        principalColumn: "branch_id");
                });

            migrationBuilder.CreateTable(
                name: "INVENTORY",
                columns: table => new
                {
                    inventory_id = table.Column<Guid>(type: "uuid", nullable: false),
                    branch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    medicine_id = table.Column<Guid>(type: "uuid", nullable: false),
                    batch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    quantity_on_hand = table.Column<int>(type: "integer", nullable: false),
                    safety_stock_level = table.Column<int>(type: "integer", nullable: false),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__INVENTOR__B59ACC4968023E2D", x => x.inventory_id);
                    table.ForeignKey(
                        name: "FK_INV_BATCH",
                        column: x => x.batch_id,
                        principalTable: "MEDICINE_BATCH",
                        principalColumn: "batch_id");
                    table.ForeignKey(
                        name: "FK_INV_BRANCH",
                        column: x => x.branch_id,
                        principalTable: "BRANCH",
                        principalColumn: "branch_id");
                    table.ForeignKey(
                        name: "FK_INV_MEDICINE",
                        column: x => x.medicine_id,
                        principalTable: "MEDICINE",
                        principalColumn: "medicine_id");
                });

            migrationBuilder.CreateTable(
                name: "INVOICE",
                columns: table => new
                {
                    invoice_id = table.Column<Guid>(type: "uuid", nullable: false),
                    branch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    prescription_id = table.Column<Guid>(type: "uuid", nullable: true),
                    invoice_code = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    invoice_date = table.Column<DateOnly>(type: "date", nullable: false),
                    total_amount = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    payment_status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__INVOICE__F58DFD49258ACF2C", x => x.invoice_id);
                    table.ForeignKey(
                        name: "FK_INV_BRANCH_2",
                        column: x => x.branch_id,
                        principalTable: "BRANCH",
                        principalColumn: "branch_id");
                    table.ForeignKey(
                        name: "FK_INV_PRESCRIPTION",
                        column: x => x.prescription_id,
                        principalTable: "PRESCRIPTION",
                        principalColumn: "prescription_id");
                    table.ForeignKey(
                        name: "FK_INV_STAFF",
                        column: x => x.staff_id,
                        principalTable: "USER",
                        principalColumn: "user_id");
                });

            migrationBuilder.CreateTable(
                name: "PRESCRIPTION_DETAIL",
                columns: table => new
                {
                    prescription_detail_id = table.Column<Guid>(type: "uuid", nullable: false),
                    prescription_id = table.Column<Guid>(type: "uuid", nullable: false),
                    medicine_id = table.Column<Guid>(type: "uuid", nullable: false),
                    dosage = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    frequency = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    duration = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: true),
                    quantity = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__PRESCRIP__CD190C8BB0BF34DD", x => x.prescription_detail_id);
                    table.ForeignKey(
                        name: "FK_PRESD_MEDICINE",
                        column: x => x.medicine_id,
                        principalTable: "MEDICINE",
                        principalColumn: "medicine_id");
                    table.ForeignKey(
                        name: "FK_PRESD_PRESCRIPTION",
                        column: x => x.prescription_id,
                        principalTable: "PRESCRIPTION",
                        principalColumn: "prescription_id");
                });

            migrationBuilder.CreateTable(
                name: "PURCHASE_ORDER_DETAIL",
                columns: table => new
                {
                    po_detail_id = table.Column<Guid>(type: "uuid", nullable: false),
                    po_id = table.Column<Guid>(type: "uuid", nullable: false),
                    medicine_id = table.Column<Guid>(type: "uuid", nullable: false),
                    ordered_quantity = table.Column<int>(type: "integer", nullable: false),
                    unit_price = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    line_total = table.Column<decimal>(type: "numeric(12,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__PURCHASE__9E6103B2CC7E0FEF", x => x.po_detail_id);
                    table.ForeignKey(
                        name: "FK_POD_MEDICINE",
                        column: x => x.medicine_id,
                        principalTable: "MEDICINE",
                        principalColumn: "medicine_id");
                    table.ForeignKey(
                        name: "FK_POD_PO",
                        column: x => x.po_id,
                        principalTable: "PURCHASE_ORDER",
                        principalColumn: "po_id");
                });

            migrationBuilder.CreateTable(
                name: "STOCK_TRANSFER_DETAIL",
                columns: table => new
                {
                    transfer_detail_id = table.Column<Guid>(type: "uuid", nullable: false),
                    transfer_id = table.Column<Guid>(type: "uuid", nullable: false),
                    medicine_id = table.Column<Guid>(type: "uuid", nullable: false),
                    batch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    quantity = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__STOCK_TR__EC2B8CDB86128AC6", x => x.transfer_detail_id);
                    table.ForeignKey(
                        name: "FK_STD_BATCH",
                        column: x => x.batch_id,
                        principalTable: "MEDICINE_BATCH",
                        principalColumn: "batch_id");
                    table.ForeignKey(
                        name: "FK_STD_MEDICINE",
                        column: x => x.medicine_id,
                        principalTable: "MEDICINE",
                        principalColumn: "medicine_id");
                    table.ForeignKey(
                        name: "FK_STD_TRANSFER",
                        column: x => x.transfer_id,
                        principalTable: "STOCK_TRANSFER",
                        principalColumn: "transfer_id");
                });

            migrationBuilder.CreateTable(
                name: "INVOICE_DETAIL",
                columns: table => new
                {
                    invoice_detail_id = table.Column<Guid>(type: "uuid", nullable: false),
                    invoice_id = table.Column<Guid>(type: "uuid", nullable: false),
                    medicine_id = table.Column<Guid>(type: "uuid", nullable: false),
                    batch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    quantity = table.Column<int>(type: "integer", nullable: false),
                    unit_price = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    line_total = table.Column<decimal>(type: "numeric(12,2)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__INVOICE___84908DB6027EFE8E", x => x.invoice_detail_id);
                    table.ForeignKey(
                        name: "FK_INVD_BATCH",
                        column: x => x.batch_id,
                        principalTable: "MEDICINE_BATCH",
                        principalColumn: "batch_id");
                    table.ForeignKey(
                        name: "FK_INVD_INVOICE",
                        column: x => x.invoice_id,
                        principalTable: "INVOICE",
                        principalColumn: "invoice_id");
                    table.ForeignKey(
                        name: "FK_INVD_MEDICINE",
                        column: x => x.medicine_id,
                        principalTable: "MEDICINE",
                        principalColumn: "medicine_id");
                });

            migrationBuilder.CreateTable(
                name: "PAYMENT_TRANSACTION",
                columns: table => new
                {
                    payment_id = table.Column<Guid>(type: "uuid", nullable: false),
                    invoice_id = table.Column<Guid>(type: "uuid", nullable: false),
                    gateway_id = table.Column<short>(type: "smallint", nullable: true),
                    amount = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    payment_method = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    payment_status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    payment_date = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    gateway_reference = table.Column<string>(type: "character varying(150)", maxLength: 150, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__PAYMENT___ED1FC9EA5BA1EC89", x => x.payment_id);
                    table.ForeignKey(
                        name: "FK_PAY_GATEWAY",
                        column: x => x.gateway_id,
                        principalTable: "PAYMENT_GATEWAY",
                        principalColumn: "gateway_id");
                    table.ForeignKey(
                        name: "FK_PAY_INVOICE",
                        column: x => x.invoice_id,
                        principalTable: "INVOICE",
                        principalColumn: "invoice_id");
                });

            migrationBuilder.InsertData(
                table: "ROLE",
                columns: new[] { "role_id", "is_active", "role_code", "role_name" },
                values: new object[,]
                {
                    { (short)1, true, "BUSINESS_ADMIN", "Business Admin" },
                    { (short)2, true, "BRANCH_MANAGER", "Branch Manager" },
                    { (short)3, true, "STAFF", "Staff" },
                    { (short)4, true, "INVENTORY_MANAGER", "Inventory Manager" }
                });

            migrationBuilder.InsertData(
                table: "USER",
                columns: new[] { "user_id", "AccessFailedCount", "branch_id", "created_at", "email", "full_name", "is_deleted", "LockoutEnd", "must_change_password", "password_hash", "PasswordResetToken", "phone", "profile_photo_uri", "ResetTokenExpiry", "role_id", "status", "updated_at" },
                values: new object[,]
                {
                    { new Guid("11111111-1111-1111-1111-111111111111"), 0, null, new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8388), "businessadmin@pharmacy.com", "Admin User", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8394) },
                    { new Guid("11111111-1111-1111-1111-111111111112"), 0, null, new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8446), "businessadmin2@pharmacy.com", "Admin User 2", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8447) },
                    { new Guid("11111111-1111-1111-1111-111111111113"), 0, null, new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8450), "businessadmin3@pharmacy.com", "Admin User 3", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8450) },
                    { new Guid("11111111-1111-1111-1111-111111111114"), 0, null, new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8458), "businessadmin4@pharmacy.com", "Admin User 4", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8459) },
                    { new Guid("11111111-1111-1111-1111-111111111115"), 0, null, new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8462), "businessadmin5@pharmacy.com", "Admin User 5", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8463) },
                    { new Guid("22222222-2222-2222-2222-222222222222"), 0, null, new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8399), "manager@pharmacy.com", "Manager User", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)2, "ACTIVE", new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8399) },
                    { new Guid("33333333-3333-3333-3333-333333333333"), 0, null, new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8438), "staff@pharmacy.com", "Staff User", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)3, "ACTIVE", new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8439) },
                    { new Guid("44444444-4444-4444-4444-444444444444"), 0, null, new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8443), "inventory@pharmacy.com", "Inventory Manager", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)4, "ACTIVE", new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8443) }
                });

            migrationBuilder.CreateIndex(
                name: "IX_AUDIT_LOG_actor_id",
                table: "AUDIT_LOG",
                column: "actor_id");

            migrationBuilder.CreateIndex(
                name: "IX_INVENTORY_batch_id",
                table: "INVENTORY",
                column: "batch_id");

            migrationBuilder.CreateIndex(
                name: "IX_INVENTORY_medicine_id",
                table: "INVENTORY",
                column: "medicine_id");

            migrationBuilder.CreateIndex(
                name: "UQ_INVENTORY_BranchBatch",
                table: "INVENTORY",
                columns: new[] { "branch_id", "batch_id" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_INVOICE_branch_id",
                table: "INVOICE",
                column: "branch_id");

            migrationBuilder.CreateIndex(
                name: "IX_INVOICE_prescription_id",
                table: "INVOICE",
                column: "prescription_id");

            migrationBuilder.CreateIndex(
                name: "IX_INVOICE_staff_id",
                table: "INVOICE",
                column: "staff_id");

            migrationBuilder.CreateIndex(
                name: "UQ__INVOICE__5ED70A35B0ECDDDB",
                table: "INVOICE",
                column: "invoice_code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_INVOICE_DETAIL_batch_id",
                table: "INVOICE_DETAIL",
                column: "batch_id");

            migrationBuilder.CreateIndex(
                name: "IX_INVOICE_DETAIL_invoice_id",
                table: "INVOICE_DETAIL",
                column: "invoice_id");

            migrationBuilder.CreateIndex(
                name: "IX_INVOICE_DETAIL_medicine_id",
                table: "INVOICE_DETAIL",
                column: "medicine_id");

            migrationBuilder.CreateIndex(
                name: "IX_MEDICINE_BATCH_supplier_id",
                table: "MEDICINE_BATCH",
                column: "supplier_id");

            migrationBuilder.CreateIndex(
                name: "UQ_MEDICINE_BATCH_Number",
                table: "MEDICINE_BATCH",
                columns: new[] { "medicine_id", "batch_number" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "UQ__PAYMENT___3AC42EB5324B5E97",
                table: "PAYMENT_GATEWAY",
                column: "gateway_code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PAYMENT_TRANSACTION_gateway_id",
                table: "PAYMENT_TRANSACTION",
                column: "gateway_id");

            migrationBuilder.CreateIndex(
                name: "IX_PAYMENT_TRANSACTION_invoice_id",
                table: "PAYMENT_TRANSACTION",
                column: "invoice_id");

            migrationBuilder.CreateIndex(
                name: "IX_PRESCRIPTION_branch_id",
                table: "PRESCRIPTION",
                column: "branch_id");

            migrationBuilder.CreateIndex(
                name: "IX_PRESCRIPTION_staff_id",
                table: "PRESCRIPTION",
                column: "staff_id");

            migrationBuilder.CreateIndex(
                name: "IX_PRESCRIPTION_DETAIL_medicine_id",
                table: "PRESCRIPTION_DETAIL",
                column: "medicine_id");

            migrationBuilder.CreateIndex(
                name: "IX_PRESCRIPTION_DETAIL_prescription_id",
                table: "PRESCRIPTION_DETAIL",
                column: "prescription_id");

            migrationBuilder.CreateIndex(
                name: "IX_PURCHASE_ORDER_approved_by",
                table: "PURCHASE_ORDER",
                column: "approved_by");

            migrationBuilder.CreateIndex(
                name: "IX_PURCHASE_ORDER_branch_id",
                table: "PURCHASE_ORDER",
                column: "branch_id");

            migrationBuilder.CreateIndex(
                name: "IX_PURCHASE_ORDER_created_by",
                table: "PURCHASE_ORDER",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_PURCHASE_ORDER_supplier_id",
                table: "PURCHASE_ORDER",
                column: "supplier_id");

            migrationBuilder.CreateIndex(
                name: "IX_PURCHASE_ORDER_DETAIL_medicine_id",
                table: "PURCHASE_ORDER_DETAIL",
                column: "medicine_id");

            migrationBuilder.CreateIndex(
                name: "IX_PURCHASE_ORDER_DETAIL_po_id",
                table: "PURCHASE_ORDER_DETAIL",
                column: "po_id");

            migrationBuilder.CreateIndex(
                name: "IX_REPORT_generated_by",
                table: "REPORT",
                column: "generated_by");

            migrationBuilder.CreateIndex(
                name: "UQ__ROLE__BAE6307522F2B53F",
                table: "ROLE",
                column: "role_code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_TRANSFER_approved_by",
                table: "STOCK_TRANSFER",
                column: "approved_by");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_TRANSFER_from_branch_id",
                table: "STOCK_TRANSFER",
                column: "from_branch_id");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_TRANSFER_requested_by",
                table: "STOCK_TRANSFER",
                column: "requested_by");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_TRANSFER_to_branch_id",
                table: "STOCK_TRANSFER",
                column: "to_branch_id");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_TRANSFER_DETAIL_batch_id",
                table: "STOCK_TRANSFER_DETAIL",
                column: "batch_id");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_TRANSFER_DETAIL_medicine_id",
                table: "STOCK_TRANSFER_DETAIL",
                column: "medicine_id");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_TRANSFER_DETAIL_transfer_id",
                table: "STOCK_TRANSFER_DETAIL",
                column: "transfer_id");

            migrationBuilder.CreateIndex(
                name: "IX_USER_branch_id",
                table: "USER",
                column: "branch_id");

            migrationBuilder.CreateIndex(
                name: "IX_User_IsDeleted_Filtered",
                table: "USER",
                column: "is_deleted",
                filter: "\"is_deleted\" = false");

            migrationBuilder.CreateIndex(
                name: "IX_USER_role_id",
                table: "USER",
                column: "role_id");

            migrationBuilder.CreateIndex(
                name: "UQ__USER__AB6E6164A2B157E7",
                table: "USER",
                column: "email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_USER_SESSION_refresh_token",
                table: "USER_SESSION",
                column: "refresh_token");

            migrationBuilder.CreateIndex(
                name: "IX_USER_SESSION_user_id",
                table: "USER_SESSION",
                column: "user_id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AUDIT_LOG");

            migrationBuilder.DropTable(
                name: "INVENTORY");

            migrationBuilder.DropTable(
                name: "INVOICE_DETAIL");

            migrationBuilder.DropTable(
                name: "PAYMENT_TRANSACTION");

            migrationBuilder.DropTable(
                name: "PRESCRIPTION_DETAIL");

            migrationBuilder.DropTable(
                name: "PURCHASE_ORDER_DETAIL");

            migrationBuilder.DropTable(
                name: "REPORT");

            migrationBuilder.DropTable(
                name: "STOCK_TRANSFER_DETAIL");

            migrationBuilder.DropTable(
                name: "USER_SESSION");

            migrationBuilder.DropTable(
                name: "PAYMENT_GATEWAY");

            migrationBuilder.DropTable(
                name: "INVOICE");

            migrationBuilder.DropTable(
                name: "PURCHASE_ORDER");

            migrationBuilder.DropTable(
                name: "MEDICINE_BATCH");

            migrationBuilder.DropTable(
                name: "STOCK_TRANSFER");

            migrationBuilder.DropTable(
                name: "PRESCRIPTION");

            migrationBuilder.DropTable(
                name: "MEDICINE");

            migrationBuilder.DropTable(
                name: "SUPPLIER");

            migrationBuilder.DropTable(
                name: "USER");

            migrationBuilder.DropTable(
                name: "BRANCH");

            migrationBuilder.DropTable(
                name: "ROLE");
        }
    }
}
