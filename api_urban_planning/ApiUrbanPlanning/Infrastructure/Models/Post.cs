namespace ApiUrbanPlanning.Infrastructure.Models
{
    public class Post
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Title { get; set; } = string.Empty; // Tipo de sugestão
        public string Description { get; set; } = string.Empty;
        public string PostImageUrl { get; set; } = string.Empty;
        public int NumberSuggestion { get; set; }
        public  Guid SuggestionId { get; set; }
        public Guid UserId { get; set; }
        public int Number { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
