using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations
{
    /// <inheritdoc />
    public partial class AddUserProfileFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "address",
                table: "USER",
                type: "character varying(255)",
                maxLength: 255,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "date_of_birth",
                table: "USER",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "gender",
                table: "USER",
                type: "character varying(10)",
                maxLength: 10,
                nullable: true);

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "address", "created_at", "date_of_birth", "gender", "updated_at" },
                values: new object[] { null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4046), null, null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4049) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111112"),
                columns: new[] { "address", "created_at", "date_of_birth", "gender", "updated_at" },
                values: new object[] { null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4072), null, null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4074) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111113"),
                columns: new[] { "address", "created_at", "date_of_birth", "gender", "updated_at" },
                values: new object[] { null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4077), null, null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4078) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111114"),
                columns: new[] { "address", "created_at", "date_of_birth", "gender", "updated_at" },
                values: new object[] { null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4082), null, null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4083) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111115"),
                columns: new[] { "address", "created_at", "date_of_birth", "gender", "updated_at" },
                values: new object[] { null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4087), null, null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4088) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "address", "created_at", "date_of_birth", "gender", "updated_at" },
                values: new object[] { null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4055), null, null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4056) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "address", "created_at", "date_of_birth", "gender", "updated_at" },
                values: new object[] { null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4063), null, null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4064) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "address", "created_at", "date_of_birth", "gender", "updated_at" },
                values: new object[] { null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4068), null, null, new DateTime(2026, 7, 18, 14, 18, 59, 378, DateTimeKind.Utc).AddTicks(4069) });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "address",
                table: "USER");

            migrationBuilder.DropColumn(
                name: "date_of_birth",
                table: "USER");

            migrationBuilder.DropColumn(
                name: "gender",
                table: "USER");

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8388), new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8394) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111112"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8446), new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8447) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111113"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8450), new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8450) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111114"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8458), new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8459) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111115"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8462), new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8463) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8399), new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8399) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8438), new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8439) });

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                columns: new[] { "created_at", "updated_at" },
                values: new object[] { new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8443), new DateTime(2026, 7, 17, 16, 55, 35, 866, DateTimeKind.Utc).AddTicks(8443) });
        }
    }
}
