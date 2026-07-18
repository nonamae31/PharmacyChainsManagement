using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("USER")]
[Index("Email", Name = "UQ__USER__AB6E6164A2B157E7", IsUnique = true)]
public partial class User
{
    [Key]
    [Column("user_id")]
    public Guid UserId { get; set; }

    [Column("role_id")]
    public short RoleId { get; set; }

    [Column("branch_id")]
    public Guid? BranchId { get; set; }

    [Column("full_name")]
    [StringLength(150)]
    public string FullName { get; set; } = null!;

    [Column("email")]
    [StringLength(150)]
    public string Email { get; set; } = null!;

    [Column("password_hash")]
    [StringLength(255)]
    public string PasswordHash { get; set; } = null!;

    [Column("phone")]
    [StringLength(30)]
    public string? Phone { get; set; }

    [Column("profile_photo_uri")]
    [StringLength(255)]
    public string? ProfilePhotoUri { get; set; }

    [Column("status")]
    [StringLength(30)]
    public string Status { get; set; } = null!;

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }

    [InverseProperty("Actor")]
    public virtual ICollection<AuditLog> AuditLogs { get; set; } = new List<AuditLog>();

    [ForeignKey("BranchId")]
    [InverseProperty("Users")]
    public virtual Branch? Branch { get; set; }

    [InverseProperty("Staff")]
    public virtual ICollection<Invoice> Invoices { get; set; } = new List<Invoice>();

    [InverseProperty("Staff")]
    public virtual ICollection<Prescription> Prescriptions { get; set; } = new List<Prescription>();

    [InverseProperty("ApprovedByNavigation")]
    public virtual ICollection<PurchaseOrder> PurchaseOrderApprovedByNavigations { get; set; } = new List<PurchaseOrder>();

    [InverseProperty("CreatedByNavigation")]
    public virtual ICollection<PurchaseOrder> PurchaseOrderCreatedByNavigations { get; set; } = new List<PurchaseOrder>();

    [InverseProperty("GeneratedByNavigation")]
    public virtual ICollection<Report> Reports { get; set; } = new List<Report>();

    [ForeignKey("RoleId")]
    [InverseProperty("Users")]
    public virtual Role Role { get; set; } = null!;

    [InverseProperty("ApprovedByNavigation")]
    public virtual ICollection<StockTransfer> StockTransferApprovedByNavigations { get; set; } = new List<StockTransfer>();

    [InverseProperty("RequestedByNavigation")]
    public virtual ICollection<StockTransfer> StockTransferRequestedByNavigations { get; set; } = new List<StockTransfer>();
}
