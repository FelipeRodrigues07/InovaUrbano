using apiUrbanPlanning.Requests;
using apiUrbanPlanning.Response;
using apiUrbanPlanning.UseCase.Users;
using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Controllers.User
{
    [ApiController]
    [Route("api")]
    [Tags("Account")]
    public class CreateAccountController : ControllerBase
    {
        private readonly CreateAccountUseCase _createAccountUseCase;


        public CreateAccountController(CreateAccountUseCase createAccountUseCase)
        {
            _createAccountUseCase = createAccountUseCase;
        }

        [HttpPost("register")]
        [ProducesResponseType(typeof(RegisterUserResponse), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<IActionResult> Register([FromBody] RequestUser request)
        {
            try
            {
                var response = await _createAccountUseCase.Execute(request);
                return CreatedAtAction(nameof(Register), new { id = response.Id }, response);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }


        }
    }
}

