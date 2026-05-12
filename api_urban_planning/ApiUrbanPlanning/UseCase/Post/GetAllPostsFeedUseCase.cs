using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Response;
using ApiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Response;

namespace ApiUrbanPlanning.UseCase.Post
{
    public class GetAllPostsFeedUseCase
    {
        private readonly InterfacePost _repository;
        private readonly InterfaceUser _userRepository;

        public GetAllPostsFeedUseCase(InterfacePost repository, InterfaceUser userRepository)
        {
            _repository = repository;
            _userRepository = userRepository;
        }


        public async Task<List<GetAllPostsFeedResponse>> Execute(int pageNumber, int pageSize)
        {
            var posts = await _repository.GetAllPostsFeed(pageNumber, pageSize);
            var postResponses = new List<GetAllPostsFeedResponse>();

            foreach (var post in posts)
            {
                var user = await _userRepository.GetUserById(post.UserId);

                postResponses.Add(new GetAllPostsFeedResponse
                {
                    Id = post.Id,
                    Title = post.Title,
                    Description = post.Description,
                    UserId = post.UserId,
                    PostImageUrl = post.PostImageUrl,
                    CreatedAt = post.CreatedAt,
                    UserName = user.Name,
                    ProfilePictureUrl = user.ProfilePictureUrl
                });
            }
            return postResponses;
        }
    }
}
