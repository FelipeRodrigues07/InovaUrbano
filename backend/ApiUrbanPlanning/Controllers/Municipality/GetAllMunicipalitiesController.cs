using apiUrbanPlanning.Infrastructure.Constants;
using apiUrbanPlanning.Response;
using apiUrbanPlanning.UseCase.Municipalities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Controllers.Municipality
{
    [ApiController]
    [Route("api")]
    [Tags("Municipalities")]
    public class GetAllMunicipalitiesController : ControllerBase
    {
        private readonly GetAllMunicipalitiesUseCase _getAllMunicipalitiesUseCase;

        public GetAllMunicipalitiesController(GetAllMunicipalitiesUseCase getAllMunicipalitiesUseCase)
        {
            _getAllMunicipalitiesUseCase = getAllMunicipalitiesUseCase;
        }

        [HttpGet("municipalities")]
        [Authorize(Roles = UserRoles.SuperAdmin)]
        [ProducesResponseType(typeof(List<MunicipalityResponse>), StatusCodes.Status200OK)]
        public async Task<IActionResult> GetAll()
        {
            var municipalities = await _getAllMunicipalitiesUseCase.Execute();
            return Ok(municipalities);
        }
    }
}
