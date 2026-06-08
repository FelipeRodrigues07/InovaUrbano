using apiUrbanPlanning.Infrastructure.Models;
using apiUrbanPlanning.UseCase.Municipalities;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace apiUrbanPlanning.Infrastructure.Data.Seed
{
    public static class MockSeedRunner
    {
        public static async Task RunAsync(InfrastructureDbContext context)
        {
            var municipality = await EnsureMunicipalityAsync(context);
            await EnsureAdminAsync(context, municipality);
            await context.SaveChangesAsync();
        }

        private static async Task<Municipality> EnsureMunicipalityAsync(InfrastructureDbContext context)
        {
            var municipality = await context.Municipalities
                .FirstOrDefaultAsync(m => m.IbgeId == MockSeedData.Anapolis.IbgeId);

            if (municipality != null)
            {
                return municipality;
            }

            municipality = new Municipality
            {
                IbgeId = MockSeedData.Anapolis.IbgeId,
                Name = MockSeedData.Anapolis.Name,
                State = MockSeedData.Anapolis.State,
                Slug = CreateMunicipalityUseCase.GenerateSlug(
                    MockSeedData.Anapolis.Name,
                    MockSeedData.Anapolis.State),
                IsActive = MockSeedData.Anapolis.IsActive,
                CreatedAt = DateTime.UtcNow
            };

            await context.Municipalities.AddAsync(municipality);
            await context.SaveChangesAsync();

            return municipality;
        }

        private static async Task EnsureAdminAsync(InfrastructureDbContext context, Municipality municipality)
        {
            var normalizedEmail = MockSeedData.Anapolis.Admin.Email.Trim().ToLowerInvariant();

            var userExists = await context.Users
                .AnyAsync(u => u.Email.ToLower() == normalizedEmail);

            if (userExists)
            {
                return;
            }

            var passwordHasher = new PasswordHasher<User>();
            var user = new User
            {
                Name = MockSeedData.Anapolis.Admin.Name,
                Email = normalizedEmail,
                Role = MockSeedData.Anapolis.Admin.Role,
                MunicipalityId = municipality.Id,
                CreatedAt = DateTime.UtcNow
            };

            user.Password = passwordHasher.HashPassword(user, MockSeedData.Anapolis.Admin.Password);

            await context.Users.AddAsync(user);
        }
    }
}
