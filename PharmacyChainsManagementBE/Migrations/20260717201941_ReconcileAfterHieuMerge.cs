using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace PharmacyChainsManagementBE.Migrations
{
    /// <inheritdoc />
    public partial class ReconcileAfterHieuMerge : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "USER",
                columns: new[] { "user_id", "AccessFailedCount", "branch_id", "created_at", "email", "full_name", "is_deleted", "LockoutEnd", "must_change_password", "password_hash", "PasswordResetToken", "phone", "profile_photo_uri", "ResetTokenExpiry", "role_id", "status", "updated_at" },
                values: new object[,]
                {
                    { new Guid("11111111-1111-1111-1111-111111111112"), 0, null, new DateTime(2026, 7, 12, 0, 0, 0, 0, DateTimeKind.Utc), "businessadmin2@pharmacy.com", "Admin User 2", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 12, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("11111111-1111-1111-1111-111111111113"), 0, null, new DateTime(2026, 7, 12, 0, 0, 0, 0, DateTimeKind.Utc), "businessadmin3@pharmacy.com", "Admin User 3", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 12, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("11111111-1111-1111-1111-111111111114"), 0, null, new DateTime(2026, 7, 12, 0, 0, 0, 0, DateTimeKind.Utc), "businessadmin4@pharmacy.com", "Admin User 4", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 12, 0, 0, 0, 0, DateTimeKind.Utc) },
                    { new Guid("11111111-1111-1111-1111-111111111115"), 0, null, new DateTime(2026, 7, 12, 0, 0, 0, 0, DateTimeKind.Utc), "businessadmin5@pharmacy.com", "Admin User 5", false, null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 12, 0, 0, 0, 0, DateTimeKind.Utc) }
                });

            migrationBuilder.CreateIndex(
                name: "IX_User_IsDeleted_Filtered",
                table: "USER",
                column: "is_deleted",
                filter: "\"is_deleted\" = false");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_User_IsDeleted_Filtered",
                table: "USER");

            migrationBuilder.DeleteData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111112"));

            migrationBuilder.DeleteData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111113"));

            migrationBuilder.DeleteData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111114"));

            migrationBuilder.DeleteData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111115"));
        }
    }
}
