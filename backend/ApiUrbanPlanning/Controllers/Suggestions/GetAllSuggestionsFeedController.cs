using apiUrbanPlanning.Response;
using apiUrbanPlanning.UseCase.Suggestions;
using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Controllers.Suggestions
{
    [ApiController]
    [Route("api")]
    [Tags("Suggestions")]
    public class GetAllSuggestionsFeedController : ControllerBase
    {
        private readonly GetAllSuggestionsFeedUseCase _getAllSuggestionsFeedUseCase;

        public GetAllSuggestionsFeedController(GetAllSuggestionsFeedUseCase getAllSuggestionsFeedUseCase)
        {
            _getAllSuggestionsFeedUseCase = getAllSuggestionsFeedUseCase;
        }   

        [HttpGet("suggestions/feed")]
        [ProducesResponseType(typeof(List<GetAllSuggestionsFeedResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAllSuggestions(
            [FromQuery] int pageNumber,
            [FromQuery] int pageSize,
            [FromQuery] int? ibgeId)
        {
            var suggestions = await _getAllSuggestionsFeedUseCase.Execute(pageNumber, pageSize, ibgeId);
            return Ok(suggestions);
        }
    }
}

