using apiUrbanPlanning.Infrastructure.Models;
using ApiUrbanPlanning.Infrastructure.Models;

namespace ApiUrbanPlanning.Infrastructure.Repositories
{
    public interface InterfacePost
    {
        Task CreatePost(Post Object);
        Task<List<Post>> GetAllPostAdm( int NumberSuggestion, DateTime? DateCalendar, int pageNumber, int pageSize);

        Task<List<Post>> GetAllPostsFeed(int pageNumber, int pageSize);
    }
}
