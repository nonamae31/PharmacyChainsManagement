using System;

namespace PharmacyChainsManagementBE.DTOs.Responses;

public class BusinessAdminDetailResponse
{
    public Guid UserId { get; set; }
    public string FullName { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string? Phone { get; set; }
    public string Status { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public string? ProfilePhotoUri { get; set; }
    public string? Address { get; set; }
    public DateTime? DateOfBirth { get; set; }
    public string? Gender { get; set; }
}
