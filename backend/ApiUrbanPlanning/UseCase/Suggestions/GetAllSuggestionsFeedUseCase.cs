using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Response;

namespace apiUrbanPlanning.UseCase.Suggestions
{
    public class GetAllSuggestionsFeedUseCase
    {
        private readonly InterfaceSuggestion _repository;
        private readonly InterfaceUser _userRepository;

        public GetAllSuggestionsFeedUseCase(InterfaceSuggestion repository, InterfaceUser userRepository)
        {
            _repository = repository;
            _userRepository = userRepository;
        }


        public async Task<List<GetAllSuggestionsFeedResponse>> Execute(int pageNumber, int pageSize, int? ibgeId)
        {
            var suggestions = await _repository.GetAllSuggestionsFeed(pageNumber, pageSize, ibgeId);
            var suggestionResponses = new List<GetAllSuggestionsFeedResponse>();

            foreach (var suggestion in suggestions)
            {
                var user = await _userRepository.GetUserById(suggestion.UserId); 

                suggestionResponses.Add(new GetAllSuggestionsFeedResponse
                {
                    Id = suggestion.Id,
                    Type = suggestion.Type,
                    Description = suggestion.Description,
                    Latitude = suggestion.Latitude,
                    Longitude = suggestion.Longitude,
                    Status = suggestion.Status,
                    UserId = suggestion.UserId,
                    SuggestionImageUrl = suggestion.SuggestionImageUrl,
                    CreatedAt = suggestion.CreatedAt,
                    UserName = user.Name, 
                    ProfilePictureUrl = user.ProfilePictureUrl 
                });
            }
            return suggestionResponses;
        }
    }
}
