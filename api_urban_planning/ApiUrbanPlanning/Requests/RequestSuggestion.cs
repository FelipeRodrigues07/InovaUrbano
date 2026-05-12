namespace apiUrbanPlanning.Requests
{
    public class RequestSuggestion
    {
        public string Type { get; set; } = string.Empty; // Tipo de sugestão
        public string Description { get; set; } = string.Empty;
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public Guid UserId { get; set; }
        public int? IbgeId { get; set; }
    }
}
