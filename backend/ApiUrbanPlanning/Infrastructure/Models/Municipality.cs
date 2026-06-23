namespace apiUrbanPlanning.Infrastructure.Models
{
    public class Municipality
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public int IbgeId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string Slug { get; set; } = string.Empty;
        public bool IsActive { get; set; } = true;
        public DateTime? ContractStartsAt { get; set; }
        public DateTime? ContractEndsAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public DateTime? DeletedAt { get; set; }

        public ICollection<User> Users { get; set; } = new List<User>();
    }
}
