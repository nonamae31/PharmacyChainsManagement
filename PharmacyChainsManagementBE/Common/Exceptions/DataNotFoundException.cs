using System;

namespace PharmacyChainsManagementBE.Common.Exceptions;

public class DataNotFoundException : Exception
{
    public DataNotFoundException(string message) : base(message)
    {
    }
}
