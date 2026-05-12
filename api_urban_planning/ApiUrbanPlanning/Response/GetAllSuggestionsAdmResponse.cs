namespace ApiUrbanPlanning.Response
{
    public class GetAllSuggestionsAdmResponse
    {
        public Guid Id { get; set; }
        public string Type { get; set; }
        public string Description { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string Status { get; set; }
        public string SuggestionImageUrl { get; set; }
        public Guid UserId { get; set; }
        public  int Number {  get; set; }
        public DateTime CreatedAt { get; set; }
        // user
        public string UserName { get; set; }
        public string ProfilePictureUrl { get; set; }
    }
}
