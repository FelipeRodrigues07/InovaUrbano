namespace apiUrbanPlanning.Requests
{
    public class RequestCreateMunicipality
    {
        public int IbgeId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string State { get; set; } = string.Empty;
        public DateTime? ContractStartsAt { get; set; }
        public DateTime? ContractEndsAt { get; set; }
    }
}
