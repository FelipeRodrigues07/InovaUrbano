using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Response;

namespace ApiUrbanPlanning.UseCase.Post
{
    public class GetAllPostAdmUseCase
    {
        private readonly InterfacePost _repository;
        private readonly InterfaceUser _userRepository;
        private readonly InterfaceSuggestion _suggestionRepository;

        public GetAllPostAdmUseCase(
            InterfacePost repository,
            InterfaceUser userRepository,
            InterfaceSuggestion suggestionRepository)
        {
            _repository = repository;
            _userRepository = userRepository;
            _suggestionRepository = suggestionRepository;
        }

        public async Task<List<GetAllPostAdmResponse>> Execute(
            int NumberSuggestion,
            string Status,
            string DateCalendar,
            int? ibgeId,
            int pageNumber,
            int pageSize)
        {

            DateTime? selectedDate = string.IsNullOrEmpty(DateCalendar)
                          ? (DateTime?)null
                          : DateTime.SpecifyKind(DateTime.Parse(DateCalendar), DateTimeKind.Utc);

            var posts = await _repository.GetAllPostAdm(NumberSuggestion, Status, selectedDate, ibgeId, pageNumber, pageSize);
            var suggestionsResponse = new List<GetAllPostAdmResponse>();


            foreach (var post in posts)
            {
                var user = await _userRepository.GetUserById(post.UserId);
                var suggestion = await _suggestionRepository.GetSuggestionById(post.SuggestionId);

                suggestionsResponse.Add(new GetAllPostAdmResponse
                {
                    Id = post.Id,
                    Title = post.Title,
                    Description = post.Description,
                    Status = suggestion?.Status ?? string.Empty,
                    UserId = post.UserId,
                    PostImageUrl = post.PostImageUrl,
                    Number = post.Number,
                    NumberSuggestion = post.NumberSuggestion,   
                    CreatedAt = post.CreatedAt,
                    UserName = user.Name,
                    ProfilePictureUrl = user.ProfilePictureUrl
                });
            }
            return suggestionsResponse;


        }
    }
}
