using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace apiUrbanPlanning.Migrations
{
    /// <inheritdoc />
    public partial class addUrlImageSuggestions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SuggestionImageUrl",
                table: "Suggestions",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SuggestionImageUrl",
                table: "Suggestions");
        }
    }
}
