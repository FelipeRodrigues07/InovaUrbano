namespace ApiUrbanPlanning.Response
{
    public class PaginatedAdmResponse<T>
    {
        public List<T> Data { get; set; } = new();
        public PaginationMeta Meta { get; set; } = new();
    }
}
