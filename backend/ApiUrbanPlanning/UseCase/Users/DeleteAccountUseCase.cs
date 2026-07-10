using System.IdentityModel.Tokens.Jwt;
using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Infrastructure.Services;
using apiUrbanPlanning.Requests;
using Microsoft.AspNetCore.Identity;

namespace apiUrbanPlanning.UseCase.Users
{
    public class DeleteAccountUseCase
    {
        private readonly InterfaceUser _repository;
        private readonly CloudinaryService _cloudinaryService;
        private readonly PasswordHasher<User> _passwordHasher;

        public DeleteAccountUseCase(
            InterfaceUser repository,
            CloudinaryService cloudinaryService)
        {
            _repository = repository;
            _cloudinaryService = cloudinaryService;
            _passwordHasher = new PasswordHasher<User>();
        }

        public async Task ExecuteFromToken(string token)
        {
            var userId = ExtractUserId(token);
            var user = await _repository.GetUserById(userId)
                ?? throw new KeyNotFoundException("Usuário não encontrado.");

            await AnonymizeAndSoftDelete(user);
        }

        public async Task ExecuteFromCredentials(RequestDeleteAccount request)
        {
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            {
                throw new InvalidOperationException("Email e senha são obrigatórios.");
            }

            var user = await _repository.GetUserByEmail(request.Email.Trim());
            if (user == null || user.DeletedAt != null)
            {
                // Resposta genérica para não revelar se o e-mail existe.
                return;
            }

            var passwordOk = _passwordHasher.VerifyHashedPassword(
                user, user.Password, request.Password);

            if (passwordOk == PasswordVerificationResult.Failed)
            {
                throw new UnauthorizedAccessException("Credenciais inválidas.");
            }

            await AnonymizeAndSoftDelete(user);
        }

        private async Task AnonymizeAndSoftDelete(User user)
        {
            if (user.DeletedAt != null)
            {
                return;
            }

            if (!string.IsNullOrEmpty(user.ProfilePictureUrl))
            {
                try
                {
                    var publicId = _cloudinaryService.GetPublicIdFromUrl(user.ProfilePictureUrl);
                    await _cloudinaryService.DeleteImageAsync(publicId);
                }
                catch
                {
                    // Não bloqueia a exclusão da conta se a remoção da imagem falhar.
                }
            }

            user.Name = "Usuário removido";
            user.Email = $"deleted-{user.Id:N}@deleted.local";
            user.Password = _passwordHasher.HashPassword(user, Guid.NewGuid().ToString("N"));
            user.ProfilePictureUrl = string.Empty;
            user.RefreshToken = null;
            user.RefreshTokenExpiresAt = null;
            user.DeletedAt = DateTime.UtcNow;
            user.UpdatedAt = DateTime.UtcNow;

            await _repository.UpdateUser(user);
        }

        private static Guid ExtractUserId(string token)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var jwtToken = tokenHandler.ReadJwtToken(token);

            var userIdClaim = jwtToken.Claims.FirstOrDefault(c => c.Type == "id")
                ?? throw new UnauthorizedAccessException("ID de usuário não encontrado no token.");

            if (!Guid.TryParse(userIdClaim.Value, out var userId))
            {
                throw new FormatException("Formato de ID de usuário inválido.");
            }

            return userId;
        }
    }
}
