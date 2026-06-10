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

        public async Task<PaginatedAdmResponse<GetAllPostAdmResponse>> Execute(
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

            var (posts, total) = await _repository.GetAllPostAdm(
                NumberSuggestion, Status, selectedDate, ibgeId, pageNumber, pageSize);

            var postsResponse = new List<GetAllPostAdmResponse>();

            foreach (var post in posts)
            {
                var user = await _userRepository.GetUserById(post.UserId);
                var suggestion = await _suggestionRepository.GetSuggestionById(post.SuggestionId);

                postsResponse.Add(new GetAllPostAdmResponse
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
                    UserName = user?.Name ?? string.Empty,
                    ProfilePictureUrl = user?.ProfilePictureUrl ?? string.Empty
                });
            }

            return new PaginatedAdmResponse<GetAllPostAdmResponse>
            {
                Data = postsResponse,
                Meta = PaginationMeta.Create(pageNumber, pageSize, total),
            };
        }
    }
}
