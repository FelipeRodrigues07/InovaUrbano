using apiUrbanPlanning.Response;
using apiUrbanPlanning.UseCase.Suggestions;
using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Controllers.Suggestions
{
    [ApiController]
    [Route("api")]
    [Tags("Suggestions")]
    public class GetAllSuggestionsByAreaController : ControllerBase
    {
        private readonly GetAllSuggestionsByAreaUseCase _getAllSuggestionsUseCase;

        public GetAllSuggestionsByAreaController(GetAllSuggestionsByAreaUseCase getAllSuggestionsUseCase)
        {
            _getAllSuggestionsUseCase = getAllSuggestionsUseCase;
        }

        [HttpGet("suggestions/area")]
        [ProducesResponseType(typeof(List<getAllSuggestionResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAllSuggestions(
            [FromQuery] double latMin,
            [FromQuery] double latMax,
            [FromQuery] double lonMin,
            [FromQuery] double lonMax,
            [FromQuery] string? Status
        )
        {
            var statusFilter = string.IsNullOrEmpty(Status) ? "Todas" : Status;
            var suggestions = await _getAllSuggestionsUseCase.Execute(latMin, latMax, lonMin, lonMax, statusFilter); 
            return Ok(suggestions); 
        }
    }
}

