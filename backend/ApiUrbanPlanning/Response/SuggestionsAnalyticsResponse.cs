namespace ApiUrbanPlanning.Response
{
    public class SuggestionsAnalyticsResponse
    {
        public AnalyticsSummary Summary { get; set; } = new();
        public List<TimeSeriesPoint> TimeSeries { get; set; } = new();
        public List<CountByLabel> ByStatus { get; set; } = new();
        public List<CountByLabel> ByType { get; set; } = new();
    }

    public class AnalyticsSummary
    {
        public int Total { get; set; }
    }

    public class TimeSeriesPoint
    {
        public string Period { get; set; } = string.Empty;
        public int Count { get; set; }
    }

    public class CountByLabel
    {
        public string Label { get; set; } = string.Empty;
        public int Count { get; set; }
    }
}
