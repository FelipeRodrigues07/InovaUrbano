using ApiUrbanPlanning.Response;
using ApiUrbanPlanning.UseCase.Post;
using ApiUrbanPlanning.UseCase.Suggestions;
using Microsoft.AspNetCore.Mvc;

namespace ApiUrbanPlanning.Controllers.Post
{
    [ApiController]
    [Route("api")]
    [Tags("Posts")]
    public class GetAllPostAdmController : ControllerBase
    {
        private readonly GetAllPostAdmUseCase _getAllPostAdmUseCase;

        public GetAllPostAdmController(GetAllPostAdmUseCase getAllPostsAdmUseCase)
        {
            _getAllPostAdmUseCase = getAllPostsAdmUseCase;
        }

        [HttpGet("posts/adm")]
        [ProducesResponseType(typeof(List<GetAllPostAdmResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAllSuggestionsAdm(
            [FromQuery] int? NumberSuggestion,
            [FromQuery] string? DateCalendar,
            [FromQuery] int pageNumber,
            [FromQuery] int pageSize)
        {
            var posts = await _getAllPostAdmUseCase.Execute(
                NumberSuggestion ?? 0,
                DateCalendar ?? string.Empty,
                pageNumber,
                pageSize);
            return Ok(posts);
        }
    }
}
