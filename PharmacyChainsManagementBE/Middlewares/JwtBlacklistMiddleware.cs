using System;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Net.Mime;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;

namespace PharmacyChainsManagementBE.Middlewares;

public class JwtBlacklistMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IMemoryCache _memoryCache;
    private readonly ILogger<JwtBlacklistMiddleware> _logger;

    public JwtBlacklistMiddleware(
        RequestDelegate next,
        IMemoryCache memoryCache,
        ILogger<JwtBlacklistMiddleware> logger)
    {
        _next = next;
        _memoryCache = memoryCache;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var jti = context.User.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Jti || c.Type == "jti")?.Value;

            if (!string.IsNullOrEmpty(jti) && _memoryCache.TryGetValue($"blacklist:{jti}", out _))
            {
                _logger.LogWarning("Access blocked: token is blacklisted (JTI: {Jti})", jti);

                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                context.Response.ContentType = MediaTypeNames.Application.Json;

                var problemDetails = new ProblemDetails
                {
                    Status = StatusCodes.Status401Unauthorized,
                    Title = "Unauthorized",
                    Type = "https://tools.ietf.org/html/rfc7235#section-3.1",
                    Detail = "The token has been invalidated.",
                    Instance = context.Request.Path
                };

                problemDetails.Extensions.Add("errors", new[]
                {
                    new { code = "AUTH_TOKEN_BLACKLISTED", message = "The token has been invalidated." }
                });

                await context.Response.WriteAsync(JsonSerializer.Serialize(problemDetails));
                return;
            }
        }

        await _next(context);
    }
}
