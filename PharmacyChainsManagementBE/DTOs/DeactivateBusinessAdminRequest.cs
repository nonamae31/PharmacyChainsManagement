using System;
using System.ComponentModel.DataAnnotations;

namespace PharmacyChainsManagementBE.DTOs;

public class DeactivateBusinessAdminRequest
{
    [Required(ErrorMessage = "Lý do vô hiệu hóa là bắt buộc.")]
    [MaxLength(500, ErrorMessage = "Lý do không được vượt quá 500 ký tự.")]
    public string Reason { get; set; } = string.Empty;
}
