using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("INVOICE")]
[Index("InvoiceCode", Name = "UQ__INVOICE__5ED70A35B0ECDDDB", IsUnique = true)]
public partial class Invoice
{
    [Key]
    [Column("invoice_id")]
    public Guid InvoiceId { get; set; }

    [Column("branch_id")]
    public Guid BranchId { get; set; }

    [Column("staff_id")]
    public Guid StaffId { get; set; }

    [Column("prescription_id")]
    public Guid? PrescriptionId { get; set; }

    [Column("invoice_code")]
    [StringLength(50)]
    public string InvoiceCode { get; set; } = null!;

    [Column("invoice_date")]
    public DateOnly InvoiceDate { get; set; }

    [Column("total_amount", TypeName = "decimal(12, 2)")]
    public decimal TotalAmount { get; set; }

    [Column("payment_status")]
    [StringLength(30)]
    public string PaymentStatus { get; set; } = null!;

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [ForeignKey("BranchId")]
    [InverseProperty("Invoices")]
    public virtual Branch Branch { get; set; } = null!;

    [InverseProperty("Invoice")]
    public virtual ICollection<InvoiceDetail> InvoiceDetails { get; set; } = new List<InvoiceDetail>();

    [InverseProperty("Invoice")]
    public virtual ICollection<PaymentTransaction> PaymentTransactions { get; set; } = new List<PaymentTransaction>();

    [ForeignKey("PrescriptionId")]
    [InverseProperty("Invoices")]
    public virtual Prescription? Prescription { get; set; }

    [ForeignKey("StaffId")]
    [InverseProperty("Invoices")]
    public virtual User Staff { get; set; } = null!;
}
