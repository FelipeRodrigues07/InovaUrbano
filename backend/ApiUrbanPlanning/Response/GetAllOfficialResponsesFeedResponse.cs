namespace ApiUrbanPlanning.Response
{
    public class GetAllOfficialResponsesFeedResponse
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public Guid UserId { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public int NumberSuggestion { get; set; }
        public int? SuggestionIbgeId { get; set; }
        public string SuggestionType { get; set; } = string.Empty;
        public string StatusAtPublish { get; set; } = string.Empty;
        public string SuggestionStatus { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string ProfilePictureUrl { get; set; } = string.Empty;
    }
}
