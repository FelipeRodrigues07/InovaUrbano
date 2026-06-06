using System.Text.Json.Serialization;

namespace ApiUrbanPlanning.Response
{
    public class PaginationMeta
    {
        [JsonPropertyName("current_page")]
        public int CurrentPage { get; set; }

        [JsonPropertyName("per_page")]
        public int PerPage { get; set; }

        [JsonPropertyName("total")]
        public int Total { get; set; }

        [JsonPropertyName("last_page")]
        public int LastPage { get; set; }

        public static PaginationMeta Create(int pageNumber, int pageSize, int total)
        {
            var perPage = Math.Max(pageSize, 1);
            var currentPage = Math.Max(pageNumber, 1);
            var lastPage = total == 0 ? 1 : (int)Math.Ceiling(total / (double)perPage);

            return new PaginationMeta
            {
                CurrentPage = currentPage,
                PerPage = perPage,
                Total = total,
                LastPage = lastPage,
            };
        }
    }
}
