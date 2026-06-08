using apiUrbanPlanning.Infrastructure.Constants;

namespace apiUrbanPlanning.Infrastructure.Models
{
    public class User
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public string Name { get; set; } = string.Empty;  //string vazia 
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;

        public string ProfilePictureUrl {  get; set; } = string.Empty;
        public string Role { get; set; } = UserRoles.Member;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public string? RefreshToken { get; set; }
        public DateTime? RefreshTokenExpiresAt { get; set; }

        public Guid? MunicipalityId { get; set; }
        public Municipality? Municipality { get; set; }

        // Relação um-para-muitos: Um usuário pode ter muitas sugestões
        public ICollection<Suggestion> Suggestions { get; set; } = new List<Suggestion>();
    }
}
