using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.UseCase.Users;
using Moq;
using Microsoft.Extensions.Configuration;
using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Requests;
using Microsoft.AspNetCore.Identity;

namespace apiUrbanPlanning.Tests.unitTesting.useCaseTests.users
{
    public class AuthenticateUseCaseTests
    {
        private readonly Mock<InterfaceUser> _userRepositoryMock;
        private readonly Mock<IConfiguration> _configurationMock;
        private readonly AuthenticateUseCase _authenticateUseCase;

        public AuthenticateUseCaseTests()
        {
            _userRepositoryMock = new Mock<InterfaceUser>();
            _configurationMock = new Mock<IConfiguration>();

            _configurationMock.Setup(c => c["JwtSettings:Secret"]).Returns("A256BitSecretKeyForTestingPurposes1234567890");

            _authenticateUseCase = new AuthenticateUseCase(_userRepositoryMock.Object, _configurationMock.Object);
        }

        [Fact]
        public async Task Execute_WithValidCredentials_ReturnsAuthenticateUserResponse()
        {

            var user = new User { Id = Guid.NewGuid(), Name = "Test User", Email = "test@example.com", Password = new PasswordHasher<User>().HashPassword(null, "password123"), Role = "User" };
            var request = new RequestAuthenticate { Email = "test@example.com", Password = "password123" };

            _userRepositoryMock.Setup(repo => repo.GetUserByEmail(It.IsAny<string>())).ReturnsAsync(user);


            var response = await _authenticateUseCase.Execute(request);


            Assert.NotNull(response);
            Assert.Equal(user.Id, response.Id);
            Assert.Equal(user.Name, response.Name);
            Assert.Equal(user.Email, response.Email);
            Assert.NotNull(response.Token);
        }

        [Fact]
        public async Task Execute_WithInvalidEmail_ThrowsInvalidOperationException()
        {

            var request = new RequestAuthenticate { Email = "invalid@example.com", Password = "password123" };
            _userRepositoryMock.Setup(repo => repo.GetUserByEmail(It.IsAny<string>())).ReturnsAsync((User)null);

            await Assert.ThrowsAsync<InvalidOperationException>(() => _authenticateUseCase.Execute(request));
        }

        [Fact]
        public async Task Execute_WithInvalidPassword_ThrowsUnauthorizedAccessException()
        {
            var user = new User { Id = Guid.NewGuid(), Email = "test@example.com", Password = new PasswordHasher<User>().HashPassword(null, "password123"), Role = "User" };
            var request = new RequestAuthenticate { Email = "test@example.com", Password = "wrongpassword" };

            _userRepositoryMock.Setup(repo => repo.GetUserByEmail(It.IsAny<string>())).ReturnsAsync(user);

            await Assert.ThrowsAsync<UnauthorizedAccessException>(() => _authenticateUseCase.Execute(request));
        }
    }
}
