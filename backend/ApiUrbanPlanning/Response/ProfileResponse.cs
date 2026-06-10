namespace apiUrbanPlanning.Response
{
    public class ProfileResponse
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string ProfilePictureUrl { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public Guid? MunicipalityId { get; set; }
        public int? IbgeId { get; set; }
        public string? MunicipalityName { get; set; }
        public string? MunicipalityState { get; set; }
    }
}
