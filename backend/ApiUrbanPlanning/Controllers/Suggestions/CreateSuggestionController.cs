using apiUrbanPlanning.Infrastructure.Services;
using apiUrbanPlanning.Requests;
using apiUrbanPlanning.UseCase.Suggestions;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Controllers.Suggestions
{
    [ApiController]
    [Route("api")]
    [Tags("Suggestions")]
    public class CreateSuggestionController : ControllerBase
    {
        private readonly CreateSuggestionUseCase _createSuggestionUseCase;
        private readonly CloudinaryService _cloudinaryService;

        public CreateSuggestionController(CreateSuggestionUseCase createSuggestionUseCase, CloudinaryService cloudinaryService)
        {
            _createSuggestionUseCase = createSuggestionUseCase;
            _cloudinaryService = cloudinaryService;

        }

        [HttpPost("createSuggestion")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> CreateSuggestion([FromForm] RequestCreateSuggestion request)
        {
            try
            {
                var userIdClaim = User.FindFirst("id")?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
                {
                    return Unauthorized(new { message = "Token inválido ou usuário não identificado." });
                }

                string imageUrl = string.Empty;

                if (request.File != null && request.File.Length > 0)
                {
                    imageUrl = await _cloudinaryService.UploadImageAsync(request.File, "suggestions_images");
                }

                await _createSuggestionUseCase.Execute(new RequestSuggestion
                {
                    Type = request.Type,
                    Description = request.Description,
                    Latitude = request.Latitude,
                    Longitude = request.Longitude,
                    UserId = userId,
                    IbgeId = request.IbgeId
                }, imageUrl);

                return StatusCode(201);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

