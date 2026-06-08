namespace apiUrbanPlanning.Requests
{
    public class RequestUpdateMunicipality
    {
        public string? Name { get; set; }
        public string? State { get; set; }
        public bool? IsActive { get; set; }
        public DateTime? ContractStartsAt { get; set; }
        public DateTime? ContractEndsAt { get; set; }
    }
}
