using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Infrastructure.Services;
using System.IdentityModel.Tokens.Jwt;

namespace apiUrbanPlanning.UseCase.Users
{
    public class DeleteProfilePictureUseCase
    {
        private readonly CloudinaryService _cloudinaryService;
        private readonly InterfaceUser _repository;

        public DeleteProfilePictureUseCase(CloudinaryService cloudinaryService, InterfaceUser repository)
        {
            _cloudinaryService = cloudinaryService;
            _repository = repository;
        }

        public async Task Execute(string token)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var jwtToken = tokenHandler.ReadJwtToken(token);

            // tira o ID do token
            var userIdClaim = jwtToken.Claims.FirstOrDefault(c => c.Type == "id");
            if (userIdClaim == null)
            {
                throw new UnauthorizedAccessException("ID de usuário não encontrado no token.");
            }

            // Converte o ID string para Guid
            if (!Guid.TryParse(userIdClaim.Value, out var userId))
            {
                throw new FormatException("Formato de ID de usuário inválido.");
            }

            var user = await _repository.GetUserById(userId);
            if (user == null)
            {
                throw new Exception("User not found");
            }

           
            if (!string.IsNullOrEmpty(user.ProfilePictureUrl))
            {
                // Extrai o public ID da imagem do Cloudinary  da URL
                var publicId = _cloudinaryService.GetPublicIdFromUrl(user.ProfilePictureUrl);
           
                
                await _cloudinaryService.DeleteImageAsync(publicId);


                user.ProfilePictureUrl = string.Empty;
                await _repository.UpdateUser(user);
            }

        }
    }
}
