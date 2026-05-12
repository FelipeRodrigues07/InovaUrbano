using apiUrbanPlanning.Infrastructure.Data;
using apiUrbanPlanning.Infrastructure.Models;
using Microsoft.EntityFrameworkCore;

namespace apiUrbanPlanning.Infrastructure.Repositories.user
{
    public class RepositoryUser : InterfaceUser
    {
        private readonly InfrastructureDbContext _context;

        public RepositoryUser(InfrastructureDbContext context)
        {
            _context = context;
        }

        public async Task CreateUser(User user)
        {
            await _context.Set<User>().AddAsync(user);
            await _context.SaveChangesAsync();
        }

        public async Task<User> GetUserById(Guid id)
        {
            return await _context.Set<User>().FindAsync(id);
        }

        public async Task<User> GetUserByEmail(string email)
        {
            return await _context.Set<User>().FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task UpdateUser(User user)
        {
            var existingUser = await GetUserById(user.Id);
            if (existingUser != null)
            {
                _context.Entry(existingUser).CurrentValues.SetValues(user);  
                await _context.SaveChangesAsync();
            }
        }


    }
}
