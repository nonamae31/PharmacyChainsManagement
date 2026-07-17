using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations
{
    /// <inheritdoc />
    public partial class FixMustChangePassword : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1358), new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1362) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111112"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1430), new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1431) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111113"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1435), new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1436) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111114"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1442), new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1442) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111115"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1446), new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1447) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1368), new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1369) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1373), new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1374) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1425), new DateTime(2026, 7, 16, 17, 7, 24, 92, DateTimeKind.Utc).AddTicks(1426) });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3525), new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3529) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111112"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3559), new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3560) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111113"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3705), new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3706) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111114"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3712), new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3713) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111115"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3719), new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3720) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3538), new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3539) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3544), new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3545) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3553), new DateTime(2026, 7, 15, 16, 3, 17, 88, DateTimeKind.Utc).AddTicks(3553) });
        }
    }
}
