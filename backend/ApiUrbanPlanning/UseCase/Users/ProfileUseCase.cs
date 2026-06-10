using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Response;
using System.IdentityModel.Tokens.Jwt;

namespace apiUrbanPlanning.UseCase.Users
{
    public class ProfileUseCase
    {
        private readonly InterfaceUser _repository;

       public ProfileUseCase(InterfaceUser repository)
       {
            _repository = repository;
       }


        public async Task<ProfileResponse> Execute(string token)
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

            return new ProfileResponse
            {
                Id = user.Id,
                Name = user.Name,
                Email = user.Email,
                ProfilePictureUrl = user.ProfilePictureUrl,
                Role = user.Role,
                MunicipalityId = user.MunicipalityId,
                IbgeId = user.Municipality?.IbgeId,
                MunicipalityName = user.Municipality?.Name,
                MunicipalityState = user.Municipality?.State,
            };

        }
    }
}
