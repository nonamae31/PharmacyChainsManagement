using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using PharmacyChainsManagementBE.Models;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations;

[DbContext(typeof(PharmacyDbContext))]
[Migration("20260719102046_AddStaffHourlyPayrollTables")]
public partial class AddStaffHourlyPayrollTables : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            CREATE TABLE IF NOT EXISTS "STAFF_PAY_RATE" (
                pay_rate_id uuid NOT NULL,
                branch_id uuid NOT NULL,
                staff_id uuid NOT NULL,
                hourly_rate numeric(18,2) NOT NULL,
                effective_from date NOT NULL,
                updated_by uuid NOT NULL,
                created_at timestamp with time zone NOT NULL,
                updated_at timestamp with time zone NOT NULL,
                CONSTRAINT "PK_STAFF_PAY_RATE" PRIMARY KEY (pay_rate_id),
                CONSTRAINT "FK_STAFF_PAY_RATE_BRANCH_branch_id"
                    FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
                CONSTRAINT "FK_STAFF_PAY_RATE_USER_staff_id"
                    FOREIGN KEY (staff_id) REFERENCES "USER" (user_id),
                CONSTRAINT "FK_STAFF_PAY_RATE_USER_updated_by"
                    FOREIGN KEY (updated_by) REFERENCES "USER" (user_id)
            );

            CREATE INDEX IF NOT EXISTS "IX_STAFF_PAY_RATE_staff_id"
                ON "STAFF_PAY_RATE" (staff_id);
            CREATE INDEX IF NOT EXISTS "IX_STAFF_PAY_RATE_updated_by"
                ON "STAFF_PAY_RATE" (updated_by);
            CREATE UNIQUE INDEX IF NOT EXISTS "UQ_STAFF_PAY_RATE_BranchStaff"
                ON "STAFF_PAY_RATE" (branch_id, staff_id);

            CREATE TABLE IF NOT EXISTS "STAFF_PAYROLL" (
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
                CONSTRAINT "FK_STAFF_PAYROLL_BRANCH_branch_id"
                    FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
                CONSTRAINT "FK_STAFF_PAYROLL_USER_staff_id"
                    FOREIGN KEY (staff_id) REFERENCES "USER" (user_id),
                CONSTRAINT "FK_STAFF_PAYROLL_USER_calculated_by"
                    FOREIGN KEY (calculated_by) REFERENCES "USER" (user_id)
            );

            CREATE INDEX IF NOT EXISTS "IX_STAFF_PAYROLL_staff_id"
                ON "STAFF_PAYROLL" (staff_id);
            CREATE INDEX IF NOT EXISTS "IX_STAFF_PAYROLL_calculated_by"
                ON "STAFF_PAYROLL" (calculated_by);
            CREATE UNIQUE INDEX IF NOT EXISTS "UQ_STAFF_PAYROLL_BranchStaffPeriod"
                ON "STAFF_PAYROLL" (branch_id, staff_id, period_start, period_end);
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            DROP TABLE IF EXISTS "STAFF_PAYROLL";
            DROP TABLE IF EXISTS "STAFF_PAY_RATE";
            """);
    }
}
