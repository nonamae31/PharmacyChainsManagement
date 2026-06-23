using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Models;

public partial class PharmacyDbContext
{
    public virtual DbSet<UserSession> UserSessions { get; set; }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserSession>(entity =>
        {
            entity.HasKey(e => e.SessionId).HasName("PK__USER_SES__session_id");

            entity.Property(e => e.SessionId).ValueGeneratedNever();

            entity.Property(e => e.RefreshToken).IsRequired();

            entity.HasIndex(e => e.RefreshToken).IsUnique(false);

            entity.HasIndex(e => e.UserId);
        });
    }
}
