using ApiUrbanPlanning.Requests;
using ApiUrbanPlanning.UseCase.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace ApiUrbanPlanning.Controllers.User
{
    [ApiController]
    [Route("api")]
    [Tags("User")]
    public class UpdateNameController : ControllerBase
    {
        private readonly UpdateNameUseCase _updateNameUseCase;

        public UpdateNameController(UpdateNameUseCase updateNameUseCase)
        {
            _updateNameUseCase = updateNameUseCase;
        }

        [HttpPut("update/name")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> UpdateEmail([FromBody] RequestNameUpdate request)
        {
            try
            {
                var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");
                await _updateNameUseCase.Execute(token, request);
                return Ok("Nome atualizado com sucesso.");
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (FormatException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, "Ocorreu um erro interno.");
            }
        }
    }
}

