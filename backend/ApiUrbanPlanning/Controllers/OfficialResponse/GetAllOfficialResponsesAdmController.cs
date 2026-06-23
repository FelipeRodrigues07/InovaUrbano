using apiUrbanPlanning.Infrastructure.Authorization;
using apiUrbanPlanning.Infrastructure.Constants;
using ApiUrbanPlanning.Response;
using ApiUrbanPlanning.UseCase.OfficialResponse;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ApiUrbanPlanning.Controllers.OfficialResponse
{
    [ApiController]
    [Route("api")]
    [Tags("OfficialResponses")]
    public class GetAllOfficialResponsesAdmController : ControllerBase
    {
        private readonly GetAllOfficialResponsesAdmUseCase _getAllOfficialResponsesAdmUseCase;

        public GetAllOfficialResponsesAdmController(GetAllOfficialResponsesAdmUseCase getAllOfficialResponsesAdmUseCase)
        {
            _getAllOfficialResponsesAdmUseCase = getAllOfficialResponsesAdmUseCase;
        }

        [HttpGet("official-responses/adm")]
        [Authorize(Roles = UserRoles.AdminPanel)]
        [ProducesResponseType(typeof(PaginatedAdmResponse<GetAllOfficialResponseAdmResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAllOfficialResponsesAdm(
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

            var responses = await _getAllOfficialResponsesAdmUseCase.Execute(
                NumberSuggestion ?? 0,
                Status ?? string.Empty,
                DateCalendar ?? string.Empty,
                effectiveIbgeId,
                pageNumber,
                pageSize);

            return Ok(responses);
        }
    }
}
