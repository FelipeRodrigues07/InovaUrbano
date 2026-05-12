using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace apiUrbanPlanning.Migrations
{
    /// <inheritdoc />
    public partial class atualizationPost : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Number",
                table: "Post",
                newName: "NumberSuggestion");

            migrationBuilder.AddColumn<Guid>(
                name: "SuggestionId",
                table: "Post",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SuggestionId",
                table: "Post");

            migrationBuilder.RenameColumn(
                name: "NumberSuggestion",
                table: "Post",
                newName: "Number");
        }
    }
}
