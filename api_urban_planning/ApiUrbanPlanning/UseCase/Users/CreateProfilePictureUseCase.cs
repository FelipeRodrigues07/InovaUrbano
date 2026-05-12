using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Infrastructure.Services;
using Newtonsoft.Json.Linq;
using System.IdentityModel.Tokens.Jwt;

namespace apiUrbanPlanning.UseCase.Users
{
    public class CreateProfilePictureUseCase
    {
        private readonly CloudinaryService _cloudinaryService;
        private readonly InterfaceUser _repository;

        public CreateProfilePictureUseCase(CloudinaryService cloudinaryService, InterfaceUser repository)
        {
            _cloudinaryService = cloudinaryService;
            _repository = repository;
        }

        public async Task<string> Execute(string token, IFormFile file)
        {

            var tokenHandler = new JwtSecurityTokenHandler();
            var jwtToken = tokenHandler.ReadJwtToken(token);

            // Extrai o ID do token
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

            //if (!Guid.TryParse(userIdString, out Guid userId))
            //{
            //    throw new Exception("Invalid user ID format");
            //}


            var user = await _repository.GetUserById(userId);
            if (user == null)
            {
                throw new Exception("User not found");
            }

            // Faz o upload da imagem para o Cloudinary
            var imageUrl = await _cloudinaryService.UploadImageAsync(file, "profile_images");

            // Atualiza a URL da imagem no perfil do usuário
            user.ProfilePictureUrl = imageUrl;
            await _repository.UpdateUser(user);

            return imageUrl;
        }
    }
}
