using eRent.Services.Database;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.OpenApi.Models;
using eRent.WebAPI.Filters;
using eRent.Services.Services;
using eRent.Services.Interfaces;
using System.Reflection;
using Microsoft.Extensions.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using DotNetEnv;

// Load .env file if it exists (for local development)
// In Docker, environment variables are provided by docker-compose
try
{
    var possibleEnvPaths = new[]
    {
        Path.Combine(Directory.GetCurrentDirectory(), ".env"),
        Path.Combine(Directory.GetCurrentDirectory(), "..", ".env"),
        Path.Combine(Directory.GetCurrentDirectory(), "..", "..", ".env"),
    };

    bool envLoaded = false;
    foreach (var envPath in possibleEnvPaths)
    {
        if (File.Exists(envPath))
        {
            Env.Load(envPath);
            envLoaded = true;
            break;
        }
    }

    if (!envLoaded)
    {
        Env.Load();
    }
}
catch (FileNotFoundException)
{
    // .env file not found - this is OK in Docker environments
    // Environment variables will be provided by docker-compose
}

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IGenderService, GenderService>();
builder.Services.AddTransient<ICountryService, CountryService>();
builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<IPropertyTypeService, PropertyTypeService>();
builder.Services.AddTransient<IAmenityService, AmenityService>();
builder.Services.AddTransient<IPropertyService, PropertyService>();
builder.Services.AddTransient<IPropertyAmenityService, PropertyAmenityService>();
builder.Services.AddTransient<IPropertyImageService, PropertyImageService>();
builder.Services.AddTransient<IRentService, RentService>();
builder.Services.AddTransient<IRentStatusService, RentStatusService>();
builder.Services.AddTransient<IReviewRentService, ReviewRentService>();
builder.Services.AddTransient<IChatService, ChatService>();
builder.Services.AddTransient<IAnalyticsService, AnalyticsService>();
builder.Services.AddTransient<ILandlordAnalyticsService, LandlordAnalyticsService>();
builder.Services.AddTransient<IPaymentService, PaymentService>();
builder.Services.AddTransient<IViewingAppointmentService, ViewingAppointmentService>();


// Configure database
// Try to get connection string from configuration first (Docker sets this via environment)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

// If not found or empty (local development), use Trusted_Connection (Windows Auth)
if (string.IsNullOrWhiteSpace(connectionString))
{
    var sqlServer = Environment.GetEnvironmentVariable("SQL__SERVER") ?? ".";
    var sqlDatabase = Environment.GetEnvironmentVariable("SQL__DATABASE") ?? "eRentDb";

    connectionString = $"Server={sqlServer};Database={sqlDatabase};TrustServerCertificate=True;Trusted_Connection=True;";
}

builder.Services.AddDatabaseServices(connectionString);

// Add configuration
builder.Services.AddSingleton<IConfiguration>(builder.Configuration);

builder.Services.AddMapster();

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddControllers(x =>
    {
        x.Filters.Add<ExceptionFilter>();
    }
);

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();

// Za dodavanje opisnog teksta pored swagger call-a
var xmlFilename = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";

builder.Services.AddSwaggerGen(c =>
{
    c.IncludeXmlComments(Path.Combine(AppContext.BaseDirectory, xmlFilename));

    c.AddSecurityDefinition("BasicAuthentication", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "basic",
        In = ParameterLocation.Header,
        Description = "Basic Authorization header using the Bearer scheme."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "BasicAuthentication" } },
            new string[] { }
        }
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
//if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Only redirect HTTP to HTTPS when not in Development (allows mobile app / emulator to use http://10.0.2.2:5130)
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<eRentDbContext>();


    var pendingMigrations = dataContext.Database.GetPendingMigrations().Any();

    if (pendingMigrations)
    {

        dataContext.Database.Migrate();


    }
    // Train the recommender model in background after startup
    _ = Task.Run(async () =>  // The underscore tells the compiler we're intentionally ignoring the result
    {
        // Wait a bit for the app to fully start
        await Task.Delay(2000);
        using (var trainingScope = app.Services.CreateScope())
        {
            PropertyService.TrainRecommenderAtStartup(trainingScope.ServiceProvider);
        }
    });
}

app.Run();
