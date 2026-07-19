using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PharmacyChainsManagementBE.Migrations
{
    /// <inheritdoc />
    public partial class AddPaymentCurrencySettlement : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "base_currency",
                table: "PAYMENT_TRANSACTION",
                type: "character varying(3)",
                maxLength: 3,
                nullable: false,
                defaultValue: "USD");

            migrationBuilder.AddColumn<decimal>(
                name: "exchange_rate",
                table: "PAYMENT_TRANSACTION",
                type: "numeric(18,4)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "expected_amount_vnd",
                table: "PAYMENT_TRANSACTION",
                type: "numeric(18,0)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "received_amount_vnd",
                table: "PAYMENT_TRANSACTION",
                type: "numeric(18,0)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "settlement_currency",
                table: "PAYMENT_TRANSACTION",
                type: "character varying(3)",
                maxLength: 3,
                nullable: false,
                defaultValue: "USD");

            migrationBuilder.Sql(
                """
                UPDATE "PAYMENT_TRANSACTION"
                SET
                    exchange_rate = 25000,
                    expected_amount_vnd = ROUND(amount * 25000),
                    base_currency = 'USD',
                    settlement_currency = 'VND'
                WHERE payment_method = 'QR';
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "base_currency",
                table: "PAYMENT_TRANSACTION");

            migrationBuilder.DropColumn(
                name: "exchange_rate",
                table: "PAYMENT_TRANSACTION");

            migrationBuilder.DropColumn(
                name: "expected_amount_vnd",
                table: "PAYMENT_TRANSACTION");

            migrationBuilder.DropColumn(
                name: "received_amount_vnd",
                table: "PAYMENT_TRANSACTION");

            migrationBuilder.DropColumn(
                name: "settlement_currency",
                table: "PAYMENT_TRANSACTION");
        }
    }
}
