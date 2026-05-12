using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Requests;
using apiUrbanPlanning.Response;
using Moq;
using apiUrbanPlanning.UseCase.Users;

namespace ApiUrbanPlanning.Test.unitTesting.useCaseTests.users
{
    public class CreateAccountUseCaseTests
    {
        private readonly Mock<InterfaceUser> _userRepositoryMock;
        private readonly CreateAccountUseCase _createAccountUseCase;

        public CreateAccountUseCaseTests()
        {
            _userRepositoryMock = new Mock<InterfaceUser>();
            _createAccountUseCase = new CreateAccountUseCase(_userRepositoryMock.Object);
        }

        [Fact]
        public async Task Execute_WithValidData_ReturnsRegisterUserResponse()
        {

            var request = new RequestUser { Name = "New User", Email = "newuser@example.com", Password = "password123" };
            var existingUser = (User)null; 

            _userRepositoryMock.Setup(repo => repo.GetUserByEmail(It.IsAny<string>())).ReturnsAsync(existingUser);

            var expectedUserResponse = new RegisterUserResponse
            {
                Id = Guid.NewGuid(),
                Name = request.Name
            };

            _userRepositoryMock.Setup(repo => repo.CreateUser(It.IsAny<User>())).Returns(Task.CompletedTask); // Simula criação de usuário

            var response = await _createAccountUseCase.Execute(request);
            Assert.NotNull(response);
            Assert.Equal(request.Name, response.Name);
            _userRepositoryMock.Verify(repo => repo.CreateUser(It.IsAny<User>()), Times.Once); // Verifica que o CreateUser foi chamado uma vez
        }

        [Fact]
        public async Task Execute_WithExistingEmail_ThrowsException()
        {
            var request = new RequestUser { Name = "New User", Email = "existing@example.com", Password = "password123" };
            var existingUser = new User { Id = Guid.NewGuid(), Name = "Existing User", Email = "existing@example.com" };

            _userRepositoryMock.Setup(repo => repo.GetUserByEmail(It.IsAny<string>())).ReturnsAsync(existingUser); // E-mail já existente

            var exception = await Assert.ThrowsAsync<Exception>(() => _createAccountUseCase.Execute(request));
            Assert.Equal("Email already exists", exception.Message);
        }

        [Fact]
        public async Task Execute_WhenRepositoryFails_ThrowsException()
        {
            var request = new RequestUser { Name = "New User", Email = "newuser@example.com", Password = "password123" };
            var existingUser = (User)null;

            _userRepositoryMock.Setup(repo => repo.GetUserByEmail(It.IsAny<string>())).ReturnsAsync(existingUser);

            _userRepositoryMock.Setup(repo => repo.CreateUser(It.IsAny<User>())).ThrowsAsync(new Exception("Database error")); 

            var exception = await Assert.ThrowsAsync<Exception>(() => _createAccountUseCase.Execute(request));
            Assert.Equal("Database error", exception.Message);
        }
    }
}
