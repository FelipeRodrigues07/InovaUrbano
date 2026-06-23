using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Requests;
using apiUrbanPlanning.Response;

namespace apiUrbanPlanning.UseCase.Municipalities
{
    public class UpdateMunicipalityUseCase
    {
        private readonly InterfaceMunicipality _repository;

        public UpdateMunicipalityUseCase(InterfaceMunicipality repository)
        {
            _repository = repository;
        }

        public async Task<MunicipalityResponse> Execute(Guid id, RequestUpdateMunicipality request)
        {
            var municipality = await _repository.GetById(id);
            if (municipality == null)
            {
                throw new KeyNotFoundException("Municipality not found");
            }

            var hasChanges = false;

            if (!string.IsNullOrWhiteSpace(request.Name))
            {
                municipality.Name = request.Name.Trim();
                hasChanges = true;
            }

            if (!string.IsNullOrWhiteSpace(request.State))
            {
                municipality.State = request.State.Trim().ToUpperInvariant();
                hasChanges = true;
            }

            if (request.IsActive.HasValue)
            {
                municipality.IsActive = request.IsActive.Value;
                hasChanges = true;
            }

            if (request.ContractStartsAt.HasValue)
            {
                municipality.ContractStartsAt = request.ContractStartsAt;
                hasChanges = true;
            }

            if (request.ContractEndsAt.HasValue)
            {
                municipality.ContractEndsAt = request.ContractEndsAt;
                hasChanges = true;
            }

            if (!hasChanges)
            {
                throw new Exception("No fields to update");
            }

            if (!string.IsNullOrWhiteSpace(request.Name) || !string.IsNullOrWhiteSpace(request.State))
            {
                var slug = CreateMunicipalityUseCase.GenerateSlug(municipality.Name, municipality.State);

                if (await _repository.ExistsBySlugExceptId(slug, municipality.Id))
                {
                    throw new Exception("Municipality slug already exists");
                }

                municipality.Slug = slug;
            }

            await _repository.Update(municipality);

            return CreateMunicipalityUseCase.MapToResponse(municipality);
        }
    }
}
