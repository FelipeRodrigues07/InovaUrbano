using ApiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Requests;
using Newtonsoft.Json.Linq;
using System.IdentityModel.Tokens.Jwt;

namespace ApiUrbanPlanning.UseCase.Post
{
    public class CreatePostUseCase
    {
        private readonly InterfacePost _repositoryPost;
        private readonly InterfaceSuggestion _repositorySuggestion;

       
        public CreatePostUseCase(InterfacePost repositoryPost, InterfaceSuggestion repositorySuggestion)
        {
            _repositoryPost = repositoryPost;
            _repositorySuggestion = repositorySuggestion;
        }

        public async Task Execute(RequestCreatePost request, string imageUrl, string token)
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


            var existingSuggestion = await _repositorySuggestion.GetSuggestionByNumber(request.Number);
            if (existingSuggestion == null)
            {
                throw new InvalidOperationException($"No suggestion with the number {request.Number} exists.");
            }

            existingSuggestion.Status = request.Status;
            await _repositorySuggestion.UpdateSuggestion(existingSuggestion);

            var post = new Infrastructure.Models.Post
            {
                Title = request.Title, 
                Description = request.Description,
                UserId = userId,
                PostImageUrl = imageUrl, 
                NumberSuggestion = request.Number,
                SuggestionId = existingSuggestion.Id,
            };

            await _repositoryPost.CreatePost(post);



        }
    }
}
