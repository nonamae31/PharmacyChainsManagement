using System;

namespace PharmacyChainsManagementBE.DTOs.Responses;

public class BusinessAdminDetailResponse
{
    public Guid Id { get; set; }
    public string Name { get; set; } = null!;
    public string Email { get; set; } = null!;
    public string Status { get; set; } = null!;
}
