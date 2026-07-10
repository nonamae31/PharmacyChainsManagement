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
using PharmacyChainsManagementBE.Validators;

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

    builder.Services.AddDbContext<PharmacyDbContext>(options =>
        options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

    var jwtSettingsSection = builder.Configuration.GetSection("JwtSettings");
    builder.Services.Configure<JwtSettings>(jwtSettingsSection);
    var jwtSettings = jwtSettingsSection.Get<JwtSettings>();

    if (jwtSettings == null || string.IsNullOrWhiteSpace(jwtSettings.SecretKey))
    {
        throw new InvalidOperationException("JWT settings are not configured properly.");
    }

    builder.Services.Configure<FounderSettings>(builder.Configuration.GetSection(FounderSettings.SectionName));
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
    });

    builder.Services.AddCors(options =>
    {
        options.AddPolicy("Production", policy =>
            policy.WithOrigins("https://yourtrusteddomain.com") 
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials());
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
    });

    builder.Services.AddScoped<IUserRepository, UserRepository>();
    builder.Services.AddScoped<ISessionRepository, SessionRepository>();
    builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
    builder.Services.AddScoped<IAuthService, AuthService>();
    builder.Services.AddScoped<ITokenService, TokenService>();
    builder.Services.AddSingleton<IPasswordHashingStrategy, BCryptPasswordHashingStrategy>();
    builder.Services.AddTransient<IEmailService, EmailService>();
    
    builder.Services.AddScoped<IAuditLogService, AuditLogService>();
    builder.Services.AddSingleton<IEmailAlertQueue, EmailAlertQueue>();
    builder.Services.AddHostedService<SuspiciousLoginAlertBackgroundService>();

    var app = builder.Build();

    app.UseMiddleware<GlobalExceptionMiddleware>();
    app.UseMiddleware<CorrelationIdMiddleware>();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    app.UseHttpsRedirection();
    
    app.UseRateLimiter();
    app.UseCors("Production");

    app.UseRouting();

    app.UseAuthentication();
    app.UseMiddleware<JwtBlacklistMiddleware>();
    app.UseAuthorization();

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
