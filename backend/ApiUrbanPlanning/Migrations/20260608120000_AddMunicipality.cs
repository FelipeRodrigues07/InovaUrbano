using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace apiUrbanPlanning.Migrations
{
    public partial class AddMunicipality : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Municipalities",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    IbgeId = table.Column<int>(type: "integer", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    State = table.Column<string>(type: "text", nullable: false),
                    Slug = table.Column<string>(type: "text", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    ContractStartsAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ContractEndsAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Municipalities", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Municipalities_IbgeId",
                table: "Municipalities",
                column: "IbgeId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Municipalities_Slug",
                table: "Municipalities",
                column: "Slug",
                unique: true);

            migrationBuilder.AddColumn<Guid>(
                name: "MunicipalityId",
                table: "Users",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Users_MunicipalityId",
                table: "Users",
                column: "MunicipalityId");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Municipalities_MunicipalityId",
                table: "Users",
                column: "MunicipalityId",
                principalTable: "Municipalities",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_Municipalities_MunicipalityId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_MunicipalityId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "MunicipalityId",
                table: "Users");

            migrationBuilder.DropTable(
                name: "Municipalities");
        }
    }
}
