using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Response;

namespace ApiUrbanPlanning.UseCase.Post
{
    public class GetAllPostsFeedUseCase
    {
        private readonly InterfacePost _repository;
        private readonly InterfaceUser _userRepository;
        private readonly InterfaceSuggestion _suggestionRepository;

        public GetAllPostsFeedUseCase(
            InterfacePost repository,
            InterfaceUser userRepository,
            InterfaceSuggestion suggestionRepository)
        {
            _repository = repository;
            _userRepository = userRepository;
            _suggestionRepository = suggestionRepository;
        }

        public async Task<List<GetAllPostsFeedResponse>> Execute(
            int pageNumber,
            int pageSize,
            int? ibgeId)
        {
            var posts = await _repository.GetAllPostsFeed(pageNumber, pageSize, ibgeId);
            var postResponses = new List<GetAllPostsFeedResponse>();

            foreach (var post in posts)
            {
                var user = await _userRepository.GetUserById(post.UserId);
                var suggestion = await _suggestionRepository.GetSuggestionById(post.SuggestionId);

                postResponses.Add(new GetAllPostsFeedResponse
                {
                    Id = post.Id,
                    Title = post.Title,
                    Description = post.Description,
                    UserId = post.UserId,
                    PostImageUrl = post.PostImageUrl,
                    CreatedAt = post.CreatedAt,
                    NumberSuggestion = post.NumberSuggestion,
                    SuggestionIbgeId = suggestion?.IbgeId,
                    SuggestionType = suggestion?.Type ?? string.Empty,
                    SuggestionStatus = suggestion?.Status ?? string.Empty,
                    UserName = user.Name,
                    ProfilePictureUrl = user.ProfilePictureUrl
                });
            }

            return postResponses;
        }
    }
}
