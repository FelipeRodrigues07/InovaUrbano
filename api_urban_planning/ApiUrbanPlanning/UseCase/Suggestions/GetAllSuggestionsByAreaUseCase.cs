using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Response;

namespace apiUrbanPlanning.UseCase.Suggestions
{
    public class GetAllSuggestionsByAreaUseCase
    {
        private readonly InterfaceSuggestion _repository;

        public GetAllSuggestionsByAreaUseCase(InterfaceSuggestion repository)
        {
            _repository = repository;
        }


        public async Task<List<getAllSuggestionResponse>> Execute(double latMin, double latMax, double lonMin, double lonMax, string Status)
        {
            var suggestions = await _repository.GetAllSuggestions(latMin, latMax, lonMin, lonMax, Status);

            var suggestionResponses = suggestions.Select(s => new getAllSuggestionResponse 
            {
                Id = s.Id,
                Type = s.Type,
                Description = s.Description,
                Latitude = s.Latitude,
                Longitude = s.Longitude,
                Status = s.Status,
                UserId = s.UserId,
                SuggestionImageUrl = s.SuggestionImageUrl,
                CreatedAt = s.CreatedAt
            }).ToList();
            return suggestionResponses;
        }

    }
}
