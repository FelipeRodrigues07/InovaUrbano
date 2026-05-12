using apiUrbanPlanning.Infrastructure.Models;

namespace apiUrbanPlanning.Infrastructure.Repositories
{
    public interface InterfaceUser
    {
        Task CreateUser(User Objeto);
        Task<User> GetUserById(Guid id);

        Task<User> GetUserByEmail(string email);

        Task UpdateUser(User user);
    }
}
