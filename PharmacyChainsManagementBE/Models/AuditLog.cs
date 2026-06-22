using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("AUDIT_LOG")]
public partial class AuditLog
{
    [Key]
    [Column("audit_id")]
    public Guid AuditId { get; set; }

    [Column("actor_id")]
    public Guid ActorId { get; set; }

    [Column("entity_name")]
    [StringLength(100)]
    public string EntityName { get; set; } = null!;

    [Column("entity_id")]
    public Guid EntityId { get; set; }

    [Column("action")]
    [StringLength(50)]
    public string Action { get; set; } = null!;

    [Column("old_value")]
    public string? OldValue { get; set; }

    [Column("new_value")]
    public string? NewValue { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [ForeignKey("ActorId")]
    [InverseProperty("AuditLogs")]
    public virtual User Actor { get; set; } = null!;
}
