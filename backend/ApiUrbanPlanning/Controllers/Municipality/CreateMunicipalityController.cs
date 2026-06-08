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
    public class CreateMunicipalityController : ControllerBase
    {
        private readonly CreateMunicipalityUseCase _createMunicipalityUseCase;

        public CreateMunicipalityController(CreateMunicipalityUseCase createMunicipalityUseCase)
        {
            _createMunicipalityUseCase = createMunicipalityUseCase;
        }

        [HttpPost("municipalities")]
        [Authorize]
        [ProducesResponseType(typeof(MunicipalityResponse), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> Create([FromBody] RequestCreateMunicipality request)
        {
            try
            {
                var response = await _createMunicipalityUseCase.Execute(request);
                return CreatedAtAction(nameof(Create), new { id = response.Id }, response);
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
