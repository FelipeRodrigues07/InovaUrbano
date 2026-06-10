using apiUrbanPlanning.Infrastructure.Data;
using apiUrbanPlanning.Infrastructure.Repositories;
using apiUrbanPlanning.Infrastructure.Repositories.user;
using apiUrbanPlanning.UseCase.Suggestions;
using apiUrbanPlanning.UseCase.Users;
using Microsoft.EntityFrameworkCore;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using apiUrbanPlanning.Infrastructure.Services;
using Microsoft.AspNetCore.Http.Features;
using ApiUrbanPlanning.UseCase.Users;
using ApiUrbanPlanning.UseCase.Suggestions;
using ApiUrbanPlanning.Infrastructure.Repositories;
using ApiUrbanPlanning.UseCase.Post;
using apiUrbanPlanning.UseCase.Municipalities;
using apiUrbanPlanning.Infrastructure.Data.Seed;


var builder = WebApplication.CreateBuilder(args);


builder.Services.AddDbContext<InfrastructureDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")).LogTo(Console.WriteLine, LogLevel.Information));//lembrar que tem que mudar se contexto ta   UseSqlServer



builder.Services.AddScoped<InterfaceUser, RepositoryUser>();
builder.Services.AddScoped<CreateAccountUseCase>();
builder.Services.AddScoped<InterfaceSuggestion, RepositorySuggestion>();
builder.Services.AddScoped<InterfacePost, RepositoryPost>();
builder.Services.AddScoped<InterfaceMunicipality, RepositoryMunicipality>();
builder.Services.AddScoped<CreateMunicipalityUseCase>();
builder.Services.AddScoped<UpdateMunicipalityUseCase>();
builder.Services.AddScoped<GetAllMunicipalitiesUseCase>();
builder.Services.AddScoped<CreateSuggestionUseCase>();
builder.Services.AddScoped<JwtTokenService>();
builder.Services.AddScoped<AuthenticateUseCase>();
builder.Services.AddScoped<ProfileUseCase>();
builder.Services.AddScoped<GetAllSuggestionsByAreaUseCase>();
builder.Services.AddScoped<GetAllSuggestionsFeedUseCase>();
builder.Services.AddScoped<CreateProfilePictureUseCase>();
builder.Services.AddScoped<DeleteProfilePictureUseCase>();
builder.Services.AddScoped<UpdatePasswordUseCase>();
builder.Services.AddScoped<UpdateEmailUseCase>();
builder.Services.AddScoped<UpdateNameUseCase>();
builder.Services.AddScoped<GetAllSuggestionsAdmUseCase>();
builder.Services.AddScoped<GetSuggestionsAnalyticsUseCase>();
builder.Services.AddScoped<CreatePostUseCase>();
builder.Services.AddScoped<GetAllPostAdmUseCase>();
builder.Services.AddScoped<GetAllPostsFeedUseCase>();

builder.Services.Configure<CloudinarySettings>(builder.Configuration.GetSection("CloudinarySettings"));
builder.Services.AddScoped<CloudinaryService>();


// Configura o JWT Bearer para autentica��o
var key = Encoding.UTF8.GetBytes(builder.Configuration["JwtSettings:Secret"]);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    // Mantém os nomes curtos das claims do token ("role", "ibge_id", etc.)
    options.MapInboundClaims = false;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = false, // Configure se necess�rio
        ValidateAudience = false, // Configure se necess�rio
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        RoleClaimType = "role",
    };
});

// Configura o limite de tamanho do corpo multipart 
builder.Services.Configure<FormOptions>(options =>
{
    options.MultipartBodyLengthLimit = 10 * 1024 * 1024; // 10 MB
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()       // Permite qualquer origem
              .AllowAnyMethod()       // Permite qualquer m�todo (GET, POST, etc.)
              .AllowAnyHeader();      // Permite qualquer cabe�alho
    });
});




builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
//builder.Services.AddSwaggerGen(c =>
//{
//    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo { Title = "Api UrbanPlanning", Version = "v1" });
//    c.ResolveConflictingActions(apiDescriptions => apiDescriptions.First());
//});

var app = builder.Build();

if (args.Contains("seed"))
{
    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<InfrastructureDbContext>();
    await MockSeedRunner.RunAsync(context);
    Console.WriteLine("Seed concluído.");
    return;
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}


app.UseHttpsRedirection();

app.UseCors("AllowAll"); //cors

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
