using BCrypt.Net;

namespace PharmacyChainsManagementBE.Services;

public class BCryptPasswordHashingStrategy : IPasswordHashingStrategy
{
    public string HashPassword(string password)
    {
        // Work factor 11 as specified in draft T-001
        return BCrypt.Net.BCrypt.HashPassword(password, workFactor: 11);
    }

    public bool VerifyPassword(string password, string hashedPassword)
    {
        try
        {
            return BCrypt.Net.BCrypt.Verify(password, hashedPassword);
        }
        catch
        {
            return false;
        }
    }

    public string Hash(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    public bool Verify(string password, string hashedPassword)
    {
        return VerifyPassword(password, hashedPassword);
    }
}
