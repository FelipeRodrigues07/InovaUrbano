using ApiUrbanPlanning.Infrastructure.Models;

namespace ApiUrbanPlanning.Infrastructure.Repositories
{
    public interface InterfaceOfficialResponse
    {
        Task CreateOfficialResponse(OfficialResponse officialResponse);
        Task<(List<OfficialResponse> Items, int Total)> GetAllOfficialResponsesAdm(
            int numberSuggestion,
            string status,
            DateTime? dateCalendar,
            int? ibgeId,
            int pageNumber,
            int pageSize);
        Task<List<OfficialResponse>> GetAllOfficialResponsesFeed(int pageNumber, int pageSize, int? ibgeId);
    }
}
