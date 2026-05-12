using apiUrbanPlanning.Infrastructure.Services;
using apiUrbanPlanning.Requests;
using apiUrbanPlanning.UseCase.Suggestions;
using ApiUrbanPlanning.Requests;
using ApiUrbanPlanning.UseCase.Post;
using Microsoft.AspNetCore.Mvc;

namespace ApiUrbanPlanning.Controllers.Post
{
    [ApiController]
    [Route("api")]
    [Tags("Posts")]
    public class CreatePostController : ControllerBase
    {
        private readonly CreatePostUseCase _createPostUseCase;
        private readonly CloudinaryService _cloudinaryService;

        public CreatePostController(CreatePostUseCase createPostUseCase, CloudinaryService cloudinaryService)
        {
            _createPostUseCase = createPostUseCase;
            _cloudinaryService = cloudinaryService;

        }

        [HttpPost("createPost")]
        [ProducesResponseType(StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> CreateSuggestion([FromForm] RequestCreatePost request)
        {

            try
            {
                var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");
                string imageUrl = string.Empty;

                if (request.File != null && request.File.Length > 0)
                {
                    imageUrl = await _cloudinaryService.UploadImageAsync(request.File, "post_images");
                }

                await _createPostUseCase.Execute(new RequestCreatePost
                {
                    Title = request.Title,
                    Description = request.Description,
                    Status = request.Status,
                    Number = request.Number,
                }, imageUrl, token);

                return StatusCode(201);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
