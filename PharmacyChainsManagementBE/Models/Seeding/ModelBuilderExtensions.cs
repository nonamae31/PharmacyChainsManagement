using Microsoft.EntityFrameworkCore;
using System;

namespace PharmacyChainsManagementBE.Models;

public static class ModelBuilderExtensions
{
    public static void SeedRolesAndUsers(this ModelBuilder modelBuilder)
    {
        var seededAt = new DateTime(2026, 7, 12, 0, 0, 0, DateTimeKind.Utc);

        // Add roles
        modelBuilder.Entity<Role>().HasData(
            new Role { RoleId = 1, RoleCode = "BUSINESS_ADMIN", RoleName = "Business Admin", IsActive = true },
            new Role { RoleId = 2, RoleCode = "BRANCH_MANAGER", RoleName = "Branch Manager", IsActive = true },
            new Role { RoleId = 3, RoleCode = "STAFF", RoleName = "Staff", IsActive = true },
            new Role { RoleId = 4, RoleCode = "INVENTORY_MANAGER", RoleName = "Inventory Manager", IsActive = true }
        );

        // Pre-generate one static hash to avoid migration noise
        // This is a known valid BCrypt hash for "123456"
        var passwordHash = "$2a$11$IYQJvf0r3oqJXCtfmuNC.ut.sFypUr1LtCajqdfXki2WAbbAu3p4a";

        // Add users
        modelBuilder.Entity<User>().HasData(
            new User
            {
                UserId = Guid.Parse("11111111-1111-1111-1111-111111111111"),
                RoleId = 1,
                FullName = "Admin User",
                Email = "businessadmin@pharmacy.com",
                PasswordHash = passwordHash,
                Status = "ACTIVE",
                CreatedAt = seededAt,
                UpdatedAt = seededAt
            },
            new User
            {
                UserId = Guid.Parse("22222222-2222-2222-2222-222222222222"),
                RoleId = 2,
                FullName = "Manager User",
                Email = "manager@pharmacy.com",
                PasswordHash = passwordHash,
                Status = "ACTIVE",
                CreatedAt = seededAt,
                UpdatedAt = seededAt
            },
            new User
            {
                UserId = Guid.Parse("33333333-3333-3333-3333-333333333333"),
                RoleId = 3,
                FullName = "Staff User",
                Email = "staff@pharmacy.com",
                PasswordHash = passwordHash,
                Status = "ACTIVE",
                CreatedAt = seededAt,
                UpdatedAt = seededAt
            },
            new User
            {
                UserId = Guid.Parse("44444444-4444-4444-4444-444444444444"),
                RoleId = 4,
                FullName = "Inventory Manager",
                Email = "phanmanh14122000@gmail.com",
                PasswordHash = passwordHash,
                Status = "ACTIVE",
                CreatedAt = seededAt,
                UpdatedAt = seededAt
            },
            new User
            {
                UserId = Guid.Parse("11111111-1111-1111-1111-111111111112"),
                RoleId = 1,
                FullName = "Admin User 2",
                Email = "businessadmin2@pharmacy.com",
                PasswordHash = passwordHash,
                Status = "ACTIVE",
                CreatedAt = seededAt,
                UpdatedAt = seededAt
            },
            new User
            {
                UserId = Guid.Parse("11111111-1111-1111-1111-111111111113"),
                RoleId = 1,
                FullName = "Admin User 3",
                Email = "businessadmin3@pharmacy.com",
                PasswordHash = passwordHash,
                Status = "ACTIVE",
                CreatedAt = seededAt,
                UpdatedAt = seededAt
            },
            new User
            {
                UserId = Guid.Parse("11111111-1111-1111-1111-111111111114"),
                RoleId = 1,
                FullName = "Admin User 4",
                Email = "businessadmin4@pharmacy.com",
                PasswordHash = passwordHash,
                Status = "ACTIVE",
                CreatedAt = seededAt,
                UpdatedAt = seededAt
            },
            new User
            {
                UserId = Guid.Parse("11111111-1111-1111-1111-111111111115"),
                RoleId = 1,
                FullName = "Admin User 5",
                Email = "businessadmin5@pharmacy.com",
                PasswordHash = passwordHash,
                Status = "ACTIVE",
                CreatedAt = seededAt,
                UpdatedAt = seededAt
            }
        );
    }
}
