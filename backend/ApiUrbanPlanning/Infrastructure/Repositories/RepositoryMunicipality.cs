using apiUrbanPlanning.Infrastructure.Data;
using apiUrbanPlanning.Infrastructure.Models;
using Microsoft.EntityFrameworkCore;

namespace apiUrbanPlanning.Infrastructure.Repositories
{
    public class RepositoryMunicipality : InterfaceMunicipality
    {
        private readonly InfrastructureDbContext _context;

        public RepositoryMunicipality(InfrastructureDbContext context)
        {
            _context = context;
        }

        public async Task Create(Municipality municipality)
        {
            await _context.Municipalities.AddAsync(municipality);
            await _context.SaveChangesAsync();
        }

        public async Task<Municipality?> GetById(Guid id)
        {
            return await _context.Municipalities.FindAsync(id);
        }

        public async Task Update(Municipality municipality)
        {
            _context.Municipalities.Update(municipality);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> ExistsByIbgeId(int ibgeId)
        {
            return await _context.Municipalities.AnyAsync(m => m.IbgeId == ibgeId);
        }

        public async Task<bool> ExistsBySlug(string slug)
        {
            return await _context.Municipalities.AnyAsync(m => m.Slug == slug);
        }

        public async Task<bool> ExistsBySlugExceptId(string slug, Guid id)
        {
            return await _context.Municipalities.AnyAsync(m => m.Slug == slug && m.Id != id);
        }

        public async Task<List<Municipality>> GetAll()
        {
            return await _context.Municipalities
                .OrderBy(m => m.Name)
                .ToListAsync();
        }
    }
}
