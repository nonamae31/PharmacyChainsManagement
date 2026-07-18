using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using PharmacyChainsManagementBE.Models;
using PharmacyChainsManagementBE.Security;
using PharmacyChainsManagementBE.Services;
using Microsoft.EntityFrameworkCore;

namespace PharmacyChainsManagementBE.Controllers
{
    [ApiController]
    [Route("api/v1/seed")]
    public class SeedController : ControllerBase
    {
        private readonly PharmacyDbContext _context;
        private readonly IPasswordHashingStrategy _passwordHasher;

        public SeedController(PharmacyDbContext context, IPasswordHashingStrategy passwordHasher)
        {
            _context = context;
            _passwordHasher = passwordHasher;
        }

        [HttpPost("run")]
        public async Task<IActionResult> RunSeed()
        {
            try
            {
                _context.Database.SetCommandTimeout(300);
                var pwd = _passwordHasher.HashPassword("Founder@123");
                
                string sql = $@"
                    -- 1. Ensure Role
                    INSERT INTO ""ROLE"" (role_id, role_code, role_name, is_active)
                    SELECT 99, 'Founder', 'Founder Role', true
                    WHERE NOT EXISTS (SELECT 1 FROM ""ROLE"" WHERE role_code = 'Founder');

                    -- 2. Ensure Founder User
                    INSERT INTO ""USER"" (user_id, role_id, full_name, email, password_hash, status, created_at, updated_at, must_change_password, is_deleted, ""AccessFailedCount"")
                    SELECT gen_random_uuid(), (SELECT role_id FROM ""ROLE"" WHERE role_code = 'Founder' LIMIT 1), 'E2E Founder', 'founder@pharmacy.com', '{pwd}', 'Active', NOW(), NOW(), false, false, 0
                    WHERE NOT EXISTS (SELECT 1 FROM ""USER"" WHERE email = 'founder@pharmacy.com');
                    
                    -- 3. Ensure Branch
                    INSERT INTO ""BRANCH"" (branch_id, branch_name, address, status, created_at, updated_at)
                    SELECT gen_random_uuid(), 'E2E Test Branch', '123 E2E Street', 'Active', NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""BRANCH"" WHERE branch_name = 'E2E Test Branch');
                    
                    -- 4. Seed Invoices for Revenue
                    INSERT INTO ""INVOICE"" (invoice_id, branch_id, staff_id, invoice_code, invoice_date, total_amount, payment_status, status, created_at, updated_at)
                    SELECT gen_random_uuid(), 
                           (SELECT branch_id FROM ""BRANCH"" WHERE branch_name = 'E2E Test Branch' LIMIT 1),
                           (SELECT user_id FROM ""USER"" WHERE email = 'founder@pharmacy.com' LIMIT 1),
                           'INV-E2E-1', CURRENT_DATE, 5000000, 'Paid', 'Completed', NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""INVOICE"" WHERE invoice_code = 'INV-E2E-1');

                    INSERT INTO ""INVOICE"" (invoice_id, branch_id, staff_id, invoice_code, invoice_date, total_amount, payment_status, status, created_at, updated_at)
                    SELECT gen_random_uuid(), 
                           (SELECT branch_id FROM ""BRANCH"" WHERE branch_name = 'E2E Test Branch' LIMIT 1),
                           (SELECT user_id FROM ""USER"" WHERE email = 'founder@pharmacy.com' LIMIT 1),
                           'INV-E2E-2', CURRENT_DATE - INTERVAL '1 day', 3500000, 'Paid', 'Completed', NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""INVOICE"" WHERE invoice_code = 'INV-E2E-2');
                    
