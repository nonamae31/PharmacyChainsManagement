using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PharmacyChainsManagementBE.Models;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations;

[DbContext(typeof(PharmacyDbContext))]
[Migration("20260717180000_AddBranchManagerStaffOperations")]
public partial class AddBranchManagerStaffOperations : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            CREATE TABLE IF NOT EXISTS "STAFF_ASSESSMENT" (
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
                CONSTRAINT "FK_STAFF_ASSESSMENT_BRANCH_branch_id"
                    FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
                CONSTRAINT "FK_STAFF_ASSESSMENT_USER_assessed_by"
                    FOREIGN KEY (assessed_by) REFERENCES "USER" (user_id),
                CONSTRAINT "FK_STAFF_ASSESSMENT_USER_staff_id"
                    FOREIGN KEY (staff_id) REFERENCES "USER" (user_id)
            );

            CREATE INDEX IF NOT EXISTS "IX_STAFF_ASSESSMENT_assessed_by"
                ON "STAFF_ASSESSMENT" (assessed_by);
            CREATE INDEX IF NOT EXISTS "IX_STAFF_ASSESSMENT_BranchStaffDate"
                ON "STAFF_ASSESSMENT" (branch_id, staff_id, assessment_date);
            CREATE INDEX IF NOT EXISTS "IX_STAFF_ASSESSMENT_staff_id"
                ON "STAFF_ASSESSMENT" (staff_id);

            CREATE TABLE IF NOT EXISTS "STAFF_SHIFT" (
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
                CONSTRAINT "FK_STAFF_SHIFT_BRANCH_branch_id"
                    FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
                CONSTRAINT "FK_STAFF_SHIFT_USER_created_by"
                    FOREIGN KEY (created_by) REFERENCES "USER" (user_id),
                CONSTRAINT "FK_STAFF_SHIFT_USER_staff_id"
                    FOREIGN KEY (staff_id) REFERENCES "USER" (user_id)
            );

            CREATE INDEX IF NOT EXISTS "IX_STAFF_SHIFT_created_by"
                ON "STAFF_SHIFT" (created_by);
            CREATE INDEX IF NOT EXISTS "IX_STAFF_SHIFT_staff_id"
                ON "STAFF_SHIFT" (staff_id);
            CREATE UNIQUE INDEX IF NOT EXISTS "UQ_STAFF_SHIFT_BranchStaffDate"
                ON "STAFF_SHIFT" (branch_id, staff_id, shift_date);
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            DROP TABLE IF EXISTS "STAFF_ASSESSMENT";
            DROP TABLE IF EXISTS "STAFF_SHIFT";
            """);
    }
}
