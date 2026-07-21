using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations
{
    /// <inheritdoc />
    public partial class AddStockReplenishmentRequests : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "STOCK_REPLENISHMENT_REQUEST",
                columns: table => new
                {
                    request_id = table.Column<Guid>(type: "uuid", nullable: false),
                    request_no = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    branch_id = table.Column<Guid>(type: "uuid", nullable: false),
                    requested_by = table.Column<Guid>(type: "uuid", nullable: false),
                    priority = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    status = table.Column<string>(type: "character varying(30)", maxLength: 30, nullable: false),
                    notes = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    inventory_note = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    request_date = table.Column<DateOnly>(type: "date", nullable: false),
                    processed_by = table.Column<Guid>(type: "uuid", nullable: true),
                    processed_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_STOCK_REPLENISHMENT_REQUEST", x => x.request_id);
                    table.ForeignKey(
                        name: "FK_STOCK_REPLENISHMENT_REQUEST_BRANCH_branch_id",
                        column: x => x.branch_id,
                        principalTable: "BRANCH",
                        principalColumn: "branch_id");
                    table.ForeignKey(
                        name: "FK_STOCK_REPLENISHMENT_REQUEST_USER_processed_by",
                        column: x => x.processed_by,
                        principalTable: "USER",
                        principalColumn: "user_id",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_STOCK_REPLENISHMENT_REQUEST_USER_requested_by",
                        column: x => x.requested_by,
                        principalTable: "USER",
                        principalColumn: "user_id");
                });

            migrationBuilder.CreateTable(
                name: "STOCK_REPLENISHMENT_REQUEST_DETAIL",
                columns: table => new
                {
                    request_detail_id = table.Column<Guid>(type: "uuid", nullable: false),
                    request_id = table.Column<Guid>(type: "uuid", nullable: false),
                    medicine_id = table.Column<Guid>(type: "uuid", nullable: false),
                    requested_quantity = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_STOCK_REPLENISHMENT_REQUEST_DETAIL", x => x.request_detail_id);
                    table.ForeignKey(
                        name: "FK_STOCK_REPLENISHMENT_REQUEST_DETAIL_MEDICINE_medicine_id",
                        column: x => x.medicine_id,
                        principalTable: "MEDICINE",
                        principalColumn: "medicine_id");
                    table.ForeignKey(
                        name: "FK_STOCK_REPLENISHMENT_REQUEST_DETAIL_STOCK_REPLENISHMENT_REQU~",
                        column: x => x.request_id,
                        principalTable: "STOCK_REPLENISHMENT_REQUEST",
                        principalColumn: "request_id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_REPLENISHMENT_REQUEST_branch_id",
                table: "STOCK_REPLENISHMENT_REQUEST",
                column: "branch_id");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_REPLENISHMENT_REQUEST_processed_by",
                table: "STOCK_REPLENISHMENT_REQUEST",
                column: "processed_by");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_REPLENISHMENT_REQUEST_request_no",
                table: "STOCK_REPLENISHMENT_REQUEST",
                column: "request_no",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_REPLENISHMENT_REQUEST_requested_by",
                table: "STOCK_REPLENISHMENT_REQUEST",
                column: "requested_by");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_REPLENISHMENT_REQUEST_DETAIL_medicine_id",
                table: "STOCK_REPLENISHMENT_REQUEST_DETAIL",
                column: "medicine_id");

            migrationBuilder.CreateIndex(
                name: "IX_STOCK_REPLENISHMENT_REQUEST_DETAIL_request_id_medicine_id",
                table: "STOCK_REPLENISHMENT_REQUEST_DETAIL",
                columns: new[] { "request_id", "medicine_id" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "STOCK_REPLENISHMENT_REQUEST_DETAIL");

            migrationBuilder.DropTable(
                name: "STOCK_REPLENISHMENT_REQUEST");
        }
    }
}
