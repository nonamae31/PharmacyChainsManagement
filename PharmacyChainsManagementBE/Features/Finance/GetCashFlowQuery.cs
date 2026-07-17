using MediatR;
using System;

namespace PharmacyChainsManagementBE.Features.Finance;

public class GetCashFlowQuery : IRequest<CashFlowDto>
{
    public DateOnly StartDate { get; set; }
    public DateOnly EndDate { get; set; }
    public Guid? BranchId { get; set; }
}
