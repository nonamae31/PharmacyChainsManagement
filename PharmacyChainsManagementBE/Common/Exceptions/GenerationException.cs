using System;

namespace PharmacyChainsManagementBE.Common.Exceptions;

public class GenerationException : Exception
{
    public GenerationException(string message, Exception? innerException = null) : base(message, innerException)
    {
    }
}
