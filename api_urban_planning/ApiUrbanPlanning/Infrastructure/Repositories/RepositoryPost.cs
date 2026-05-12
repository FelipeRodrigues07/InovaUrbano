
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

        public async Task<List<Post>> GetAllPostAdm( int postNumber, DateTime? DateCalendar, int pageNumber, int pageSize)
        {
            var query = _context.Posts.AsQueryable();

            //if (!string.IsNullOrEmpty(status) && status != "Todas")
            //{
            //    query = query.Where(s => s.Status == status);
            //}

            if (postNumber > 0)
            {
                query = query.Where(s => s.Number == postNumber);
            }

            if (DateCalendar.HasValue)
            {
                query = query.Where(s => s.CreatedAt.Date == DateCalendar.Value.Date);
            }

            query = query.OrderByDescending(s => s.CreatedAt);

            query = query.Skip((pageNumber - 1) * pageSize).Take(pageSize);

            return await query.ToListAsync();
        }


        public async Task<List<Post>> GetAllPostsFeed(int pageNumber, int pageSize)
        {
            return await _context.Posts
                                 //.OrderByDescending(s => s.CreatedAt)
                                 .Skip((pageNumber - 1) * pageSize)
                                 .Take(pageSize)
                                 .ToListAsync();
        }

    }
}
