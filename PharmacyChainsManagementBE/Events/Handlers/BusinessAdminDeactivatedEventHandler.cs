using System;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using Microsoft.Extensions.Logging;
using PharmacyChainsManagementBE.Repositories;
using PharmacyChainsManagementBE.Services;

namespace PharmacyChainsManagementBE.Events.Handlers;

public class BusinessAdminDeactivatedEventHandler : INotificationHandler<BusinessAdminDeactivated>
{
    private readonly ILogger<BusinessAdminDeactivatedEventHandler> _logger;
    private readonly IEmailService _emailService;
    private readonly IUserRepository _userRepository;

    public BusinessAdminDeactivatedEventHandler(
        ILogger<BusinessAdminDeactivatedEventHandler> logger, 
        IEmailService emailService, 
        IUserRepository userRepository)
    {
        _logger = logger;
        _emailService = emailService;
        _userRepository = userRepository;
    }

    public async Task Handle(BusinessAdminDeactivated notification, CancellationToken cancellationToken)
    {
        try
        {
            var user = await _userRepository.GetBusinessAdminByIdAsync(notification.AdminId, cancellationToken);
            if (user == null)
            {
                _logger.LogWarning("Admin {AdminId} not found when trying to send deactivation email.", notification.AdminId);
                return;
            }

            var subject = "Thông báo: Tài khoản của bạn đã bị vô hiệu hóa";
            var body = $@"Xin chào {user.FullName},

Tài khoản Business Admin của bạn trên hệ thống Pharmacy Chains Management đã bị vô hiệu hóa vào lúc {notification.DeactivatedAt:dd/MM/yyyy HH:mm:ss} (UTC).

Lý do: {notification.Reason}

Nếu bạn cho rằng có sự nhầm lẫn, vui lòng liên hệ với Founder để được hỗ trợ.

Trân trọng,
Hệ thống Pharmacy Chains Management";

            await _emailService.SendEmailAsync(user.Email, subject, body, cancellationToken);
            _logger.LogInformation("Sent deactivation email to {Email}", user.Email);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send deactivation email for Admin {AdminId}", notification.AdminId);
        }
    }
}
