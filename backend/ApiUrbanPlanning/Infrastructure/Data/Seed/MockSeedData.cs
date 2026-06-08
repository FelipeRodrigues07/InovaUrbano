using apiUrbanPlanning.Infrastructure.Constants;

namespace apiUrbanPlanning.Infrastructure.Data.Seed
{
    public static class MockSeedData
    {
        public static class Anapolis
        {
            public const int IbgeId = 5201108;
            public const string Name = "Anápolis";
            public const string State = "GO";
            public const string Slug = "anapolis-go";
            public const bool IsActive = true;

            public static class Admin
            {
                public const string Name = "Admin Anápolis";
                public const string Email = "admin.anapolis@inovaurbano.local";
                public const string Password = "Admin@123";
                public const string Role = UserRoles.MunicipalityAdmin;
            }
        }
    }
}
