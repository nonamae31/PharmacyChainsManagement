using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations;

public partial class AddStaffWeeklySchedule : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            CREATE TABLE IF NOT EXISTS "STAFF_WEEKLY_SCHEDULE" (
                weekly_schedule_id uuid NOT NULL,
                branch_id uuid NOT NULL,
                staff_id uuid NOT NULL,
                start_time time without time zone NOT NULL,
                end_time time without time zone NOT NULL,
                updated_by uuid NOT NULL,
                created_at timestamp with time zone NOT NULL,
                updated_at timestamp with time zone NOT NULL,
                CONSTRAINT "PK_STAFF_WEEKLY_SCHEDULE" PRIMARY KEY (weekly_schedule_id),
                CONSTRAINT "FK_STAFF_WEEKLY_SCHEDULE_BRANCH_branch_id"
                    FOREIGN KEY (branch_id) REFERENCES "BRANCH" (branch_id),
                CONSTRAINT "FK_STAFF_WEEKLY_SCHEDULE_USER_staff_id"
                    FOREIGN KEY (staff_id) REFERENCES "USER" (user_id),
                CONSTRAINT "FK_STAFF_WEEKLY_SCHEDULE_USER_updated_by"
                    FOREIGN KEY (updated_by) REFERENCES "USER" (user_id)
            );

            CREATE INDEX IF NOT EXISTS "IX_STAFF_WEEKLY_SCHEDULE_staff_id"
                ON "STAFF_WEEKLY_SCHEDULE" (staff_id);
            CREATE INDEX IF NOT EXISTS "IX_STAFF_WEEKLY_SCHEDULE_updated_by"
                ON "STAFF_WEEKLY_SCHEDULE" (updated_by);
            CREATE UNIQUE INDEX IF NOT EXISTS "UQ_STAFF_WEEKLY_SCHEDULE_BranchStaff"
                ON "STAFF_WEEKLY_SCHEDULE" (branch_id, staff_id);

            INSERT INTO "STAFF_WEEKLY_SCHEDULE" (
                weekly_schedule_id, branch_id, staff_id, start_time, end_time,
                updated_by, created_at, updated_at)
            SELECT gen_random_uuid(), latest.branch_id, latest.staff_id,
                   latest.start_time, latest.end_time, latest.created_by,
                   NOW(), NOW()
            FROM (
                SELECT DISTINCT ON (branch_id, staff_id)
                       branch_id, staff_id, start_time, end_time, created_by
                FROM "STAFF_SHIFT"
                WHERE status = 'SCHEDULED'
                ORDER BY branch_id, staff_id, shift_date DESC, updated_at DESC
            ) latest
            ON CONFLICT (branch_id, staff_id) DO NOTHING;

            UPDATE "STAFF_SHIFT"
            SET status = 'OFF', updated_at = NOW()
            WHERE status = 'SCHEDULED'
              AND EXTRACT(ISODOW FROM shift_date) = 7
              AND shift_date >= CURRENT_DATE;
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql("DROP TABLE IF EXISTS \"STAFF_WEEKLY_SCHEDULE\";");
    }
}
