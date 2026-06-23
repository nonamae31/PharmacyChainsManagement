using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using PharmacyChainsManagementBE.Common;
using System;
using System.Collections.Generic;

namespace PharmacyChainsManagementBE.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
public class BaseApiController : ControllerBase
{
    protected ActionResult ToProblemDetails(Result result)
    {
        if (result.IsSuccess)
        {
            return Problem(
                statusCode: StatusCodes.Status500InternalServerError,
                title: "Internal Server Error",
                type: "https://tools.ietf.org/html/rfc7231#section-6.6.1",
                detail: "Cannot convert a successful result to a ProblemDetails response."
            );
        }

        var error = result.Error;

        var statusCode = error.Type switch
        {
            ErrorType.Validation => StatusCodes.Status400BadRequest,
            ErrorType.NotFound => StatusCodes.Status404NotFound,
            ErrorType.Unauthorized => StatusCodes.Status401Unauthorized,
            ErrorType.Forbidden => StatusCodes.Status403Forbidden,
            ErrorType.Conflict => StatusCodes.Status409Conflict,
            _ => StatusCodes.Status500InternalServerError
        };

        var problemDetails = new ProblemDetails
        {
            Status = statusCode,
            Title = GetTitleForErrorType(error.Type),
            Type = GetTypeForErrorType(error.Type),
            Detail = error.Message
        };

        problemDetails.Extensions.Add("errors", new[] { new { code = error.Code, message = error.Message } });

        return new ObjectResult(problemDetails)
        {
            StatusCode = statusCode
        };
    }

    private static string GetTitleForErrorType(ErrorType type) =>
        type switch
        {
            ErrorType.Validation => "Bad Request",
            ErrorType.NotFound => "Not Found",
            ErrorType.Unauthorized => "Unauthorized",
            ErrorType.Forbidden => "Forbidden",
            ErrorType.Conflict => "Conflict",
            _ => "Internal Server Error"
        };

    private static string GetTypeForErrorType(ErrorType type) =>
        type switch
        {
            ErrorType.Validation => "https://tools.ietf.org/html/rfc7231#section-6.5.1",
            ErrorType.NotFound => "https://tools.ietf.org/html/rfc7231#section-6.5.4",
            ErrorType.Unauthorized => "https://tools.ietf.org/html/rfc7235#section-3.1",
            ErrorType.Forbidden => "https://tools.ietf.org/html/rfc7231#section-6.5.3",
            ErrorType.Conflict => "https://tools.ietf.org/html/rfc7231#section-6.5.8",
            _ => "https://tools.ietf.org/html/rfc7231#section-6.6.1"
        };
}
