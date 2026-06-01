
using ApiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using apiUrbanPlanning.Infrastructure.Models;

namespace ApiUrbanPlanning.Infrastructure.Repositories
{
    public class RepositoryPost : InterfacePost
    {
        private readonly InfrastructureDbContext _context;

        public RepositoryPost(InfrastructureDbContext context)
        {
            _context = context;
        }

        public async Task CreatePost(Post post)
        {
            await _context.Set<Post>().AddAsync(post);
            await _context.SaveChangesAsync();

        }

        public async Task<List<Post>> GetAllPostAdm(int numberSuggestion, string status, DateTime? DateCalendar, int? ibgeId, int pageNumber, int pageSize)
        {
            var query = _context.Posts.AsQueryable();

            if (numberSuggestion > 0)
            {
                query = query.Where(p => p.NumberSuggestion == numberSuggestion);
            }

            if (DateCalendar.HasValue)
            {
                query = query.Where(p => p.CreatedAt.Date == DateCalendar.Value.Date);
            }

            if (!string.IsNullOrEmpty(status) && status != "Todas")
            {
                query = query.Where(p =>
                    _context.Suggestions.Any(s =>
                        s.Id == p.SuggestionId && s.Status == status));
            }

            if (ibgeId.HasValue && ibgeId.Value > 0)
            {
                query = query.Where(p =>
                    _context.Suggestions.Any(s =>
                        s.Id == p.SuggestionId && s.IbgeId == ibgeId.Value));
            }

            query = query.OrderByDescending(p => p.CreatedAt);

            query = query.Skip((pageNumber - 1) * pageSize).Take(pageSize);

            return await query.ToListAsync();
        }


        public async Task<List<Post>> GetAllPostsFeed(int pageNumber, int pageSize, int? ibgeId)
        {
            if (!ibgeId.HasValue)
            {
                return new List<Post>();
            }

            var query = _context.Posts.Where(p =>
                _context.Suggestions.Any(s =>
                    s.Id == p.SuggestionId && s.IbgeId == ibgeId.Value));

            return await query
                .OrderByDescending(p => p.CreatedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }

    }
}
