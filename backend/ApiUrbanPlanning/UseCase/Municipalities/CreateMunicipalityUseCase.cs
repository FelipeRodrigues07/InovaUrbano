using System.Globalization;
using System.Text;
using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Requests;
using apiUrbanPlanning.Response;

namespace apiUrbanPlanning.UseCase.Municipalities
{
    public class CreateMunicipalityUseCase
    {
        private readonly InterfaceMunicipality _repository;

        public CreateMunicipalityUseCase(InterfaceMunicipality repository)
        {
            _repository = repository;
        }

        public async Task<MunicipalityResponse> Execute(RequestCreateMunicipality request)
        {
            if (request.IbgeId <= 0)
            {
                throw new Exception("IbgeId is required");
            }

            if (string.IsNullOrWhiteSpace(request.Name))
            {
                throw new Exception("Name is required");
            }

            if (string.IsNullOrWhiteSpace(request.State))
            {
                throw new Exception("State is required");
            }

            if (await _repository.ExistsByIbgeId(request.IbgeId))
            {
                throw new Exception("Municipality with this IbgeId already exists");
            }

            var state = request.State.Trim().ToUpperInvariant();
            var slug = GenerateSlug(request.Name, state);

            if (await _repository.ExistsBySlug(slug))
            {
                throw new Exception("Municipality slug already exists");
            }

            var municipality = new Municipality
            {
                IbgeId = request.IbgeId,
                Name = request.Name.Trim(),
                State = state,
                Slug = slug,
                IsActive = true,
                ContractStartsAt = request.ContractStartsAt,
                ContractEndsAt = request.ContractEndsAt,
                CreatedAt = DateTime.UtcNow
            };

            await _repository.Create(municipality);

            return MapToResponse(municipality);
        }

        internal static string GenerateSlug(string name, string state)
        {
            var normalizedName = RemoveDiacritics(name.Trim().ToLowerInvariant());
            normalizedName = new string(normalizedName
                .Select(c => char.IsLetterOrDigit(c) ? c : '-')
                .ToArray());

            while (normalizedName.Contains("--"))
            {
                normalizedName = normalizedName.Replace("--", "-");
            }

            normalizedName = normalizedName.Trim('-');
            return $"{normalizedName}-{state.ToLowerInvariant()}";
        }

        private static string RemoveDiacritics(string text)
        {
            var normalized = text.Normalize(NormalizationForm.FormD);
            var builder = new StringBuilder();

            foreach (var c in normalized)
            {
                if (CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
                {
                    builder.Append(c);
                }
            }

            return builder.ToString().Normalize(NormalizationForm.FormC);
        }

        internal static MunicipalityResponse MapToResponse(Municipality municipality)
        {
            return new MunicipalityResponse
            {
                Id = municipality.Id,
                IbgeId = municipality.IbgeId,
                Name = municipality.Name,
                State = municipality.State,
                Slug = municipality.Slug,
                IsActive = municipality.IsActive,
                ContractStartsAt = municipality.ContractStartsAt,
                ContractEndsAt = municipality.ContractEndsAt,
                CreatedAt = municipality.CreatedAt,
                UpdatedAt = municipality.UpdatedAt
            };
        }
    }
}
