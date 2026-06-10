using apiUrbanPlanning.Infrastructure.Authorization;
using apiUrbanPlanning.Infrastructure.Constants;
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
        [Authorize(Roles = UserRoles.AdminPanel)]
        [ProducesResponseType(typeof(SuggestionsAnalyticsResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAnalytics(
            [FromQuery] string? Status,
            [FromQuery] int? IbgeId,
            [FromQuery] string? DateFrom,
            [FromQuery] string? DateTo,
            [FromQuery] string? GroupBy)
        {
            var effectiveIbgeId = TenantIbgeResolver.ResolveEffectiveIbgeId(User, IbgeId);
            if (TenantIbgeResolver.RequiresTenantIbge(User) && effectiveIbgeId == null)
            {
                return Forbid();
            }

            var result = await _useCase.Execute(
                Status ?? string.Empty,
                effectiveIbgeId,
                DateFrom,
                DateTo,
                GroupBy ?? "month");

            return Ok(result);
        }
    }
}
