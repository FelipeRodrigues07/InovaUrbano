using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace apiUrbanPlanning.Migrations
{
    public partial class renamePostToPosts : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameTable(
                name: "Post",
                newName: "Posts");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameTable(
                name: "Posts",
                newName: "Post");
        }
    }
}
