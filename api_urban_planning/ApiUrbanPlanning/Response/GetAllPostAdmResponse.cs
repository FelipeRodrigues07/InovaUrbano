namespace ApiUrbanPlanning.Response
{
    public class GetAllPostAdmResponse
    {
        public Guid Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Status { get; set; }
        public string PostImageUrl { get; set; }
        public Guid UserId { get; set; }
        public int Number { get; set; }
        public int NumberSuggestion { get; set; }   
        public DateTime CreatedAt { get; set; }
        // user
        public string UserName { get; set; }
        public string ProfilePictureUrl { get; set; }
    }
}
