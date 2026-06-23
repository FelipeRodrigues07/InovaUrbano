using apiUrbanPlanning.Infrastructure.Authorization;
using apiUrbanPlanning.Infrastructure.Constants;
using apiUrbanPlanning.Infrastructure.Services;
using ApiUrbanPlanning.Requests;
using ApiUrbanPlanning.UseCase.OfficialResponse;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ApiUrbanPlanning.Controllers.OfficialResponse
{
    [ApiController]
    [Route("api")]
    [Tags("OfficialResponses")]
    public class CreateOfficialResponseController : ControllerBase
    {
        private readonly CreateOfficialResponseUseCase _createOfficialResponseUseCase;
        private readonly CloudinaryService _cloudinaryService;

        public CreateOfficialResponseController(
            CreateOfficialResponseUseCase createOfficialResponseUseCase,
            CloudinaryService cloudinaryService)
        {
            _createOfficialResponseUseCase = createOfficialResponseUseCase;
            _cloudinaryService = cloudinaryService;
        }

        [HttpPost("official-responses")]
        [Authorize(Roles = UserRoles.AdminPanel)]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> CreateOfficialResponse([FromForm] RequestCreateOfficialResponse request)
        {
            try
            {
                var effectiveIbgeId = TenantIbgeResolver.ResolveEffectiveIbgeId(User, request.IbgeId);
                if (effectiveIbgeId == null || effectiveIbgeId.Value <= 0)
                {
                    return BadRequest(new { message = "IbgeId is required for this operation." });
                }

                var token = Request.Headers.Authorization.ToString().Replace("Bearer ", "", StringComparison.Ordinal);
                var imageUrl = string.Empty;

                if (request.File != null && request.File.Length > 0)
                {
                    imageUrl = await _cloudinaryService.UploadImageAsync(request.File, "official_responses");
                }

                await _createOfficialResponseUseCase.Execute(
                    request,
                    imageUrl,
                    token,
                    effectiveIbgeId.Value);

                return StatusCode(201);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
