using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace PharmacyChainsManagementBE.Migrations
{
    /// <inheritdoc />
    public partial class AddMustChangePassword : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "must_change_password",
                table: "USER",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "created_at", "email", "must_change_password", "password_hash", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3525), "businessadmin@pharmacy.com", false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3529) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "created_at", "must_change_password", "password_hash", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3538), false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3539) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "created_at", "must_change_password", "password_hash", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3544), false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3545) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "created_at", "must_change_password", "password_hash", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3553), false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3553) });

            migrationBuilder.InsertData(
                table: "USER",
                columns: new[] { "user_id", "AccessFailedCount", "branch_id", "created_at", "email", "full_name", "LockoutEnd", "must_change_password", "password_hash", "PasswordResetToken", "phone", "profile_photo_uri", "ResetTokenExpiry", "role_id", "status", "updated_at" },
                values: new object[,]
                {
                    { new Guid("11111111-1111-1111-1111-111111111112"), 0, null, new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3559), "businessadmin2@pharmacy.com", "Admin User 2", null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3560) },
                    { new Guid("11111111-1111-1111-1111-111111111113"), 0, null, new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3705), "businessadmin3@pharmacy.com", "Admin User 3", null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3706) },
                    { new Guid("11111111-1111-1111-1111-111111111114"), 0, null, new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3712), "businessadmin4@pharmacy.com", "Admin User 4", null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3713) },
                    { new Guid("11111111-1111-1111-1111-111111111115"), 0, null, new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3719), "businessadmin5@pharmacy.com", "Admin User 5", null, false, "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a", null, null, null, null, (short)1, "ACTIVE", new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3720) }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
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

            migrationBuilder.DropColumn(
                name: "must_change_password",
                table: "USER");

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "created_at", "email", "password_hash", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 12, 15, 37, 1, 66, DateTimeKind.Utc).AddTicks(2176), "admin@pharmacy.com", "$2a$11$NMSJsKiD6hr4KnXcEnV5vOCbPKnfHRtJKJLZxMPJ6EPgxFstFsSUi", new DateTime(2026, 7, 12, 15, 37, 1, 66, DateTimeKind.Utc).AddTicks(2183) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "created_at", "password_hash", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 12, 15, 37, 1, 66, DateTimeKind.Utc).AddTicks(2192), "$2a$11$NMSJsKiD6hr4KnXcEnV5vOCbPKnfHRtJKJLZxMPJ6EPgxFstFsSUi", new DateTime(2026, 7, 12, 15, 37, 1, 66, DateTimeKind.Utc).AddTicks(2192) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "created_at", "password_hash", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 12, 15, 37, 1, 66, DateTimeKind.Utc).AddTicks(2196), "$2a$11$NMSJsKiD6hr4KnXcEnV5vOCbPKnfHRtJKJLZxMPJ6EPgxFstFsSUi", new DateTime(2026, 7, 12, 15, 37, 1, 66, DateTimeKind.Utc).AddTicks(2197) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "created_at", "password_hash", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 12, 15, 37, 1, 66, DateTimeKind.Utc).AddTicks(2291), "$2a$11$NMSJsKiD6hr4KnXcEnV5vOCbPKnfHRtJKJLZxMPJ6EPgxFstFsSUi", new DateTime(2026, 7, 12, 15, 37, 1, 66, DateTimeKind.Utc).AddTicks(2292) });
        }
    }
}
