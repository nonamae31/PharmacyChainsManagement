using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("SUPPLIER")]
public partial class Supplier
{
    [Key]
    [Column("supplier_id")]
    public Guid SupplierId { get; set; }

    [Column("supplier_name")]
    [StringLength(150)]
    public string SupplierName { get; set; } = null!;

    [Column("contact_person")]
    [StringLength(150)]
    public string? ContactPerson { get; set; }

    [Column("email")]
    [StringLength(150)]
    public string? Email { get; set; }

    [Column("phone")]
    [StringLength(30)]
    public string? Phone { get; set; }

    [Column("address")]
    [StringLength(255)]
    public string? Address { get; set; }

    [Column("tax_code")]
    [StringLength(50)]
    public string? TaxCode { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [InverseProperty("Supplier")]
    public virtual ICollection<MedicineBatch> MedicineBatches { get; set; } = new List<MedicineBatch>();

    [InverseProperty("Supplier")]
    public virtual ICollection<PurchaseOrder> PurchaseOrders { get; set; } = new List<PurchaseOrder>();
}
