using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Controllers
{
    [Route("api/branches")]
    [ApiController]
    public class BranchesController : ControllerBase
    {
        private readonly PharmacyDbContext _context;

        public BranchesController(PharmacyDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetBranches()
        {
            var branches = await _context.Branches
                .Where(b => b.Status != "Inactive")
                .Select(b => new { Id = b.BranchId, Name = b.BranchName })
                .ToListAsync();
            return Ok(branches);
        }
    }
}
