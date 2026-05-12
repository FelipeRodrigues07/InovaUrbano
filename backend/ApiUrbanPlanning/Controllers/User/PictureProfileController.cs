using apiUrbanPlanning.Requests;
using apiUrbanPlanning.UseCase.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Swashbuckle.AspNetCore.Annotations;

namespace apiUrbanPlanning.Controllers.User
{
    [ApiController]
    [Route("api")]
    [Tags("User")]
    public class PictureProfileController : ControllerBase
    {

        private readonly CreateProfilePictureUseCase _createProfilePictureUseCase;

        public PictureProfileController(CreateProfilePictureUseCase createProfilePictureUseCase)
        {
            _createProfilePictureUseCase = createProfilePictureUseCase;
        }



        [HttpPost("upload")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        
        public async Task<IActionResult> UploadProfilePicture([FromForm] RequestPictureProfile request)
        {
            if (request.File == null || request.File.Length == 0)
            {
              
                return BadRequest(new { message = "File not selected" });
            }

            var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");
            try
            {
                var imageUrl = await _createProfilePictureUseCase.Execute(token, request.File);
                return Ok(new { imageUrl });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }


    }
}

