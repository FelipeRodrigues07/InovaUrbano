namespace apiUrbanPlanning.Infrastructure.Constants
{
    public static class UserRoles
    {
        public const string Member = "member";
        public const string MunicipalityAdmin = "municipality_admin";
        public const string Operator = "operator";
        public const string SuperAdmin = "super_admin";

        public const string AdminPanel =
            $"{SuperAdmin},{MunicipalityAdmin},{Operator}";
    }
}
