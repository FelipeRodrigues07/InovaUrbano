using apiUrbanPlanning.Infrastructure.Models;
using ApiUrbanPlanning.Infrastructure.Models;
using Microsoft.EntityFrameworkCore;

namespace apiUrbanPlanning.Infrastructure.Data
{
    public class InfrastructureDbContext : DbContext
    {
        public InfrastructureDbContext(DbContextOptions<InfrastructureDbContext> options) : base(options)
        {
        }

        public override int SaveChanges()
        {
            ApplyAuditTimestamps();
            return base.SaveChanges();
        }

        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            ApplyAuditTimestamps();
            return base.SaveChangesAsync(cancellationToken);
        }

        private void ApplyAuditTimestamps()
        {
            var now = DateTime.UtcNow;

            foreach (var entry in ChangeTracker.Entries())
            {
                if (entry.State == EntityState.Added)
                {
                    var createdAt = entry.Properties.FirstOrDefault(p => p.Metadata.Name == nameof(User.CreatedAt));
                    if (createdAt != null && createdAt.CurrentValue is DateTime created && created == default)
                        createdAt.CurrentValue = now;
                }
                else if (entry.State == EntityState.Modified)
                {
                    var updatedAt = entry.Properties.FirstOrDefault(p => p.Metadata.Name == nameof(User.UpdatedAt));
                    if (updatedAt != null)
                        updatedAt.CurrentValue = now;
                }
            }
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Suggestion> Suggestions { get; set; }
        public DbSet<OfficialResponse> OfficialResponses { get; set; }
        public DbSet<Municipality> Municipalities { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Suggestion>(entity =>
            {
                entity.HasOne(s => s.User)
                    .WithMany(u => u.Suggestions)
                    .HasForeignKey(s => s.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(s => new { s.IbgeId, s.Number })
                    .IsUnique();
            });

            modelBuilder.Entity<OfficialResponse>(entity =>
            {
                entity.ToTable("OfficialResponses");

                entity.Property(r => r.Number)
                    .ValueGeneratedOnAdd()
                    .UseIdentityColumn();

                entity.HasOne<Suggestion>()
                    .WithMany()
                    .HasForeignKey(r => r.SuggestionId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne<User>()
                    .WithMany()
                    .HasForeignKey(r => r.UserId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<Municipality>(entity =>
            {
                entity.ToTable("Municipalities");
                entity.HasIndex(m => m.IbgeId).IsUnique();
                entity.HasIndex(m => m.Slug).IsUnique();
            });

            modelBuilder.Entity<User>(entity =>
            {
                entity.HasIndex(u => u.Email).IsUnique();

                entity.HasOne(u => u.Municipality)
                    .WithMany(m => m.Users)
                    .HasForeignKey(u => u.MunicipalityId)
                    .OnDelete(DeleteBehavior.SetNull);
            });
        }
    }
}
