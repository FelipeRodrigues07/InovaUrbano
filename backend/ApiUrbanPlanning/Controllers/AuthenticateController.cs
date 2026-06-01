using apiUrbanPlanning.Requests;
using apiUrbanPlanning.Response;
using apiUrbanPlanning.UseCase.Users;
using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Controllers
{
    [ApiController]
    [Route("api")]
    [Tags("Auth")]
    public class AuthenticateController : ControllerBase
    {
        private readonly AuthenticateUseCase _authenticateUseCase;

        public AuthenticateController(AuthenticateUseCase authenticateUseCase)
        {
            _authenticateUseCase = authenticateUseCase;
        }

        [HttpPost("authenticate")]
        [ProducesResponseType(typeof(AuthenticateUserResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Authenticate([FromBody] RequestAuthenticate request)
        {
            try
            {
                return Ok(await _authenticateUseCase.Execute(request));
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("refresh")]
        [ProducesResponseType(typeof(AuthenticateUserResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Refresh([FromBody] RequestRefreshToken request)
        {
            try
            {
                return Ok(await _authenticateUseCase.Refresh(request.RefreshToken));
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("logout")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        public async Task<IActionResult> Logout([FromBody] RequestRefreshToken? request)
        {
            await _authenticateUseCase.Revoke(request?.RefreshToken);
            return NoContent();
        }
    }
}
