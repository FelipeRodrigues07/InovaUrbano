using apiUrbanPlanning.Infrastructure.Models;
using ApiUrbanPlanning.Infrastructure.Models;

namespace ApiUrbanPlanning.Infrastructure.Repositories
{
    public interface InterfacePost
    {
        Task CreatePost(Post Object);
        Task<(List<Post> Items, int Total)> GetAllPostAdm(int NumberSuggestion, string status, DateTime? DateCalendar, int? ibgeId, int pageNumber, int pageSize);

        Task<List<Post>> GetAllPostsFeed(int pageNumber, int pageSize, int? ibgeId);
    }
}
