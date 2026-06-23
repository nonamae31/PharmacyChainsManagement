namespace PharmacyChainsManagementBE.Services;

public interface IPasswordHashingStrategy
{
    string HashPassword(string password);
    bool VerifyPassword(string password, string hashedPassword);
    string Hash(string password);
    bool Verify(string password, string hashedPassword);
}
