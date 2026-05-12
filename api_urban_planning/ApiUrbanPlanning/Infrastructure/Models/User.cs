namespace apiUrbanPlanning.Infrastructure.Models
{
    public class User
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Name { get; set; } = string.Empty;  //string vazia 
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;

        public string ProfilePictureUrl {  get; set; } = string.Empty;
        public string Role { get; set; } = "member";
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;


        // Relação um-para-muitos: Um usuário pode ter muitas sugestões
        public ICollection<Suggestion> Suggestions { get; set; } = new List<Suggestion>();
    }
}
