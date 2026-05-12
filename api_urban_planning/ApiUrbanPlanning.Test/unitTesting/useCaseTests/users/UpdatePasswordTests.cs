using ApiUrbanPlanning.UseCase.Users;
using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Requests;
using Moq;
using Microsoft.Extensions.Configuration;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Identity;

namespace ApiUrbanPlanning.Test.unitTesting.useCaseTests.users
{
    public class UpdatePasswordUseCaseTests
    {
        private readonly Mock<InterfaceUser> _repositoryMock;
        private readonly Mock<IConfiguration> _configurationMock;
        private readonly UpdatePasswordUseCase _updatePasswordUseCase;
        private readonly string _validJwtSecret = "A256BitSecretKeyForTestingPurposes1234567890";

        public UpdatePasswordUseCaseTests()
        {
            _repositoryMock = new Mock<InterfaceUser>();
            _configurationMock = new Mock<IConfiguration>();
            _configurationMock.Setup(c => c["JwtSettings:Secret"]).Returns(_validJwtSecret);
            _updatePasswordUseCase = new UpdatePasswordUseCase(_repositoryMock.Object, _configurationMock.Object);
        }

        [Fact]
        public async Task Execute_WithValidTokenAndCorrectPassword_UpdatesPasswordSuccessfully()
        {
            var userId = Guid.NewGuid();
            var user = new User
            {
                Id = userId,
                Name = "Test User",
                Email = "test@example.com",
                Password = new PasswordHasher<User>().HashPassword(null, "oldpassword123"),
                Role = "User"
            };

            var request = new RequestPasswordUpdate
            {
                OldPassword = "oldpassword123",
                NewPassword = "newpassword123"
            };

            var token = GenerateValidToken(userId);

            _repositoryMock.Setup(repo => repo.GetUserById(userId)).ReturnsAsync(user);
            _repositoryMock.Setup(repo => repo.UpdateUser(It.IsAny<User>())).Returns(Task.CompletedTask);

            await _updatePasswordUseCase.Execute(token, request);

            _repositoryMock.Verify(repo => repo.UpdateUser(It.Is<User>(u => u.Password != user.Password)), Times.Once);
        }

        [Fact]
        public async Task Execute_WithInvalidToken_ThrowsUnauthorizedAccessException()
        {
            var invalidToken = "invalidToken";

            var request = new RequestPasswordUpdate
            {
                OldPassword = "oldpassword123",
                NewPassword = "newpassword123"
            };

            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _updatePasswordUseCase.Execute(invalidToken, request));
        }

        [Fact]
        public async Task Execute_WithIncorrectOldPassword_ThrowsUnauthorizedAccessException()
        {
            var userId = Guid.NewGuid();
            var user = new User
            {
                Id = userId,
                Name = "Test User",
                Email = "test@example.com",
                Password = new PasswordHasher<User>().HashPassword(null, "oldpassword123"),
                Role = "User"
            };

            var request = new RequestPasswordUpdate
            {
                OldPassword = "wrongOldPassword",
                NewPassword = "newpassword123"
            };

            var token = GenerateValidToken(userId);

            _repositoryMock.Setup(repo => repo.GetUserById(userId)).ReturnsAsync(user);

            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _updatePasswordUseCase.Execute(token, request));
        }

        [Fact]
        public async Task Execute_WithNonExistentUser_ThrowsKeyNotFoundException()
        {
            var userId = Guid.NewGuid();
            var user = new User
            {
                Id = userId,
                Name = "Test User",
                Email = "test@example.com",
                Password = new PasswordHasher<User>().HashPassword(null, "oldpassword123"),
                Role = "User"
            };

            var request = new RequestPasswordUpdate
            {
                OldPassword = "oldpassword123",
                NewPassword = "newpassword123"
            };

            var token = GenerateValidToken(userId);

            _repositoryMock.Setup(repo => repo.GetUserById(userId)).ReturnsAsync((User)null);

            await Assert.ThrowsAsync<KeyNotFoundException>(() => _updatePasswordUseCase.Execute(token, request));
        }

        private string GenerateValidToken(Guid userId)
        {
            var claims = new[] {
                new System.Security.Claims.Claim("id", userId.ToString())
            };

            var key = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(_validJwtSecret));
            var creds = new Microsoft.IdentityModel.Tokens.SigningCredentials(key, Microsoft.IdentityModel.Tokens.SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: "TestIssuer",
                audience: "TestAudience",
                claims: claims,
                expires: DateTime.Now.AddMinutes(30),
                signingCredentials: creds);

            var tokenHandler = new JwtSecurityTokenHandler();
            return tokenHandler.WriteToken(token);
        }
    }
}
