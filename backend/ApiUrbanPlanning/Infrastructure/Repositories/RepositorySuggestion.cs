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



        public async Task<(List<Suggestion> Items, int Total)> GetAllSuggestionsAdm(string status, int suggestionNumber, DateTime? DateCalendar, int? ibgeId, int pageNumber, int pageSize)
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

            var total = await query.CountAsync();
            var items = await query
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (items, total);
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

        public async Task<SuggestionsAnalyticsData> GetSuggestionsAnalytics(
            string status,
            int? ibgeId,
            DateTime? dateFrom,
            DateTime? dateTo,
            string groupBy)
        {
            var query = _context.Suggestions.AsQueryable();

            if (!string.IsNullOrEmpty(status) && status != "Todas")
            {
                query = query.Where(s => s.Status == status);
            }

            if (ibgeId.HasValue && ibgeId.Value > 0)
            {
                query = query.Where(s => s.IbgeId == ibgeId.Value);
            }

            if (dateFrom.HasValue)
            {
                query = query.Where(s => s.CreatedAt >= dateFrom.Value);
            }

            if (dateTo.HasValue)
            {
                var endExclusive = dateTo.Value.Date.AddDays(1);
                query = query.Where(s => s.CreatedAt < endExclusive);
            }

            var total = await query.CountAsync();

            var byStatus = await query
                .GroupBy(s => s.Status)
                .Select(g => new AnalyticsCountItem { Label = g.Key, Count = g.Count() })
                .OrderByDescending(x => x.Count)
                .ToListAsync();

            var byType = await query
                .GroupBy(s => s.Type)
                .Select(g => new AnalyticsCountItem { Label = g.Key, Count = g.Count() })
                .OrderByDescending(x => x.Count)
                .ToListAsync();

            List<AnalyticsTimeSeriesItem> timeSeries;

            if (groupBy == "year")
            {
                var yearly = await query
                    .GroupBy(s => s.CreatedAt.Year)
                    .Select(g => new
                    {
                        Year = g.Key,
                        Count = g.Count(),
                    })
                    .OrderBy(x => x.Year)
                    .ToListAsync();

                timeSeries = yearly
                    .Select(x => new AnalyticsTimeSeriesItem
                    {
                        Period = x.Year.ToString(),
                        Count = x.Count,
                    })
                    .ToList();
            }
            else if (groupBy == "day")
            {
                var daily = await query
                    .GroupBy(s => s.CreatedAt.Date)
                    .Select(g => new
                    {
                        Date = g.Key,
                        Count = g.Count(),
                    })
                    .OrderBy(x => x.Date)
                    .ToListAsync();

                timeSeries = daily
                    .Select(x => new AnalyticsTimeSeriesItem
                    {
                        Period = x.Date.ToString("yyyy-MM-dd"),
                        Count = x.Count,
                    })
                    .ToList();
            }
            else
            {
                var monthly = await query
                    .GroupBy(s => new { s.CreatedAt.Year, s.CreatedAt.Month })
                    .Select(g => new
                    {
                        g.Key.Year,
                        g.Key.Month,
                        Count = g.Count(),
                    })
                    .OrderBy(x => x.Year)
                    .ThenBy(x => x.Month)
                    .ToListAsync();

                timeSeries = monthly
                    .Select(x => new AnalyticsTimeSeriesItem
                    {
                        Period = $"{x.Year:D4}-{x.Month:D2}",
                        Count = x.Count,
                    })
                    .ToList();
            }

            return new SuggestionsAnalyticsData
            {
                Total = total,
                TimeSeries = timeSeries,
                ByStatus = byStatus,
                ByType = byType,
            };
        }

    }


}
