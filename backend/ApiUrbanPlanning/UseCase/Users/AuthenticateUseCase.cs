using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Requests;
using apiUrbanPlanning.Response;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens; //contém classes relacionadas à criação e manipulação de tokens de segurança, como o JWT.
using System.IdentityModel.Tokens.Jwt; //Este namespace contém classes específicas para criação, validação e manipulação de tokens JWT.
using System.Security.Claims;
using System.Text; // convertrer de strings para bytes

namespace apiUrbanPlanning.UseCase.Users
{
    public class AuthenticateUseCase
    {

        private readonly InterfaceUser _repository;
        private readonly PasswordHasher<User> _passwordHasher;
        private readonly string _jwtSecret;

        public AuthenticateUseCase(InterfaceUser repository, IConfiguration configuration)
        {
            _repository = repository;
            _passwordHasher = new PasswordHasher<User>();
            _jwtSecret = configuration["JwtSettings:Secret"];
        }

        public async Task<AuthenticateUserResponse> Execute(RequestAuthenticate request)
        {
            var existingUser = await _repository.GetUserByEmail(request.Email);

            if (existingUser == null)
            {
                throw new InvalidOperationException("Email does not exist.");
            }

            var passwordVerificationResult = _passwordHasher.VerifyHashedPassword(
                existingUser,
                existingUser.Password, // Hash da senha armazenada
                request.Password // Senha fornecida
            );

            if (passwordVerificationResult == PasswordVerificationResult.Failed)
            {
                throw new UnauthorizedAccessException("User credentials do not match.");
            }

            var token = GenerateJwtToken(existingUser);

            return new AuthenticateUserResponse
            {
                Id = existingUser.Id,
                Name = existingUser.Name,
                Email = existingUser.Email,
                Token = token

            };
        }

        private string GenerateJwtToken(User user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_jwtSecret);

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim("id", user.Id.ToString()),
                    new Claim("email", user.Email),
                    new Claim("role", user.Role)
                }),
                Expires = DateTime.UtcNow.AddDays(7), // O token expira em 7 dias
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }




    }
}

