using apiUrbanPlanning.Infrastructure.Data;
using ApiUrbanPlanning.Infrastructure.Models;
using Microsoft.EntityFrameworkCore;

namespace ApiUrbanPlanning.Infrastructure.Repositories
{
    public class RepositoryOfficialResponse : InterfaceOfficialResponse
    {
        private readonly InfrastructureDbContext _context;

        public RepositoryOfficialResponse(InfrastructureDbContext context)
        {
            _context = context;
        }

        public async Task CreateOfficialResponse(OfficialResponse officialResponse)
        {
            await _context.OfficialResponses.AddAsync(officialResponse);
            await _context.SaveChangesAsync();
        }

        public async Task<(List<OfficialResponse> Items, int Total)> GetAllOfficialResponsesAdm(
            int numberSuggestion,
            string status,
            DateTime? dateCalendar,
            int? ibgeId,
            int pageNumber,
            int pageSize)
        {
            var query = _context.OfficialResponses.AsQueryable();

            if (numberSuggestion > 0)
            {
                query = query.Where(r => r.NumberSuggestion == numberSuggestion);
            }

            if (dateCalendar.HasValue)
            {
                query = query.Where(r => r.CreatedAt.Date == dateCalendar.Value.Date);
            }

            if (!string.IsNullOrEmpty(status) && status != "Todas")
            {
                query = query.Where(r =>
                    r.StatusAtPublish == status
                    || (r.StatusAtPublish == string.Empty
                        && _context.Suggestions.Any(s =>
                            s.Id == r.SuggestionId && s.Status == status)));
            }

            if (ibgeId.HasValue && ibgeId.Value > 0)
            {
                query = query.Where(r =>
                    _context.Suggestions.Any(s =>
                        s.Id == r.SuggestionId && s.IbgeId == ibgeId.Value));
            }

            query = query.OrderByDescending(r => r.CreatedAt);

            var total = await query.CountAsync();
            var items = await query
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return (items, total);
        }

        public async Task<List<OfficialResponse>> GetAllOfficialResponsesFeed(int pageNumber, int pageSize, int? ibgeId)
        {
            if (!ibgeId.HasValue)
            {
                return new List<OfficialResponse>();
            }

            var query = _context.OfficialResponses.Where(r =>
                _context.Suggestions.Any(s =>
                    s.Id == r.SuggestionId && s.IbgeId == ibgeId.Value));

            return await query
                .OrderByDescending(r => r.CreatedAt)
                .Skip((pageNumber - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
        }
    }
}
