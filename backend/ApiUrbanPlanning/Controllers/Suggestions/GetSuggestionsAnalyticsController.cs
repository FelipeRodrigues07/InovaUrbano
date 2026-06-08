using ApiUrbanPlanning.Response;
using ApiUrbanPlanning.UseCase.Suggestions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ApiUrbanPlanning.Controllers.Suggestions
{
    [ApiController]
    [Route("api")]
    [Tags("Suggestions")]
    public class GetSuggestionsAnalyticsController : ControllerBase
    {
        private readonly GetSuggestionsAnalyticsUseCase _useCase;

        public GetSuggestionsAnalyticsController(GetSuggestionsAnalyticsUseCase useCase)
        {
            _useCase = useCase;
        }

        [HttpGet("suggestions/analytics")]
        [Authorize]
        [ProducesResponseType(typeof(SuggestionsAnalyticsResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAnalytics(
            [FromQuery] string? Status,
            [FromQuery] int? IbgeId,
            [FromQuery] string? DateFrom,
            [FromQuery] string? DateTo,
            [FromQuery] string? GroupBy)
        {
            var result = await _useCase.Execute(
                Status ?? string.Empty,
                IbgeId,
                DateFrom,
                DateTo,
                GroupBy ?? "month");

            return Ok(result);
        }
    }
}
