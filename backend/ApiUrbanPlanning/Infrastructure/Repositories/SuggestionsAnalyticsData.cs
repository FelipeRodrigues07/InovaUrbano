namespace apiUrbanPlanning.Infrastructure.Repositories
{
    public class SuggestionsAnalyticsData
    {
        public int Total { get; set; }
        public List<AnalyticsTimeSeriesItem> TimeSeries { get; set; } = new();
        public List<AnalyticsCountItem> ByStatus { get; set; } = new();
        public List<AnalyticsCountItem> ByType { get; set; } = new();
    }

    public class AnalyticsTimeSeriesItem
    {
        public string Period { get; set; } = string.Empty;
        public int Count { get; set; }
    }

    public class AnalyticsCountItem
    {
        public string Label { get; set; } = string.Empty;
        public int Count { get; set; }
    }
}
