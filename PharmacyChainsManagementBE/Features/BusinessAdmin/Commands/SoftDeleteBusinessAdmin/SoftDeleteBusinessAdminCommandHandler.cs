using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.Repositories;
using PharmacyChainsManagementBE.Events;

namespace PharmacyChainsManagementBE.Features.BusinessAdmin.Commands.SoftDeleteBusinessAdmin;

public class SoftDeleteBusinessAdminCommandHandler : IRequestHandler<SoftDeleteBusinessAdminCommand, ApiResponse<object>>
{
    private readonly IUserRepository _userRepository;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IPublisher _publisher;

    public SoftDeleteBusinessAdminCommandHandler(IUserRepository userRepository, IUnitOfWork unitOfWork, IPublisher publisher)
    {
        _userRepository = userRepository;
        _unitOfWork = unitOfWork;
        _publisher = publisher;
    }

    public async Task<ApiResponse<object>> Handle(SoftDeleteBusinessAdminCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetBusinessAdminByIdAsync(request.AdminId, cancellationToken);
        if (user == null)
        {
            return ApiResponse<object>.ErrorResponse("Business Admin không tồn tại.", 404);
        }

        _userRepository.Remove(user);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _publisher.Publish(new AuditLogEvent(
            "SoftDeleteBusinessAdmin", 
            $"Soft deleted admin {request.AdminId}", 
            request.AdminId.ToString(), 
            request.IpAddress), cancellationToken);

        return ApiResponse<object>.Ok(new { Message = "Đã xóa mềm tài khoản Business Admin thành công." });
    }
}
