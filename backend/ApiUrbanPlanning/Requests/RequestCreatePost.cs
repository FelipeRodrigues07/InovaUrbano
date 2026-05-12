using Microsoft.AspNetCore.Mvc;

namespace ApiUrbanPlanning.Requests
{
    public class RequestCreatePost
    {
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Status {  get; set; } = string.Empty; 
        public int Number {  get; set; } 

        [FromForm(Name = "file")]
        public IFormFile File { get; set; } //  Arquivo de imagem 
    }
}
