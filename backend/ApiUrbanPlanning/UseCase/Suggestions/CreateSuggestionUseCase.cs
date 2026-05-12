using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Infrastructure.Services;
using apiUrbanPlanning.Requests;


namespace apiUrbanPlanning.UseCase.Suggestions
{
    public class CreateSuggestionUseCase
    {
        private readonly InterfaceSuggestion _repository;

        public CreateSuggestionUseCase(InterfaceSuggestion repository)
        {
            _repository = repository;
        }

        public async Task Execute(RequestSuggestion request, string imageUrl)
        {
            {

                var suggestion = new Suggestion
                {
                    Type = request.Type,
                    Description = request.Description,
                    Latitude = request.Latitude,
                    Longitude = request.Longitude,
                    UserId = request.UserId,
                    IbgeId = request.IbgeId,
                    SuggestionImageUrl = imageUrl,


                };

                await _repository.CreateSuggestion(suggestion);
            }
        }
    }
}
