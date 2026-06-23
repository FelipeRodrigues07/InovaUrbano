namespace ApiUrbanPlanning.Response
{
    public class GetAllOfficialResponseAdmResponse
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string StatusAtPublish { get; set; } = string.Empty;
        public string ImageUrl { get; set; } = string.Empty;
        public Guid UserId { get; set; }
        public int Number { get; set; }
        public int NumberSuggestion { get; set; }
        public DateTime CreatedAt { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string ProfilePictureUrl { get; set; } = string.Empty;
    }
}
