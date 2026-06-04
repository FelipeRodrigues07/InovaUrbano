using apiUrbanPlanning.Infrastructure.Models;
using ApiUrbanPlanning.Infrastructure.Models;
using Microsoft.EntityFrameworkCore;

namespace apiUrbanPlanning.Infrastructure.Data
{
    public class InfrastructureDbContext : DbContext
    {

        public InfrastructureDbContext(DbContextOptions<InfrastructureDbContext> options) : base(options) { 
        }


        public DbSet<User> Users { get; set; }  
        public DbSet<Suggestion>  Suggestions { get; set; }
        public DbSet<Post> Posts { get; set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configura a relação entre Suggestion e User
            modelBuilder.Entity<Suggestion>()
                .HasOne(s => s.User) // Define que Suggestion tem uma relação com User
                .WithMany(u => u.Suggestions) // Define que User pode ter muitas sugestões
                .HasForeignKey(s => s.UserId) // Define a chave estrangeira
                .OnDelete(DeleteBehavior.Cascade); // Comportamento de deleção

            modelBuilder.Entity<Suggestion>()
           .Property(s => s.Number)
           .ValueGeneratedOnAdd()
            .UseIdentityColumn();


            modelBuilder.Entity<Post>()
                .ToTable("Posts")
                .Property(s => s.Number)
                .ValueGeneratedOnAdd()
                .UseIdentityColumn();

        }


    }
}
