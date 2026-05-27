namespace ApiUrbanPlanning.Response
{
    public class GetAllPostsFeedResponse
    {
        public Guid Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public Guid UserId { get; set; }
        public string PostImageUrl { get; set; }
        public DateTime CreatedAt { get; set; }
        public int NumberSuggestion { get; set; }
        public int? SuggestionIbgeId { get; set; }
        public string SuggestionType { get; set; }
        public string SuggestionStatus { get; set; }

        // user
        public string UserName { get; set; }
        public string ProfilePictureUrl { get; set; }
    }
}
