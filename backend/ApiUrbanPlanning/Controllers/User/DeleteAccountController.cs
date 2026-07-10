using apiUrbanPlanning.Requests;
using apiUrbanPlanning.UseCase.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Controllers.User
{
    [ApiController]
    [Route("api")]
    [Tags("User")]
    public class DeleteAccountController : ControllerBase
    {
        private readonly DeleteAccountUseCase _deleteAccountUseCase;

        public DeleteAccountController(DeleteAccountUseCase deleteAccountUseCase)
        {
            _deleteAccountUseCase = deleteAccountUseCase;
        }

        /// <summary>
        /// Exclusão autenticada (app mobile / sessão logada).
        /// </summary>
        [HttpDelete("account")]
        [Authorize]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> DeleteAccount()
        {
            var token = Request.Headers.Authorization.ToString()
                .Replace("Bearer ", "", StringComparison.Ordinal);

            try
            {
                await _deleteAccountUseCase.ExecuteFromToken(token);
                return Ok(new
                {
                    message = "Conta excluída com sucesso. Dados pessoais foram removidos; relatos públicos permanecem anônimos."
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Exclusão pública por e-mail + senha (página web exigida pela Play Store).
        /// </summary>
        [HttpPost("account/delete")]
        [AllowAnonymous]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> DeleteAccountByCredentials([FromBody] RequestDeleteAccount request)
        {
            try
            {
                await _deleteAccountUseCase.ExecuteFromCredentials(request);
                return Ok(new
                {
                    message = "Se a conta existir e as credenciais estiverem corretas, ela foi excluída. Dados pessoais foram removidos; relatos públicos permanecem anônimos."
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
