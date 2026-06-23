using ApiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Requests;
using System.IdentityModel.Tokens.Jwt;
using OfficialResponseModel = ApiUrbanPlanning.Infrastructure.Models.OfficialResponse;

namespace ApiUrbanPlanning.UseCase.OfficialResponse
{
    public class CreateOfficialResponseUseCase
    {
        private readonly InterfaceOfficialResponse _repositoryOfficialResponse;
        private readonly InterfaceSuggestion _repositorySuggestion;

        public CreateOfficialResponseUseCase(
            InterfaceOfficialResponse repositoryOfficialResponse,
            InterfaceSuggestion repositorySuggestion)
        {
            _repositoryOfficialResponse = repositoryOfficialResponse;
            _repositorySuggestion = repositorySuggestion;
        }

        public async Task Execute(RequestCreateOfficialResponse request, string imageUrl, string token)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var jwtToken = tokenHandler.ReadJwtToken(token);

            var userIdClaim = jwtToken.Claims.FirstOrDefault(c => c.Type == "id");
            if (userIdClaim == null)
            {
                throw new UnauthorizedAccessException("ID de usuário não encontrado no token.");
            }

            if (!Guid.TryParse(userIdClaim.Value, out var userId))
            {
                throw new FormatException("Formato de ID de usuário inválido.");
            }

            var existingSuggestion = await _repositorySuggestion.GetSuggestionByNumber(request.Number);
            if (existingSuggestion == null)
            {
                throw new InvalidOperationException($"No suggestion with the number {request.Number} exists.");
            }

            existingSuggestion.Status = request.Status;
            await _repositorySuggestion.UpdateSuggestion(existingSuggestion);

            var officialResponse = new OfficialResponseModel
            {
                Title = request.Title,
                Description = request.Description,
                UserId = userId,
                PostImageUrl = imageUrl,
                NumberSuggestion = request.Number,
                SuggestionId = existingSuggestion.Id,
            };

            await _repositoryOfficialResponse.CreateOfficialResponse(officialResponse);
        }
    }
}
