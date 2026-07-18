using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.Repositories;
using PharmacyChainsManagementBE.Events;
using Microsoft.EntityFrameworkCore;
using PharmacyChainsManagementBE.Models;

namespace PharmacyChainsManagementBE.Features.BusinessAdmin.Commands.ReactivateBusinessAdmin;

public class ReactivateBusinessAdminCommandHandler : IRequestHandler<ReactivateBusinessAdminCommand, ApiResponse<object>>
{
    private readonly PharmacyDbContext _context;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IPublisher _publisher;

    public ReactivateBusinessAdminCommandHandler(PharmacyDbContext context, IUnitOfWork unitOfWork, IPublisher publisher)
    {
        _context = context;
        _unitOfWork = unitOfWork;
        _publisher = publisher;
    }

    public async Task<ApiResponse<object>> Handle(ReactivateBusinessAdminCommand request, CancellationToken cancellationToken)
    {
        // Need to use IgnoreQueryFilters to find soft-deleted user
        var user = await _context.Users.IgnoreQueryFilters()
            .FirstOrDefaultAsync(u => u.UserId == request.AdminId, cancellationToken);

        if (user == null)
        {
            return ApiResponse<object>.ErrorResponse("Business Admin không tồn tại.", 404);
        }

        if (!user.IsDeleted && user.Status != "DEACTIVATED")
        {
            return ApiResponse<object>.ErrorResponse("Business Admin đang không bị xóa hoặc vô hiệu hóa.", 400);
        }

        user.IsDeleted = false;
        user.Status = "ACTIVE";
        
        _context.Users.Update(user);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _publisher.Publish(new AuditLogEvent(
            "ReactivateBusinessAdmin", 
            $"Reactivated admin {request.AdminId}", 
            request.AdminId.ToString(), 
            request.IpAddress), cancellationToken);

        return ApiResponse<object>.Ok(new { Message = "Đã kích hoạt lại tài khoản Business Admin thành công." });
    }
}