                    -- 5. Seed Payment Transactions (Cash Flow Inflow)
                    INSERT INTO ""PAYMENT_TRANSACTION"" (payment_id, invoice_id, amount, payment_method, payment_status, payment_date, created_at, updated_at)
                    SELECT gen_random_uuid(), 
                           (SELECT invoice_id FROM ""INVOICE"" WHERE invoice_code = 'INV-E2E-1' LIMIT 1),
                           5000000, 'Cash', 'Paid', NOW(), NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""PAYMENT_TRANSACTION"" WHERE amount = 5000000 AND payment_method = 'Cash');
                    
                    -- 6. Ensure Supplier
                    INSERT INTO ""SUPPLIER"" (supplier_id, supplier_name, status, created_at, updated_at)
                    SELECT gen_random_uuid(), 'E2E Supplier', 'Active', NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""SUPPLIER"" WHERE supplier_name = 'E2E Supplier');

                    -- 7. Ensure Purchase Order (Cash Flow Outflow)
                    INSERT INTO ""PURCHASE_ORDER"" (po_id, supplier_id, branch_id, created_by, approved_by, po_status, order_date, expected_date, created_at, updated_at)
                    SELECT gen_random_uuid(),
                           (SELECT supplier_id FROM ""SUPPLIER"" WHERE supplier_name = 'E2E Supplier' LIMIT 1),
                           (SELECT branch_id FROM ""BRANCH"" WHERE branch_name = 'E2E Test Branch' LIMIT 1),
                           (SELECT user_id FROM ""USER"" WHERE email = 'founder@pharmacy.com' LIMIT 1),
                           (SELECT user_id FROM ""USER"" WHERE email = 'founder@pharmacy.com' LIMIT 1),
                           'Approved', CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day', NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""PURCHASE_ORDER"" WHERE po_status = 'Approved' AND created_at >= CURRENT_DATE);

                    -- 8. Seed Medicine (if needed for PO details, though GetCashFlowQueryHandler doesn't join medicine, we might need a detail)
                    -- Wait, the query is: SELECT SUM(line_total) FROM PURCHASE_ORDER_DETAIL pod INNER JOIN PURCHASE_ORDER po ...
                    -- So we need a PURCHASE_ORDER_DETAIL! But MedicineId might be required by foreign key.
                    -- Let's just insert one if we can, or bypass FK if we don't know the medicine.
                    -- Actually we can just find any medicine!
                    INSERT INTO ""PURCHASE_ORDER_DETAIL"" (po_detail_id, po_id, medicine_id, ordered_quantity, unit_price, line_total)
                    SELECT gen_random_uuid(),
                           (SELECT po_id FROM ""PURCHASE_ORDER"" WHERE po_status = 'Approved' LIMIT 1),
                           (SELECT medicine_id FROM ""MEDICINE"" LIMIT 1), -- Assuming at least one medicine exists, or we skip if none!
                           10, 50000, 500000
                    WHERE EXISTS (SELECT 1 FROM ""MEDICINE"" LIMIT 1) 
                      AND NOT EXISTS (SELECT 1 FROM ""PURCHASE_ORDER_DETAIL"" WHERE line_total = 500000);

                    -- 9. Seed Budget Allocation
                    INSERT INTO ""BUDGET_ALLOCATION"" (allocation_id, category_name, percentage, created_at, updated_at)
                    SELECT gen_random_uuid(), 'Ops & Maintenance', 65.0, NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""BUDGET_ALLOCATION"" WHERE category_name = 'Ops & Maintenance');

                    INSERT INTO ""BUDGET_ALLOCATION"" (allocation_id, category_name, percentage, created_at, updated_at)
                    SELECT gen_random_uuid(), 'Branch Expansion', 22.0, NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""BUDGET_ALLOCATION"" WHERE category_name = 'Branch Expansion');

                    INSERT INTO ""BUDGET_ALLOCATION"" (allocation_id, category_name, percentage, created_at, updated_at)
                    SELECT gen_random_uuid(), 'R&D Projects', 13.0, NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""BUDGET_ALLOCATION"" WHERE category_name = 'R&D Projects');

                    -- 10. Seed Liquidity Forecast (July to November 2024 for example)
                    INSERT INTO ""LIQUIDITY_FORECAST"" (forecast_id, forecast_date, projected_inflow, projected_outflow, created_at, updated_at)
                    SELECT gen_random_uuid(), '2024-07-01', 5000000, 2000000, NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""LIQUIDITY_FORECAST"" WHERE forecast_date = '2024-07-01');

                    INSERT INTO ""LIQUIDITY_FORECAST"" (forecast_id, forecast_date, projected_inflow, projected_outflow, created_at, updated_at)
                    SELECT gen_random_uuid(), '2024-08-01', 5200000, 2100000, NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""LIQUIDITY_FORECAST"" WHERE forecast_date = '2024-08-01');

                    INSERT INTO ""LIQUIDITY_FORECAST"" (forecast_id, forecast_date, projected_inflow, projected_outflow, created_at, updated_at)
                    SELECT gen_random_uuid(), '2024-09-01', 5400000, 2300000, NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""LIQUIDITY_FORECAST"" WHERE forecast_date = '2024-09-01');

                    INSERT INTO ""LIQUIDITY_FORECAST"" (forecast_id, forecast_date, projected_inflow, projected_outflow, created_at, updated_at)
                    SELECT gen_random_uuid(), '2024-10-01', 5600000, 2500000, NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""LIQUIDITY_FORECAST"" WHERE forecast_date = '2024-10-01');

                    INSERT INTO ""LIQUIDITY_FORECAST"" (forecast_id, forecast_date, projected_inflow, projected_outflow, created_at, updated_at)
                    SELECT gen_random_uuid(), '2024-11-01', 6000000, 2600000, NOW(), NOW()
                    WHERE NOT EXISTS (SELECT 1 FROM ""LIQUIDITY_FORECAST"" WHERE forecast_date = '2024-11-01');
                ";
                
                await _context.Database.ExecuteSqlRawAsync(sql);
                return Ok("Seed data injected successfully via raw SQL!");
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.ToString());
            }
        }
    }
}
