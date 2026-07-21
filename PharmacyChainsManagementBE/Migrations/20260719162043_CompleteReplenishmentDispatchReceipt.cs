using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations
{
    /// <inheritdoc />
    public partial class CompleteReplenishmentDispatchReceipt : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "dispatched_at",
                table: "STOCK_REPLENISHMENT_REQUEST",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "received_at",
                table: "STOCK_REPLENISHMENT_REQUEST",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "received_by",
                table: "STOCK_REPLENISHMENT_REQUEST",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "transfer_id",
                table: "STOCK_REPLENISHMENT_REQUEST",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_REPLENISHMENT_REQUEST_received_by",
                table: "STOCK_REPLENISHMENT_REQUEST",
                column: "received_by");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_REPLENISHMENT_REQUEST_transfer_id",
                table: "STOCK_REPLENISHMENT_REQUEST",
                column: "transfer_id",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_STOCK_REPLENISHMENT_REQUEST_STOCK_TRANSFER_transfer_id",
                table: "STOCK_REPLENISHMENT_REQUEST",
                column: "transfer_id",
                principalTable: "STOCK_TRANSFER",
                principalColumn: "transfer_id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_STOCK_REPLENISHMENT_REQUEST_USER_received_by",
                table: "STOCK_REPLENISHMENT_REQUEST",
                column: "received_by",
                principalTable: "USER",
                principalColumn: "user_id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_STOCK_REPLENISHMENT_REQUEST_STOCK_TRANSFER_transfer_id",
                table: "STOCK_REPLENISHMENT_REQUEST");

            migrationBuilder.DropForeignKey(
                name: "FK_STOCK_REPLENISHMENT_REQUEST_USER_received_by",
                table: "STOCK_REPLENISHMENT_REQUEST");

            migrationBuilder.DropIndex(
                name: "IX_STOCK_REPLENISHMENT_REQUEST_received_by",
                table: "STOCK_REPLENISHMENT_REQUEST");

            migrationBuilder.DropIndex(
                name: "IX_STOCK_REPLENISHMENT_REQUEST_transfer_id",
                table: "STOCK_REPLENISHMENT_REQUEST");

            migrationBuilder.DropColumn(
                name: "dispatched_at",
                table: "STOCK_REPLENISHMENT_REQUEST");

            migrationBuilder.DropColumn(
                name: "received_at",
                table: "STOCK_REPLENISHMENT_REQUEST");

            migrationBuilder.DropColumn(
                name: "received_by",
                table: "STOCK_REPLENISHMENT_REQUEST");

            migrationBuilder.DropColumn(
                name: "transfer_id",
                table: "STOCK_REPLENISHMENT_REQUEST");
        }
    }
}
