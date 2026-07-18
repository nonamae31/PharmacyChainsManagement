using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("BRANCH")]
public partial class Branch
{
    [Key]
    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("branch_name")]
    [StringLength(150)]
    public string BranchName { get; set; } = null!;

    [Column("address")]
    [StringLength(255)]
    public string Address { get; set; } = null!;

    [Column("phone")]
    [StringLength(30)]
    public string? Phone { get; set; }

    [Column("latitude", TypeName = "decimal(10, 7)")]
    public decimal? Latitude { get; set; }

    [Column("longitude", TypeName = "decimal(10, 7)")]
    public decimal? Longitude { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [InverseProperty("Branch")]
    public virtual ICollection<Inventory> Inventories { get; set; } = new List<Inventory>();

    [InverseProperty("Branch")]
    public virtual ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();

    [InverseProperty("Branch")]
    public virtual ICollection<Prescription> Prescriptions { get; set; } = new List<Prescription>();

    [InverseProperty("Branch")]
    public virtual ICollection<PurchaseOrder> PurchaseOrders { get; set; } = new List<PurchaseOrder>();

    [InverseProperty("FromBranch")]
    public virtual ICollection<StockTransfer> StockTransferFromBranches { get; set; } = new List<StockTransfer>();

    [InverseProperty("ToBranch")]
    public virtual ICollection<StockTransfer> StockTransferToBranches { get; set; } = new List<StockTransfer>();

    [InverseProperty("Branch")]
    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
