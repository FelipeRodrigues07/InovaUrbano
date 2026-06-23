using apiUrbanPlanning.Infrastructure.Services;
using ApiUrbanPlanning.Requests;
using ApiUrbanPlanning.UseCase.OfficialResponse;
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
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> CreateOfficialResponse([FromForm] RequestCreateOfficialResponse request)
        {
            try
            {
                var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");
                var imageUrl = string.Empty;

                if (request.File != null && request.File.Length > 0)
                {
                    imageUrl = await _cloudinaryService.UploadImageAsync(request.File, "post_images");
                }

                await _createOfficialResponseUseCase.Execute(request, imageUrl, token);

                return StatusCode(201);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
