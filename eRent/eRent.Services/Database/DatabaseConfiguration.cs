using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace eRent.Services.Database
{
    public static class DatabaseConfiguration
    {
        public static void AddDatabaseServices(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<eRentDbContext>(options =>
                options.UseSqlServer(connectionString));
        }

        public static void AddDatabaseERent(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<eRentDbContext>(options =>
                options.UseSqlServer(connectionString));
        }
    }
}