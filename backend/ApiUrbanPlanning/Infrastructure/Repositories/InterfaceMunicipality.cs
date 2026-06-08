using apiUrbanPlanning.Infrastructure.Models;

namespace apiUrbanPlanning.Infrastructure.Repositories
{
    public interface InterfaceMunicipality
    {
        Task Create(Municipality municipality);
        Task<Municipality?> GetById(Guid id);
        Task Update(Municipality municipality);
        Task<bool> ExistsByIbgeId(int ibgeId);
        Task<bool> ExistsBySlug(string slug);
        Task<bool> ExistsBySlugExceptId(string slug, Guid id);
        Task<List<Municipality>> GetAll();
    }
}
