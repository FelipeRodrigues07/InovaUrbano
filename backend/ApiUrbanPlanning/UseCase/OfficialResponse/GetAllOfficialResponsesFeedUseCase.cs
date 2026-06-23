using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Response;

namespace ApiUrbanPlanning.UseCase.OfficialResponse
{
    public class GetAllOfficialResponsesFeedUseCase
    {
        private readonly InterfaceOfficialResponse _repository;
        private readonly InterfaceUser _userRepository;
        private readonly InterfaceSuggestion _suggestionRepository;

        public GetAllOfficialResponsesFeedUseCase(
            InterfaceOfficialResponse repository,
            InterfaceUser userRepository,
            InterfaceSuggestion suggestionRepository)
        {
            _repository = repository;
            _userRepository = userRepository;
            _suggestionRepository = suggestionRepository;
        }

        public async Task<List<GetAllOfficialResponsesFeedResponse>> Execute(
            int pageNumber,
            int pageSize,
            int? ibgeId)
        {
            var responses = await _repository.GetAllOfficialResponsesFeed(pageNumber, pageSize, ibgeId);
            var feed = new List<GetAllOfficialResponsesFeedResponse>();

            foreach (var response in responses)
            {
                var user = await _userRepository.GetUserById(response.UserId);
                var suggestion = await _suggestionRepository.GetSuggestionById(response.SuggestionId);

                feed.Add(new GetAllOfficialResponsesFeedResponse
                {
                    Id = response.Id,
                    Title = response.Title,
                    Description = response.Description,
                    UserId = response.UserId,
                    PostImageUrl = response.PostImageUrl,
                    CreatedAt = response.CreatedAt,
                    NumberSuggestion = response.NumberSuggestion,
                    SuggestionIbgeId = suggestion?.IbgeId,
                    SuggestionType = suggestion?.Type ?? string.Empty,
                    SuggestionStatus = suggestion?.Status ?? string.Empty,
                    UserName = user?.Name ?? string.Empty,
                    ProfilePictureUrl = user?.ProfilePictureUrl ?? string.Empty,
                });
            }

            return feed;
        }
    }
}
