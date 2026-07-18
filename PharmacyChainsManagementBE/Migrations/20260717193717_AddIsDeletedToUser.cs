using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations
{
    /// <inheritdoc />
    public partial class AddIsDeletedToUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "is_deleted",
                table: "USER",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("11111111-1111-1111-1111-111111111111"),
                column: "is_deleted",
                value: false);

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("22222222-2222-2222-2222-222222222222"),
                column: "is_deleted",
                value: false);

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("33333333-3333-3333-3333-333333333333"),
                column: "is_deleted",
                value: false);

            migrationBuilder.UpdateData(
                table: "USER",
                keyColumn: "user_id",
                keyValue: new Guid("44444444-4444-4444-4444-444444444444"),
                column: "is_deleted",
                value: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "is_deleted",
                table: "USER");
        }
    }
}
