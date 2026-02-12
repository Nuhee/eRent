using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using DotNetEnv;
using System.IO;
using System.Reflection;

namespace eRent.Services.Database
{
    /// <summary>
    /// Design-time factory for Entity Framework migrations.
    /// This allows EF Core tools to create a DbContext instance during migrations.
    /// Uses Trusted_Connection (Windows Auth) for local development.
    /// </summary>
    public class eRentDbContextFactory : IDesignTimeDbContextFactory<eRentDbContext>
    {
        public eRentDbContext CreateDbContext(string[] args)
        {
            // Try to find and load .env file by walking up directories
            var currentDir = Directory.GetCurrentDirectory();

            for (int i = 0; i < 5 && currentDir != null; i++)
            {
                var testPath = Path.Combine(currentDir, ".env");
                if (File.Exists(testPath))
                {
                    try
                    {
                        Env.Load(testPath);
                    }
                    catch
                    {
                        // If loading fails, continue - environment variables might be set another way
                    }
                    break;
                }
                currentDir = Directory.GetParent(currentDir)?.FullName;
            }

            // Design-time factory is only used locally (migrations), never in Docker
            // Use Trusted_Connection (Windows Auth) - no password needed
            var sqlServer = Environment.GetEnvironmentVariable("SQL__SERVER") ?? ".";
            var sqlDatabase = Environment.GetEnvironmentVariable("SQL__DATABASE") ?? "eRentDb";

            var connectionString = $"Server={sqlServer};Database={sqlDatabase};TrustServerCertificate=True;Trusted_Connection=True;";

            var optionsBuilder = new DbContextOptionsBuilder<eRentDbContext>();
            optionsBuilder.UseSqlServer(connectionString);

            return new eRentDbContext(optionsBuilder.Options);
        }
    }
}
