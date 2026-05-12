using Microsoft.AspNetCore.Mvc;
using apiUrbanPlanning.UseCase.Users;
using Microsoft.AspNetCore.Authorization;

namespace apiUrbanPlanning.Controllers.User
{
    [ApiController]
    [Route("api")]
    [Tags("User")]
    public class DeletePictureProfileController : ControllerBase
    {
        private readonly DeleteProfilePictureUseCase _deleteProfilePictureUseCase;

        public DeletePictureProfileController(DeleteProfilePictureUseCase deleteProfilePictureUseCase)
        {
            _deleteProfilePictureUseCase = deleteProfilePictureUseCase;
        }


        [HttpDelete("delete")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> DeleteProfilePicture()
        {
            var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");

            try
            {
                await _deleteProfilePictureUseCase.Execute(token);
                return Ok(new { message = "Profile picture deleted successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

    }
}

