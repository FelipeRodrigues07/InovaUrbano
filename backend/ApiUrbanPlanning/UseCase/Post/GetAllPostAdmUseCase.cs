using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Response;

namespace ApiUrbanPlanning.UseCase.Post
{
    public class GetAllPostAdmUseCase
    {
        private readonly InterfacePost _repository;
        private readonly InterfaceUser _userRepository;

        public GetAllPostAdmUseCase(InterfacePost repository, InterfaceUser userRepository)
        {
            _repository = repository;
            _userRepository = userRepository;
        }

        public async Task<List<GetAllPostAdmResponse>> Execute( int NumberSuggestion, string DateCalendar, int pageNumber, int pageSize)
        {

            DateTime? selectedDate = string.IsNullOrEmpty(DateCalendar)
                          ? (DateTime?)null
                          : DateTime.SpecifyKind(DateTime.Parse(DateCalendar), DateTimeKind.Utc);

            var posts = await _repository.GetAllPostAdm( NumberSuggestion, selectedDate, pageNumber, pageSize);
            var suggestionsResponse = new List<GetAllPostAdmResponse>();


            foreach (var post in posts)
            {
                var user = await _userRepository.GetUserById(post.UserId);

                suggestionsResponse.Add(new GetAllPostAdmResponse
                {
                    Id = post.Id,
                    Title = post.Title,
                    Description = post.Description,
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
