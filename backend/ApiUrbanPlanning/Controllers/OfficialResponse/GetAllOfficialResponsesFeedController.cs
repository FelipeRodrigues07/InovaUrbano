using ApiUrbanPlanning.Response;
using ApiUrbanPlanning.UseCase.OfficialResponse;
using Microsoft.AspNetCore.Mvc;

namespace ApiUrbanPlanning.Controllers.OfficialResponse
{
    [ApiController]
    [Route("api")]
    [Tags("OfficialResponses")]
    public class GetAllOfficialResponsesFeedController : ControllerBase
    {
        private readonly GetAllOfficialResponsesFeedUseCase _getAllOfficialResponsesFeedUseCase;

        public GetAllOfficialResponsesFeedController(GetAllOfficialResponsesFeedUseCase getAllOfficialResponsesFeedUseCase)
        {
            _getAllOfficialResponsesFeedUseCase = getAllOfficialResponsesFeedUseCase;
        }

        [HttpGet("official-responses/feed")]
        [ProducesResponseType(typeof(List<GetAllOfficialResponsesFeedResponse>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<IActionResult> GetAllOfficialResponsesFeed(
            [FromQuery] int pageNumber,
            [FromQuery] int pageSize,
            [FromQuery] int? ibgeId)
        {
            var responses = await _getAllOfficialResponsesFeedUseCase.Execute(pageNumber, pageSize, ibgeId);
            return Ok(responses);
        }
    }
}
