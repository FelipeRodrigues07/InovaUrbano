using apiUrbanPlanning.Response;
using apiUrbanPlanning.UseCase.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Controllers.User
{
    [ApiController]
    [Route("api")]
    [Tags("User")]
    public class ProfileController : ControllerBase
    {
        private readonly ProfileUseCase _profileUseCase;

        public ProfileController(ProfileUseCase profileUseCase)
        {
            _profileUseCase = profileUseCase;
        }

        [HttpGet("Profile")]
        [Authorize]
        [ProducesResponseType(typeof(ProfileResponse), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                // Extrai o token JWT do cabeçalho Authorization
                var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");

                var profile = await _profileUseCase.Execute(token);
                return Ok(profile);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (System.Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

