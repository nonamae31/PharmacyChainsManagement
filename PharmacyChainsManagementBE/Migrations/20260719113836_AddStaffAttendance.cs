using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations
{
    public partial class AddStaffAttendance : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "STAFF_ATTENDANCE",
                columns: table => new
                {
                    attendance_id = table.Column<Guid>(type: "uuid", nullable: false),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    branch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    attendance_date = table.Column<DateOnly>(type: "date", nullable: false),
                    check_in_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    check_out_time = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_STAFF_ATTENDANCE", x => x.attendance_id);
                    table.ForeignKey(
                        name: "FK_STAFF_ATTENDANCE_BRANCH_branch_id",
                        column: x => x.branch_id,
                        principalTable: "BRANCH",
                        principalColumn: "branch_id");
                    table.ForeignKey(
                        name: "FK_STAFF_ATTENDANCE_USER_staff_id",
                        column: x => x.staff_id,
                        principalTable: "USER",
                        principalColumn: "user_id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_STAFF_ATTENDANCE_BranchDate",
                table: "STAFF_ATTENDANCE",
                columns: new[] { "branch_id", "attendance_date" });

            migrationBuilder.CreateIndex(
                name: "UQ_STAFF_ATTENDANCE_StaffDate",
                table: "STAFF_ATTENDANCE",
                columns: new[] { "staff_id", "attendance_date" },
                unique: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(name: "STAFF_ATTENDANCE");
        }
    }
}
