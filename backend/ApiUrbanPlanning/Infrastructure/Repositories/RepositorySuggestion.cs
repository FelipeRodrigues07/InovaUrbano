using apiUrbanPlanning.Infrastructure.Data;
using apiUrbanPlanning.Infrastructure.Models;
using Microsoft.EntityFrameworkCore;

namespace apiUrbanPlanning.Infrastructure.Repositories
{
    public class RepositorySuggestion : InterfaceSuggestion
    {

        private readonly InfrastructureDbContext _context;

        public RepositorySuggestion(InfrastructureDbContext context)
        {
            _context = context;
        }

        public async  Task CreateSuggestion(Suggestion suggestion)
        {
            await _context.Set<Suggestion>().AddAsync(suggestion);
            await _context.SaveChangesAsync();

        }

        public async Task<List<Suggestion>> GetAllSuggestions(double latMin, double latMax, double lonMin, double lonMax, string Status)
        {

            var query = _context.Suggestions
        .Where(s => s.Latitude >= latMin && s.Latitude <= latMax && s.Longitude >= lonMin && s.Longitude <= lonMax);

            if (Status != "Todas")
            {
                query = query.Where(s => s.Status == Status);
            }

            return await query.ToListAsync();
        }

        public async Task<List<Suggestion>> GetAllSuggestionsFeed(int pageNumber, int pageSize, int? ibgeId)
        {
            if (!ibgeId.HasValue)
            {
                return new List<Suggestion>();
            }

            var query = _context.Suggestions.Where(s => s.IbgeId == ibgeId.Value);

            return await query
                .OrderByDescending(s => s.CreatedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }



        public async Task<List<Suggestion>> GetAllSuggestionsAdm(string status, int suggestionNumber, DateTime? DateCalendar, int? ibgeId, int pageNumber, int pageSize)
        {
            var query = _context.Suggestions.AsQueryable();

            if (!string.IsNullOrEmpty(status) && status != "Todas")
            {
                query = query.Where(s => s.Status == status);
            }

            if (suggestionNumber > 0)
            {
                query = query.Where(s => s.Number == suggestionNumber);
            }

            if (DateCalendar.HasValue)
            {
                query = query.Where(s => s.CreatedAt.Date == DateCalendar.Value.Date);
            }

            if (ibgeId.HasValue && ibgeId.Value > 0)
            {
                query = query.Where(s => s.IbgeId == ibgeId.Value);
            }

            query = query.OrderByDescending(s => s.CreatedAt);

            query = query.Skip((pageNumber - 1) * pageSize).Take(pageSize);

            return await query.ToListAsync();
        }

        public async Task<Suggestion?> GetSuggestionByNumber(int number)
        {
            return await _context.Suggestions.FirstOrDefaultAsync(s => s.Number == number);
        }

        public async Task<Suggestion> GetSuggestionById(Guid id)
        {
            return await _context.Set<Suggestion>().FindAsync(id);
        }

        public async Task UpdateSuggestion(Suggestion suggestion)
        {
            var existingSuggestion = await GetSuggestionById(suggestion.Id);
            if (existingSuggestion != null)
            {
                _context.Entry(existingSuggestion).CurrentValues.SetValues(suggestion);
                await _context.SaveChangesAsync();
            }
        }




    }


}
