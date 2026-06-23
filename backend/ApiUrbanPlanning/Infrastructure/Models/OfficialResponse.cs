namespace ApiUrbanPlanning.Infrastructure.Models
{
    public class OfficialResponse
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string ImageUrl { get; set; } = string.Empty;
        public string StatusAtPublish { get; set; } = string.Empty;
        public int NumberSuggestion { get; set; }
        public Guid SuggestionId { get; set; }
        public Guid UserId { get; set; }
        public int Number { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public DateTime? DeletedAt { get; set; }
    }
}
