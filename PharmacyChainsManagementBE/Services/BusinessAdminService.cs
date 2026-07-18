using System;
using System.Security.Cryptography;
using System.Threading;
using System.Threading.Tasks;
using PharmacyChainsManagementBE.Common;
using PharmacyChainsManagementBE.DTOs;
using PharmacyChainsManagementBE.DTOs.Responses;
using PharmacyChainsManagementBE.Models;
using PharmacyChainsManagementBE.Repositories;
using MediatR;

namespace PharmacyChainsManagementBE.Services;

public class BusinessAdminService : IBusinessAdminService
{
    private readonly IUserRepository _userRepository;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IPasswordHashingStrategy _passwordHashingStrategy;
    private readonly IEmailAlertQueue _emailAlertQueue;
    private readonly IAuditLogService _auditLogService;
    private readonly IPublisher _publisher;

    public BusinessAdminService(
        IUserRepository userRepository,
        IUnitOfWork unitOfWork,
        IPasswordHashingStrategy passwordHashingStrategy,
        IEmailAlertQueue emailAlertQueue,
        IAuditLogService auditLogService,
        IPublisher publisher)
    {
        _userRepository = userRepository;
        _unitOfWork = unitOfWork;
        _passwordHashingStrategy = passwordHashingStrategy;
        _emailAlertQueue = emailAlertQueue;
        _auditLogService = auditLogService;
        _publisher = publisher;
    }

    public async Task<ApiResponse<BusinessAdminDetailResponse>> GetBusinessAdminAsync(Guid accountId, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetBusinessAdminByIdAsync(accountId, cancellationToken);
        if (user == null)
        {
            return ApiResponse<BusinessAdminDetailResponse>.ErrorResponse("Business Admin không tồn tại.", 404);
        }

        var response = new BusinessAdminDetailResponse
        {
            UserId = user.UserId,
            FullName = user.FullName,
            Email = user.Email,
            Phone = user.Phone,
            Status = user.Status,
            CreatedAt = user.CreatedAt,
            ProfilePhotoUri = user.ProfilePhotoUri,
            Address = user.Address,
            DateOfBirth = user.DateOfBirth,
            Gender = user.Gender
        };

        return ApiResponse<BusinessAdminDetailResponse>.Ok(response);
    }

    public async Task<ApiResponse<System.Collections.Generic.List<BusinessAdminDetailResponse>>> GetBusinessAdminsAsync(CancellationToken cancellationToken = default)
    {
        var users = await _userRepository.GetUsersByRoleCodeAsync("BUSINESS_ADMIN", cancellationToken);
        var response = users.Select(user => new BusinessAdminDetailResponse
        {
            UserId = user.UserId,
            FullName = user.FullName,
            Email = user.Email,
            Phone = user.Phone,
            Status = user.Status,
            CreatedAt = user.CreatedAt,
            ProfilePhotoUri = user.ProfilePhotoUri,
            Address = user.Address,
            DateOfBirth = user.DateOfBirth,
            Gender = user.Gender
        }).ToList();

        return ApiResponse<System.Collections.Generic.List<BusinessAdminDetailResponse>>.Ok(response);
    }

