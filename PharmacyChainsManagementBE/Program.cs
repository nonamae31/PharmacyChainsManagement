using System;
using System.Text;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;
using FluentValidation;
using FluentValidation.AspNetCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using Serilog;
using PharmacyChainsManagementBE.Middlewares;
using PharmacyChainsManagementBE.Models;
using PharmacyChainsManagementBE.Repositories;
using PharmacyChainsManagementBE.Services;
using PharmacyChainsManagementBE.Services.Strategies;
using PharmacyChainsManagementBE.Validators;
using PharmacyChainsManagementBE.Security;
using Microsoft.AspNetCore.Authorization;
using PharmacyChainsManagementBE.Common.Settings;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try 
{
    var builder = WebApplication.CreateBuilder(args);

    builder.Host.UseSerilog((context, services, configuration) => configuration
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.Console());

    builder.Services.AddControllers();

    builder.Services.AddFluentValidationAutoValidation();
    builder.Services.AddValidatorsFromAssemblyContaining<LoginRequestValidator>();

    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();

    builder.Services.AddSingleton<PharmacyChainsManagementBE.Common.Interceptors.SoftDeleteInterceptor>();
    builder.Services.AddDbContext<PharmacyDbContext>((sp, options) =>
        options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"), b => b.CommandTimeout(120))
               .AddInterceptors(sp.GetRequiredService<PharmacyChainsManagementBE.Common.Interceptors.SoftDeleteInterceptor>()));

    var jwtSettingsSection = builder.Configuration.GetSection("JwtSettings");
    builder.Services.Configure<JwtSettings>(jwtSettingsSection);
    var jwtSettings = jwtSettingsSection.Get<JwtSettings>();

    if (jwtSettings == null || string.IsNullOrWhiteSpace(jwtSettings.SecretKey))
    {
        throw new InvalidOperationException("JWT settings are not configured properly.");
    }

    builder.Services.Configure<FounderSettings>(builder.Configuration.GetSection(FounderSettings.SectionName));
    builder.Services.Configure<CloudinarySettings>(builder.Configuration.GetSection("CloudinarySettings"));
    builder.Services.AddMemoryCache();

    builder.Services.AddRateLimiter(options =>
    {
        options.AddFixedWindowLimiter("LoginPolicy", o =>
        {
            o.PermitLimit = 5;
            o.Window = TimeSpan.FromMinutes(1);
            o.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            o.QueueLimit = 2;
        });

        options.AddFixedWindowLimiter("GetAdminPolicy", o =>
        {
            o.PermitLimit = 10;
            o.Window = TimeSpan.FromMinutes(1);
            o.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            o.QueueLimit = 2;
        });

        options.AddFixedWindowLimiter("CreateAdminPolicy", o =>
        {
            o.PermitLimit = 5;
            o.Window = TimeSpan.FromMinutes(1);
            o.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            o.QueueLimit = 2;
        });

        options.AddFixedWindowLimiter("CashFlowReportPolicy", o =>
        {
            o.PermitLimit = 5;
            o.Window = TimeSpan.FromMinutes(1);
            o.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            o.QueueLimit = 2;
        });

        options.AddFixedWindowLimiter("export_policy", o =>
        {
            o.PermitLimit = 5;
            o.Window = TimeSpan.FromMinutes(1);
            o.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            o.QueueLimit = 2;
        });

        options.AddFixedWindowLimiter("ProfileUpdatePolicy", o =>
        {
            o.PermitLimit = 10;
            o.Window = TimeSpan.FromMinutes(1);
            o.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
            o.QueueLimit = 2;
        });
    });

    builder.Services.AddCors(options =>
    {
        options.AddDefaultPolicy(policy =>
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader());
    });

    builder.Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSettings.Issuer,
            ValidAudience = jwtSettings.Audience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings.SecretKey)),
            ClockSkew = TimeSpan.Zero
        };
        options.Events = new JwtBearerEvents
        {
            OnTokenValidated = context =>
            {
                if (context.Principal?.Identity is System.Security.Claims.ClaimsIdentity identity)
                {
                    var claims = new System.Collections.Generic.List<System.Security.Claims.Claim>(identity.FindAll(identity.RoleClaimType));
                    foreach (var claim in claims)
                    {
                        if (string.IsNullOrEmpty(claim.Value)) continue;
                        var normalizedRole = char.ToUpper(claim.Value[0]) + claim.Value.Substring(1).ToLower();
                        if (claim.Value != normalizedRole)
                        {
                            identity.RemoveClaim(claim);
                            identity.AddClaim(new System.Security.Claims.Claim(identity.RoleClaimType, normalizedRole));
                        }
                    }
                }
                return Task.CompletedTask;
            }
        };
    });

    builder.Services.AddScoped<IUserRepository, UserRepository>();
    builder.Services.AddScoped<ISessionRepository, SessionRepository>();
    builder.Services.AddScoped<ITransactionRepository, TransactionRepository>();
    builder.Services.AddScoped<IAuditLogRepository, AuditLogRepository>();
    builder.Services.AddScoped<IInvoiceRepository, InvoiceRepository>();
    builder.Services.AddScoped<IReportRepository, ReportRepository>();
    builder.Services.AddScoped<IRevenueReportService, RevenueReportService>();
    builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
    builder.Services.AddScoped<IAuthService, AuthService>();
    builder.Services.AddScoped<ITokenService, TokenService>();
    builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
    builder.Services.AddScoped<IUserService, UserService>();
    builder.Services.AddScoped<ICloudinaryService, CloudinaryService>();
    builder.Services.AddSingleton<IPasswordHashingStrategy, BCryptPasswordHashingStrategy>();
    builder.Services.AddTransient<IEmailService, EmailService>();
    
    builder.Services.AddScoped<IAuditLogService, AuditLogService>();
    builder.Services.AddSingleton<IEmailAlertQueue, EmailAlertQueue>();
    builder.Services.AddHostedService<SuspiciousLoginAlertBackgroundService>();

    builder.Services.AddScoped<IBusinessAdminService, BusinessAdminService>();
    builder.Services.AddScoped<IFinancialReportService, FinancialReportService>();
    builder.Services.AddScoped<IExportFormatStrategy<PharmacyChainsManagementBE.DTOs.Finance.ReportPayloadDTO>, PdfExportStrategy>();
    builder.Services.AddScoped<IExportFormatStrategy<PharmacyChainsManagementBE.DTOs.Finance.ReportPayloadDTO>, ExcelExportStrategy>();
    builder.Services.AddScoped<IExportFormatStrategy<PharmacyChainsManagementBE.DTOs.Finance.ReportPayloadDTO>, CsvExportStrategy>();

    builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(Program).Assembly));
    builder.Services.AddHttpContextAccessor();
    builder.Services.AddSingleton<IAuthorizationHandler, AdminOrOwnerHandler>();
    builder.Services.AddAuthorization(options =>
    {
        options.AddPolicy("RequireSuperAdminOrOwner", policy =>
            policy.Requirements.Add(new AdminOrOwnerRequirement()));
    });

    var app = builder.Build();

    app.UseMiddleware<GlobalExceptionMiddleware>();
    app.UseMiddleware<CorrelationIdMiddleware>();

    app.UseHttpsRedirection();
    
    app.UseRouting();
    app.UseCors();

    app.UseRateLimiter(); // UseRateLimiter must be placed AFTER UseRouting to work with endpoint specific policies

    app.UseAuthentication();
    app.UseMiddleware<JwtBlacklistMiddleware>();
    app.UseAuthorization();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    app.MapControllers();

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Host terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
