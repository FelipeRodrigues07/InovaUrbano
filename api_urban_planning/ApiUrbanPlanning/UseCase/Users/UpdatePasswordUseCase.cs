using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Requests;
using Microsoft.AspNetCore.Identity;
using System.IdentityModel.Tokens.Jwt;

namespace ApiUrbanPlanning.UseCase.Users
{
    public class UpdatePasswordUseCase
    {
        private readonly InterfaceUser _repository;
        private readonly PasswordHasher<User> _passwordHasher;
        private readonly string _jwtSecret;

        public UpdatePasswordUseCase(InterfaceUser repository, IConfiguration configuration)
        {
            _repository = repository;
            _passwordHasher = new PasswordHasher<User>();
            _jwtSecret = configuration["JwtSettings:Secret"];

        }

        public async Task  Execute( string token, RequestPasswordUpdate request)
        {

            // Valida o token e decodifica para pegar o ID do usuário
            var tokenHandler = new JwtSecurityTokenHandler();
            var jwtToken = tokenHandler.ReadJwtToken(token);

            // Extrai o ID do usuário das claims do token
            var userIdClaim = jwtToken.Claims.FirstOrDefault(c => c.Type == "id");
            if (userIdClaim == null)
            {
                throw new UnauthorizedAccessException("ID de usuário não encontrado no token.");
            }

            // Converte o ID do usuário de string para Guid
            if (!Guid.TryParse(userIdClaim.Value, out var userId))
            {
                throw new FormatException("Formato de ID de usuário inválido.");
            }


            var user = await _repository.GetUserById(userId);
            if (user == null)
            {
                throw new KeyNotFoundException("Usuário não encontrado.");
            }

            var passwordVerificationResult = _passwordHasher.VerifyHashedPassword(
               user,
               user.Password, 
               request.OldPassword
           );

            if (passwordVerificationResult == PasswordVerificationResult.Failed)
            {
                throw new UnauthorizedAccessException("User credentials do not match.");
            }

            user.Password = _passwordHasher.HashPassword(user, request.NewPassword);
            await _repository.UpdateUser(user);

        }
    }
}
