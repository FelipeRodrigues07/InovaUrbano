using Microsoft.AspNetCore.Mvc;

namespace apiUrbanPlanning.Requests
{
    public class RequestPictureProfile
    {

        [FromForm(Name = "file")]
        public IFormFile File { get; set; }

    }
}