    public async Task<ApiResponse<BusinessAdminDetailResponse>> CreateBusinessAdminAsync(CreateBusinessAdminRequest request, string? ipAddress, CancellationToken cancellationToken = default)
    {
        var existingUser = await _userRepository.FindByEmailAsync(request.Email, cancellationToken);
        if (existingUser != null)
        {
            return ApiResponse<BusinessAdminDetailResponse>.ErrorResponse("Email đã tồn tại trong hệ thống.", 409);
        }

        var existingPhoneUser = await _userRepository.FindByPhoneAsync(request.Phone, cancellationToken);
        if (existingPhoneUser != null)
        {
            return ApiResponse<BusinessAdminDetailResponse>.ErrorResponse("Số điện thoại đã tồn tại trong hệ thống.", 409);
        }

        var adminRole = await _userRepository.GetRoleByCodeAsync("BUSINESS_ADMIN", cancellationToken);
        if (adminRole == null)
        {
            return ApiResponse<BusinessAdminDetailResponse>.ErrorResponse("BUSINESS_ADMIN role not found.");
        }

        string rawPassword = GenerateSecurePassword();
        string hashedPassword = _passwordHashingStrategy.HashPassword(rawPassword);

        var newUser = new User
        {
            UserId = Guid.NewGuid(),
            FullName = request.FullName,
            Email = request.Email,
            Phone = request.Phone,
            PasswordHash = hashedPassword,
            RoleId = adminRole.RoleId,
            Status = "ACTIVE",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            MustChangePassword = true
        };

        await _userRepository.AddAsync(newUser, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _emailAlertQueue.EnqueueEmailAsync(new EmailMessage(
            request.Email,
            "Account Created",
            $"Password: {rawPassword}"
        ), cancellationToken);

        await _auditLogService.LogAsync("CreateBusinessAdmin", $"Created admin {request.Email}", newUser.UserId.ToString(), ipAddress, cancellationToken);

        var response = new BusinessAdminDetailResponse
        {
            UserId = newUser.UserId,
            FullName = newUser.FullName,
            Email = newUser.Email,
            Phone = newUser.Phone,
            Status = newUser.Status,
            CreatedAt = newUser.CreatedAt,
            ProfilePhotoUri = newUser.ProfilePhotoUri,
            Address = newUser.Address,
            DateOfBirth = newUser.DateOfBirth,
            Gender = newUser.Gender
        };

        return ApiResponse<BusinessAdminDetailResponse>.Ok(response);
    }

    public async Task<ApiResponse<object>> VerifyAndDeactivateAsync(Guid adminId, string reason, string? ipAddress, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetBusinessAdminByIdAsync(adminId, cancellationToken);
        if (user == null)
        {
            return ApiResponse<object>.ErrorResponse("Business Admin không tồn tại.", 404);
        }

        if (user.Status != "ACTIVE")
        {
            return ApiResponse<object>.ErrorResponse("Tài khoản đã bị vô hiệu hóa hoặc không ở trạng thái ACTIVE.", 400);
        }

        user.Status = "DEACTIVATED";
        user.UpdatedAt = DateTime.UtcNow;

        await _userRepository.UpdateAsync(user, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _auditLogService.LogAsync("DeactivateBusinessAdmin", $"Deactivated admin {adminId}. Reason: {reason}", user.UserId.ToString(), ipAddress, cancellationToken);

        await _publisher.Publish(new Events.BusinessAdminDeactivated(adminId, reason, DateTime.UtcNow), cancellationToken);

        return ApiResponse<object>.Ok(new { Message = "Đã vô hiệu hóa tài khoản Business Admin thành công." });
    }

    public async Task<ApiResponse<object>> GetBusinessAdminStatusAsync(Guid adminId, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetBusinessAdminByIdAsync(adminId, cancellationToken);
        if (user == null)
        {
            return ApiResponse<object>.ErrorResponse("Business Admin không tồn tại.", 404);
        }

        return ApiResponse<object>.Ok(new { AdminId = user.UserId, Status = user.Status });
    }

    public async Task<ApiResponse<BusinessAdminDetailResponse>> UpdateBusinessAdminAsync(Guid accountId, UpdateBusinessAdminRequest request, Guid currentUserId, string? currentUserRole, string? ipAddress, CancellationToken cancellationToken = default)
    {
        if (currentUserRole != "Founder" && currentUserRole != "SUPER_ADMIN" && currentUserId != accountId)
        {
            return ApiResponse<BusinessAdminDetailResponse>.ErrorResponse("Quyền truy cập bị từ chối.", 403);
        }

        var user = await _userRepository.GetBusinessAdminByIdAsync(accountId, cancellationToken);
        if (user == null)
        {
            return ApiResponse<BusinessAdminDetailResponse>.ErrorResponse("Business Admin không tồn tại.", 404);
        }

        string oldEmail = user.Email;
        string oldPhone = user.Phone;

        if (!string.Equals(oldEmail, request.Email, StringComparison.OrdinalIgnoreCase))
        {
            var existingUser = await _userRepository.FindByEmailAsync(request.Email, cancellationToken);
            if (existingUser != null && existingUser.UserId != accountId)
            {
                return ApiResponse<BusinessAdminDetailResponse>.ErrorResponse("Email đã tồn tại trong hệ thống.", 409);
            }
        }

        if (oldPhone != request.Phone)
        {
            var existingPhoneUser = await _userRepository.FindByPhoneAsync(request.Phone, cancellationToken);
            if (existingPhoneUser != null && existingPhoneUser.UserId != accountId)
            {
                return ApiResponse<BusinessAdminDetailResponse>.ErrorResponse("Số điện thoại đã tồn tại trong hệ thống.", 409);
            }
        }

        user.FullName = request.FullName;
        user.Email = request.Email;
        user.Phone = request.Phone;
        user.UpdatedAt = DateTime.UtcNow;

        try
        {
            await _userRepository.UpdateAsync(user, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);
        }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex)
        {
            if (ex.InnerException != null && (ex.InnerException.Message.Contains("duplicate", StringComparison.OrdinalIgnoreCase) || ex.InnerException.Message.Contains("unique", StringComparison.OrdinalIgnoreCase)))
            {
                return ApiResponse<BusinessAdminDetailResponse>.ErrorResponse("Email hoặc Số điện thoại đã tồn tại trong hệ thống.", 409);
            }
            throw;
        }

        if (oldEmail != user.Email || oldPhone != user.Phone)
        {
            await _auditLogService.LogAsync("UpdateBusinessAdminProfile", $"Updated profile for admin {accountId}. Email changed: {oldEmail != user.Email}, Phone changed: {oldPhone != user.Phone}", user.UserId.ToString(), ipAddress, cancellationToken);
        }

        var response = new BusinessAdminDetailResponse
        {
            UserId = user.UserId,
            FullName = user.FullName,
            Email = user.Email,
            Phone = user.Phone,
            Status = user.Status,
            CreatedAt = user.CreatedAt,
            ProfilePhotoUri = user.ProfilePhotoUri,
            Address = user.Address,
            DateOfBirth = user.DateOfBirth,
            Gender = user.Gender
        };

        return ApiResponse<BusinessAdminDetailResponse>.Ok(response);
    }

    private string GenerateSecurePassword(int length = 12)
    {
        const string validChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*";
        var result = new char[length];
        using (var rng = RandomNumberGenerator.Create())
        {
            var buffer = new byte[length];
            rng.GetBytes(buffer);
            for (int i = 0; i < length; i++)
            {
                result[i] = validChars[buffer[i] % validChars.Length];
            }
        }
        return new string(result);
    }
}
