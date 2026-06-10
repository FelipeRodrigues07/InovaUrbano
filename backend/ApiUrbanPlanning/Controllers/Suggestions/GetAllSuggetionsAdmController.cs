using apiUrbanPlanning.Infrastructure.Authorization;
using apiUrbanPlanning.Infrastructure.Constants;
using apiUrbanPlanning.Response;
using ApiUrbanPlanning.Response;
using ApiUrbanPlanning.UseCase.Suggestions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ApiUrbanPlanning.Controllers.Suggestions
{
    [ApiController]
    [Route("api")]
    [Tags("Suggestions")]
    public class GetAllSuggetionsAdmController : ControllerBase
    {
        private readonly GetAllSuggestionsAdmUseCase _getAllSuggestionsAdmUseCase;

        public GetAllSuggetionsAdmController(GetAllSuggestionsAdmUseCase getAllSuggestionsAdmUseCase)
        {
            _getAllSuggestionsAdmUseCase = getAllSuggestionsAdmUseCase;
        }

        [HttpGet("suggestions/adm")]
        [Authorize(Roles = UserRoles.AdminPanel)]
        [ProducesResponseType(typeof(PaginatedAdmResponse<GetAllSuggestionsAdmResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAllSuggestionsAdm(
            [FromQuery] int? NumberSuggestion,
            [FromQuery] string? Status,
            [FromQuery] string? DateCalendar,
            [FromQuery] int? IbgeId,
            [FromQuery] int pageNumber,
            [FromQuery] int pageSize)
        {
            var effectiveIbgeId = TenantIbgeResolver.ResolveEffectiveIbgeId(User, IbgeId);
            if (TenantIbgeResolver.RequiresTenantIbge(User) && effectiveIbgeId == null)
            {
                return Forbid();
            }

            var suggestions = await _getAllSuggestionsAdmUseCase.Execute(
                Status ?? string.Empty,
                NumberSuggestion ?? 0,
                DateCalendar ?? string.Empty,
                effectiveIbgeId,
                pageNumber,
                pageSize);
            return Ok(suggestions);
        }
    }
}
