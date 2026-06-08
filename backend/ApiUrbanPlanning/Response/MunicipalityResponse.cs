namespace apiUrbanPlanning.Response
{
    public class MunicipalityResponse
    {
        public Guid Id { get; set; }
        public int IbgeId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public string Slug { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime? ContractStartsAt { get; set; }
        public DateTime? ContractEndsAt { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
