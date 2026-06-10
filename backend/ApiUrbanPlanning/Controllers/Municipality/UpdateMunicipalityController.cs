using apiUrbanPlanning.Infrastructure.Constants;
using apiUrbanPlanning.Requests;
using apiUrbanPlanning.Response;
using apiUrbanPlanning.UseCase.Municipalities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Controllers.Municipality
{
    [ApiController]
    [Route("api")]
    [Tags("Municipalities")]
    public class UpdateMunicipalityController : ControllerBase
    {
        private readonly UpdateMunicipalityUseCase _updateMunicipalityUseCase;

        public UpdateMunicipalityController(UpdateMunicipalityUseCase updateMunicipalityUseCase)
        {
            _updateMunicipalityUseCase = updateMunicipalityUseCase;
        }

        [HttpPatch("municipalities/{id:guid}")]
        [Authorize(Roles = UserRoles.SuperAdmin)]
        [ProducesResponseType(typeof(MunicipalityResponse), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> Update(Guid id, [FromBody] RequestUpdateMunicipality request)
        {
            try
            {
                var response = await _updateMunicipalityUseCase.Execute(id, request);
                return Ok(response);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (Exception ex) when (ex.Message.Contains("already exists"))
            {
                return Conflict(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}
