using System;
using System.Security.Cryptography;
using System.Text;

namespace PotatoCornerSys
{
    public static class PasswordHelper
    {
        public static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString(); // 64-char hex string
            }
        }

        public static bool VerifyPassword(string enteredPassword, string storedHash)
        {
            string enteredHash = HashPassword(enteredPassword);
            return string.Equals(enteredHash, storedHash, StringComparison.OrdinalIgnoreCase);
        }
    }
}