using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Serilog.Context;

namespace PharmacyChainsManagementBE.Middlewares;

public class CorrelationIdMiddleware
{
    private readonly RequestDelegate _next;
    private const string CorrelationIdHeader = "X-Correlation-ID";

    public CorrelationIdMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = context.Request.Headers[CorrelationIdHeader].ToString();
        
        if (string.IsNullOrEmpty(correlationId))
        {
            correlationId = Guid.NewGuid().ToString();
            context.Request.Headers.TryAdd(CorrelationIdHeader, correlationId);
        }

        context.Response.OnStarting(() =>
        {
            context.Response.Headers.TryAdd(CorrelationIdHeader, correlationId);
            return Task.CompletedTask;
        });

        using (LogContext.PushProperty("CorrelationId", correlationId))
        {
            await _next(context);
        }
    }
}
