using apiUrbanPlanning.Requests;
using apiUrbanPlanning.Response;
using apiUrbanPlanning.UseCase.Users;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Win32;

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
                var response = await _authenticateUseCase.Execute(request);

                return Ok(new AuthenticateUserResponse
                {
                    Id = response.Id,
                    Name = response.Name,
                    Email = response.Email,
                    Token = response.Token
                });

            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });

            }
        }
    }
}
