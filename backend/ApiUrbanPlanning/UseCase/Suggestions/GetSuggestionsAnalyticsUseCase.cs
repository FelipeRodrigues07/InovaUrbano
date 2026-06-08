using apiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.Response;

namespace ApiUrbanPlanning.UseCase.Suggestions
{
    public class GetSuggestionsAnalyticsUseCase
    {
        private readonly InterfaceSuggestion _repository;

        public GetSuggestionsAnalyticsUseCase(InterfaceSuggestion repository)
        {
            _repository = repository;
        }

        public async Task<SuggestionsAnalyticsResponse> Execute(
            string status,
            int? ibgeId,
            string? dateFrom,
            string? dateTo,
            string groupBy)
        {
            var parsedDateFrom = ParseDate(dateFrom);
            var parsedDateTo = ParseDate(dateTo);
            var normalizedGroupBy = NormalizeGroupBy(groupBy);

            var data = await _repository.GetSuggestionsAnalytics(
                status,
                ibgeId,
                parsedDateFrom,
                parsedDateTo,
                normalizedGroupBy);

            return new SuggestionsAnalyticsResponse
            {
                Summary = new AnalyticsSummary { Total = data.Total },
                TimeSeries = data.TimeSeries.Select(x => new TimeSeriesPoint
                {
                    Period = x.Period,
                    Count = x.Count,
                }).ToList(),
                ByStatus = data.ByStatus.Select(x => new CountByLabel
                {
                    Label = x.Label,
                    Count = x.Count,
                }).ToList(),
                ByType = data.ByType.Select(x => new CountByLabel
                {
                    Label = x.Label,
                    Count = x.Count,
                }).ToList(),
            };
        }

        private static DateTime? ParseDate(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return null;
            }

            return DateTime.SpecifyKind(DateTime.Parse(value), DateTimeKind.Utc);
        }

        private static string NormalizeGroupBy(string? groupBy)
        {
            return groupBy?.ToLowerInvariant() switch
            {
                "day" => "day",
                "year" => "year",
                _ => "month",
            };
        }
    }
}
