namespace apiUrbanPlanning.Infrastructure.Models
{
    public class Suggestion
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Type { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string Status { get; set; } = "Pendente";
        public string SuggestionImageUrl { get; set; } = string.Empty;
        public int IbgeId { get; set; }
        public int Number { get; set; }
        public Guid UserId { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public DateTime? DeletedAt { get; set; }

        public User? User { get; set; }
    }
}
