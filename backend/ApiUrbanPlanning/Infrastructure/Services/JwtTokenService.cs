using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using apiUrbanPlanning.Infrastructure.Models;
using Microsoft.IdentityModel.Tokens;

namespace apiUrbanPlanning.Infrastructure.Services
{
    public class JwtTokenService
    {
        private const string RefreshTokenType = "refresh";

        private readonly string _secret;
        private readonly int _accessTokenMinutes;
        private readonly int _refreshTokenDays;

        public JwtTokenService(IConfiguration configuration)
        {
            _secret = configuration["JwtSettings:Secret"]
                ?? throw new InvalidOperationException("JwtSettings:Secret is required.");
            _accessTokenMinutes = configuration.GetValue("JwtSettings:AccessTokenMinutes", 60);
            _refreshTokenDays = configuration.GetValue("JwtSettings:RefreshTokenDays", 30);
        }

        public int AccessTokenLifetimeSeconds => _accessTokenMinutes * 60;

        public DateTime RefreshTokenExpiresAt =>
            DateTime.UtcNow.AddDays(_refreshTokenDays);

        public static string HashToken(string plainToken) =>
            Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(plainToken)));

        public string GenerateAccessToken(User user) =>
            WriteToken(user, DateTime.UtcNow.AddMinutes(_accessTokenMinutes), null);

        public string GenerateRefreshToken(User user) =>
            WriteToken(user, DateTime.UtcNow.AddDays(_refreshTokenDays), RefreshTokenType);

        public Guid? ValidateRefreshToken(string token)
        {
            if (string.IsNullOrWhiteSpace(token))
            {
                return null;
            }

            try
            {
                var handler = new JwtSecurityTokenHandler();
                var key = Encoding.UTF8.GetBytes(_secret);

                var principal = handler.ValidateToken(
                    token,
                    new TokenValidationParameters
                    {
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(key),
                        ValidateIssuer = false,
                        ValidateAudience = false,
                        ValidateLifetime = true,
                        ClockSkew = TimeSpan.FromMinutes(1),
                    },
                    out _);

                if (principal.FindFirst("token_type")?.Value != RefreshTokenType)
                {
                    return null;
                }

                var idClaim = principal.FindFirst("id")?.Value;
                return Guid.TryParse(idClaim, out var userId) ? userId : null;
            }
            catch
            {
                return null;
            }
        }

        private string WriteToken(User user, DateTime expires, string? tokenType)
        {
            var claims = new List<Claim>
            {
                new("id", user.Id.ToString()),
                new("email", user.Email),
                new("role", user.Role),
            };

            if (tokenType != null)
            {
                claims.Add(new Claim("token_type", tokenType));
            }

            var handler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(_secret);

            var descriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = expires,
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(key),
                    SecurityAlgorithms.HmacSha256Signature),
            };

            return handler.WriteToken(handler.CreateToken(descriptor));
        }
    }
}
