using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Response;
using ApiUrbanPlanning.Response;

namespace ApiUrbanPlanning.UseCase.Suggestions
{
    public class GetAllSuggestionsAdmUseCase
    {
        private readonly InterfaceSuggestion _repository;
        private readonly InterfaceUser _userRepository;

        public GetAllSuggestionsAdmUseCase(InterfaceSuggestion repository, InterfaceUser userRepository)
        {
            _repository = repository;
            _userRepository = userRepository;
        }

        public async Task<List<GetAllSuggestionsAdmResponse>> Execute(string Status, int NumberSuggestion, string DateCalendar, int? ibgeId, int pageNumber, int pageSize)
        {

            DateTime? selectedDate = string.IsNullOrEmpty(DateCalendar)
                          ? (DateTime?)null
                          : DateTime.SpecifyKind(DateTime.Parse(DateCalendar), DateTimeKind.Utc);

            var suggestions = await _repository.GetAllSuggestionsAdm(Status, NumberSuggestion, selectedDate, ibgeId, pageNumber, pageSize);
            var suggestionsResponse = new List<GetAllSuggestionsAdmResponse>();


            foreach (var suggestion in suggestions)
            {
                var user = await _userRepository.GetUserById(suggestion.UserId);

                suggestionsResponse.Add(new GetAllSuggestionsAdmResponse
                {
                    Id = suggestion.Id,
                    Type = suggestion.Type,
                    Description = suggestion.Description,
                    Latitude = suggestion.Latitude,
                    Longitude = suggestion.Longitude,
                    Status = suggestion.Status,
                    UserId = suggestion.UserId,
                    SuggestionImageUrl = suggestion.SuggestionImageUrl,
                    Number = suggestion.Number,
                    CreatedAt = suggestion.CreatedAt,
                    UserName = user.Name,
                    ProfilePictureUrl = user.ProfilePictureUrl
                });
            }
            return suggestionsResponse;

           
        }

    }
}
