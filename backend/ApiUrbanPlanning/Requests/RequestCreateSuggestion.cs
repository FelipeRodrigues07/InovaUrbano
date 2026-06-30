using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Requests
{
    public class RequestCreateSuggestion
    {
        public string Type { get; set; } = string.Empty; 
        public string Description { get; set; } = string.Empty;
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        [FromForm(Name = "ibgeId")]
        public int IbgeId { get; set; }

        [FromForm(Name = "file")]
        public IFormFile? File { get; set; }
    }
}