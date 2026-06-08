using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Response;

namespace apiUrbanPlanning.UseCase.Municipalities
{
    public class GetAllMunicipalitiesUseCase
    {
        private readonly InterfaceMunicipality _repository;

        public GetAllMunicipalitiesUseCase(InterfaceMunicipality repository)
        {
            _repository = repository;
        }

        public async Task<List<MunicipalityResponse>> Execute()
        {
            var municipalities = await _repository.GetAll();

            return municipalities
                .Select(CreateMunicipalityUseCase.MapToResponse)
                .ToList();
        }
    }
}
