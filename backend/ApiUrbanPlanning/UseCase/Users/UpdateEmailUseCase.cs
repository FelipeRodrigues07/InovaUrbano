using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Requests;
using Microsoft.AspNetCore.Identity;
using System.IdentityModel.Tokens.Jwt;


namespace ApiUrbanPlanning.UseCase.Users
{
    public class UpdateEmailUseCase
    {
        private readonly InterfaceUser _repository;
        private readonly string _jwtSecret;

        public UpdateEmailUseCase(InterfaceUser repository, IConfiguration configuration)
        {
            _repository = repository;
            _jwtSecret = configuration["JwtSettings:Secret"];
        }

        public async Task Execute(string token, RequestEmailUpdate request)
        {
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
                throw new BadHttpRequestException("Usuário não encontrado.");
            }

            var existingUser = await _repository.GetUserByEmail(request.NewEmail);
            if (existingUser != null)
            {
                throw new BadHttpRequestException("Este email já está em uso.");
            }

            user.Email = request.NewEmail;
            await _repository.UpdateUser(user);
        }
    }
}
