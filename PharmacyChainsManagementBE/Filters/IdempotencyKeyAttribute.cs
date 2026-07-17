using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.DependencyInjection;
using PharmacyChainsManagementBE.Common;

namespace PharmacyChainsManagementBE.Filters;

[AttributeUsage(AttributeTargets.Method)]
public class IdempotencyKeyAttribute : Attribute, IAsyncActionFilter
{
    private const string HeaderName = "Idempotency-Key";

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        if (!context.HttpContext.Request.Headers.TryGetValue(HeaderName, out var keyValues))
        {
            var response = ApiResponse<object>.ErrorResponse("Missing Idempotency-Key header", StatusCodes.Status400BadRequest);
            context.Result = new BadRequestObjectResult(response);
            return;
        }

        var key = keyValues.ToString();
        var cache = context.HttpContext.RequestServices.GetRequiredService<IMemoryCache>();
        var cacheKey = $"Idempotency_{key}";

        if (cache.TryGetValue(cacheKey, out _))
        {
            var response = ApiResponse<object>.ErrorResponse("Idempotency-Key has already been processed.", StatusCodes.Status409Conflict);
            context.Result = new ConflictObjectResult(response);
            return;
        }

        var executedContext = await next();

        if (executedContext.Exception == null && executedContext.Result is ObjectResult)
        {
            var cacheOptions = new MemoryCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromHours(24)
            };
            cache.Set(cacheKey, true, cacheOptions);
        }
    }
}
