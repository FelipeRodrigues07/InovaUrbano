using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Response;

namespace ApiUrbanPlanning.UseCase.OfficialResponse
{
    public class GetAllOfficialResponsesAdmUseCase
    {
        private readonly InterfaceOfficialResponse _repository;
        private readonly InterfaceUser _userRepository;
        private readonly InterfaceSuggestion _suggestionRepository;

        public GetAllOfficialResponsesAdmUseCase(
            InterfaceOfficialResponse repository,
            InterfaceUser userRepository,
            InterfaceSuggestion suggestionRepository)
        {
            _repository = repository;
            _userRepository = userRepository;
            _suggestionRepository = suggestionRepository;
        }

        public async Task<PaginatedAdmResponse<GetAllOfficialResponseAdmResponse>> Execute(
            int numberSuggestion,
            string status,
            string dateCalendar,
            int? ibgeId,
            int pageNumber,
            int pageSize)
        {
            DateTime? selectedDate = string.IsNullOrEmpty(dateCalendar)
                ? null
                : DateTime.SpecifyKind(DateTime.Parse(dateCalendar), DateTimeKind.Utc);

            var (responses, total) = await _repository.GetAllOfficialResponsesAdm(
                numberSuggestion, status, selectedDate, ibgeId, pageNumber, pageSize);

            var responsesDto = new List<GetAllOfficialResponseAdmResponse>();

            foreach (var response in responses)
            {
                var user = await _userRepository.GetUserById(response.UserId);
                var suggestion = await _suggestionRepository.GetSuggestionById(response.SuggestionId);

                responsesDto.Add(new GetAllOfficialResponseAdmResponse
                {
                    Id = response.Id,
                    Title = response.Title,
                    Description = response.Description,
                    Status = suggestion?.Status ?? string.Empty,
                    UserId = response.UserId,
                    PostImageUrl = response.PostImageUrl,
                    Number = response.Number,
                    NumberSuggestion = response.NumberSuggestion,
                    CreatedAt = response.CreatedAt,
                    UserName = user?.Name ?? string.Empty,
                    ProfilePictureUrl = user?.ProfilePictureUrl ?? string.Empty,
                });
            }

            return new PaginatedAdmResponse<GetAllOfficialResponseAdmResponse>
            {
                Data = responsesDto,
                Meta = PaginationMeta.Create(pageNumber, pageSize, total),
            };
        }
    }
}
