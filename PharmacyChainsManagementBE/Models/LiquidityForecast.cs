using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PharmacyChainsManagementBE.Models;

[Table("LIQUIDITY_FORECAST")]
public class LiquidityForecast
{
    [Key]
    [Column("forecast_id")]
    public Guid ForecastId { get; set; } = Guid.NewGuid();

    [Column("forecast_date")]
    public DateOnly ForecastDate { get; set; }

    [Column("projected_inflow", TypeName = "decimal(12, 2)")]
    public decimal ProjectedInflow { get; set; }

    [Column("projected_outflow", TypeName = "decimal(12, 2)")]
    public decimal ProjectedOutflow { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
