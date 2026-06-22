using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

[Table("ROLE")]
[Index("RoleCode", Name = "UQ__ROLE__BAE6307522F2B53F", IsUnique = true)]
public partial class Role
{
    [Key]
    [Column("role_id")]
    public short RoleId { get; set; }

    [Column("role_code")]
    [StringLength(50)]
    public string RoleCode { get; set; } = null!;

    [Column("role_name")]
    [StringLength(100)]
    public string RoleName { get; set; } = null!;

    [Column("is_active")]
    public bool IsActive { get; set; }

    [InverseProperty("Role")]
    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
