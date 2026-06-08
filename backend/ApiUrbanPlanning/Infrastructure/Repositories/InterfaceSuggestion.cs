

using apiUrbanPlanning.Infrastructure.Models;

namespace apiUrbanPlanning.Infrastructure.Repositories
{
    public interface InterfaceSuggestion
    {
        Task CreateSuggestion(Suggestion Objeto);

        Task<List<Suggestion>> GetAllSuggestions(double latMin, double latMax, double lonMin, double lonMax, string Status);
        Task<List<Suggestion>> GetAllSuggestionsFeed(int pageNumber, int pageSize, int? ibgeId);
        Task<(List<Suggestion> Items, int Total)> GetAllSuggestionsAdm(string Status, int NumberSuggestion, DateTime? DateCalendar, int? ibgeId, int pageNumber, int pageSize);
        Task<Suggestion> GetSuggestionByNumber(int number);
        Task UpdateSuggestion(Suggestion suggestion);

        Task<Suggestion> GetSuggestionById(Guid id);

        Task<SuggestionsAnalyticsData> GetSuggestionsAnalytics(
            string status,
            int? ibgeId,
            DateTime? dateFrom,
            DateTime? dateTo,
            string groupBy);

    }
}