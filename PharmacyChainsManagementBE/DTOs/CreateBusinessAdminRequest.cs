using System.ComponentModel.DataAnnotations;

namespace PharmacyChainsManagementBE.DTOs
{
    public class CreateBusinessAdminRequest
    {
        public string FullName { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string Phone { get; set; } = null!;
    }
}
