namespace ApiUrbanPlanning.Requests
{
    public class RequestPasswordUpdate
    {
        public string OldPassword { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }
}
