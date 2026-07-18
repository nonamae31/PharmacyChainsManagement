using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations
{
    /// <inheritdoc />
    public partial class AddBudgetAllocationAndLiquidityForecast : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BUDGET_ALLOCATION",
                columns: table => new
                {
                    allocation_id = table.Column<Guid>(type: "uuid", nullable: false),
                    category_name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    percentage = table.Column<decimal>(type: "numeric(5,2)", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BUDGET_ALLOCATION", x => x.allocation_id);
                });

            migrationBuilder.CreateTable(
                name: "LIQUIDITY_FORECAST",
                columns: table => new
                {
                    forecast_id = table.Column<Guid>(type: "uuid", nullable: false),
                    forecast_date = table.Column<DateOnly>(type: "date", nullable: false),
                    projected_inflow = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    projected_outflow = table.Column<decimal>(type: "numeric(12,2)", nullable: false),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LIQUIDITY_FORECAST", x => x.forecast_id);
                });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7942), new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7945) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111112"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7963), new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7965) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111113"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7968), new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7968) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111114"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7971), new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7972) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111115"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7976), new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7976) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7950), new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7951) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7956), new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7956) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7960), new DateTime(2026, 7, 18, 14, 42, 16, 246, DateTimeKind.Utc).AddTicks(7960) });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BUDGET_ALLOCATION");

            migrationBuilder.DropTable(
                name: "LIQUIDITY_FORECAST");

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4046), new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4049) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111112"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4072), new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4074) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111113"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4077), new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4078) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111114"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4082), new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4083) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111115"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4087), new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4088) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4055), new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4056) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4063), new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4064) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4068), new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4069) });
        }
    }
}
