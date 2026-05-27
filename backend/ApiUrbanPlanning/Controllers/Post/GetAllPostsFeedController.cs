
using ApiUrbanPlanning.Response;
using ApiUrbanPlanning.UseCase.Post;
using Microsoft.AspNetCore.Mvc;

namespace ApiUrbanPlanning.Controllers.Post
{
    [ApiController]
    [Route("api")]
    [Tags("Posts")]
    public class GetAllPostsFeedController : ControllerBase
    {
        private readonly GetAllPostsFeedUseCase _getAllPostsFeedUseCase;

        public GetAllPostsFeedController(GetAllPostsFeedUseCase getAllPostsFeedUseCase)
        {
            _getAllPostsFeedUseCase = getAllPostsFeedUseCase;
        }

        [HttpGet("posts/feed")]
        [ProducesResponseType(typeof(List<GetAllPostsFeedResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAllPostsFeeed(
            [FromQuery] int pageNumber,
            [FromQuery] int pageSize,
            [FromQuery] int? ibgeId)
        {
            var posts = await _getAllPostsFeedUseCase.Execute(pageNumber, pageSize, ibgeId);
            return Ok(posts);
        }
    }
}
