using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Requests;
using apiUrbanPlanning.Response;
using Microsoft.AspNetCore.Identity;

namespace apiUrbanPlanning.UseCase.Users
{
    public class CreateAccountUseCase
    {
        private readonly InterfaceUser _repository;   //readonly só pode ser atribuida uma vez 
        private readonly PasswordHasher<User> _passwordHasher;   //utilizar a classe de hash

        public CreateAccountUseCase(InterfaceUser repository)
        {
            _repository = repository;
            _passwordHasher = new PasswordHasher<User>();
        }

        public async Task<RegisterUserResponse> Execute(RequestUser request)
        {
            // Verifica se o e-mail já existe
            var existingUser = await _repository.GetUserByEmail(request.Email);
            if (existingUser != null)
            {
                throw new Exception("Email already exists");
            }

            var user = new User
            {
                Name = request.Name,
                Email = request.Email,
            };

            //hash da senha
            user.Password = _passwordHasher.HashPassword(user, request.Password);


            // Cria o novo usuário no repositório
            await _repository.CreateUser(user);

            return new RegisterUserResponse
            {
                Id = user.Id,
                Name = request.Name,
            };
        }
    }
}
