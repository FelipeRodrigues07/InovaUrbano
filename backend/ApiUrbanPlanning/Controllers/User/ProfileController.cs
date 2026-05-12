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
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                // Extrai o token JWT do cabeçalho Authorization
                var token = Request.Headers["Authorization"].ToString().Replace("Bearer ", "");

                // Chama o caso de uso para buscar o perfil do usuário
                var user = await _profileUseCase.Execute(token);

                // Retorna os dados do perfil do usuário
                return Ok(new
                {
                    Id = user.Id,
                    Name = user.Name,
                    Email = user.Email,
                    ProfilePictureUrl = user.ProfilePictureUrl
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
            catch (System.Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

