using eRent.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;

namespace eRent.Services.Database
{
    public static class DataSeeder
    {
        private const string DefaultPhoneNumber = "+387 00 000 000";
        
        private const string TestMailSender = "test.sender@gmail.com";
        private const string TestMailReceiver = "test.receiver@gmail.com";

        public static void SeedData(this ModelBuilder modelBuilder)
        {
            // Use a fixed date for all timestamps
            var fixedDate = new DateTime(2025, 5, 5, 0, 0, 0, DateTimeKind.Utc);

            // Seed Roles
            modelBuilder.Entity<Role>().HasData(
                new Role 
                { 
                    Id = 1, 
                    Name = "Administrator", 
                    Description = "System administrator with full access", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                },
                new Role 
                { 
                    Id = 2, 
                    Name = "User", 
                    Description = "Regular user role", 
                    CreatedAt = fixedDate, 
                    IsActive = true 
                }
            );

            // Seed Users
            modelBuilder.Entity<User>().HasData(
                new User 
                {
                    Id = 1,
                    FirstName = "Denis",
                    LastName = "Mušić",
                    Email = TestMailReceiver,
                    Username = "admin",
                    PasswordHash = "3KbrBi5n9zdQnceWWOK5zaeAwfEjsluyhRQUbNkcgLQ=",
                    PasswordSalt = "6raKZCuEsvnBBxPKHGpRtA==",
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 1, // Sarajevo
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "denis.png")
                },
                new User 
                { 
                    Id = 2, 
                    FirstName = "Amel", 
                    LastName = "Musić",
                    Email = "example1@gmail.com",
                    Username = "user", 
                    PasswordHash = "kDPVcZaikiII7vXJbMEw6B0xZ245I29ocaxBjLaoAC0=", 
                    PasswordSalt = "O5R9WmM6IPCCMci/BCG/eg==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 5, // Mostar
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "amel.png")
                },
                new User 
                { 
                    Id = 3, 
                    FirstName = "Adil", 
                    LastName = "Joldić",
                    Email = "example2@gmail.com",
                    Username = "admin2", 
                    PasswordHash = "BiWDuil9svAKOYzii5wopQW3YqjVfQrzGE2iwH/ylY4=", 
                    PasswordSalt = "pfNS+OLBaQeGqBIzXXcWuA==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, // Male
                    CityId = 3, // Tuzla
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "adil.png")
                },
                new User 
                { 
                    Id = 4, 
                    FirstName = "Test", 
                    LastName = "Test", 
                    Email = TestMailSender, 
                    Username = "user2", 
                    PasswordHash = "KUF0Jsocq9AqdwR9JnT2OrAqm5gDj7ecQvNwh6fW/Bs=", 
                    PasswordSalt = "c3ZKo0va3tYfnYuNKkHDbQ==", 
                    IsActive = true, 
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 2, // Female
                    CityId = 1, // Sarajevo
                    //Picture = ImageConversion.ConvertImageToByteArray("Assets", "test.png")
                }
            );

            // Seed UserRoles
            modelBuilder.Entity<UserRole>().HasData(
                new UserRole { Id = 1, UserId = 1, RoleId = 1, DateAssigned = fixedDate }, 
                new UserRole { Id = 2, UserId = 2, RoleId = 1, DateAssigned = fixedDate }, 
                new UserRole { Id = 3, UserId = 3, RoleId = 2, DateAssigned = fixedDate }, 
                new UserRole { Id = 4, UserId = 4, RoleId = 2, DateAssigned = fixedDate }  
            );

            // Seed Genders
            modelBuilder.Entity<Gender>().HasData(
                new Gender { Id = 1, Name = "Male" },
                new Gender { Id = 2, Name = "Female" }
            );

            // Seed Countries (Balkan countries)
            modelBuilder.Entity<Country>().HasData(
                new Country { Id = 1, Name = "Bosnia and Herzegovina", Code = "BIH", IsActive = true },
                new Country { Id = 2, Name = "Croatia", Code = "HRV", IsActive = true },
                new Country { Id = 3, Name = "Serbia", Code = "SRB", IsActive = true },
                new Country { Id = 4, Name = "Montenegro", Code = "MNE", IsActive = true },
                new Country { Id = 5, Name = "North Macedonia", Code = "MKD", IsActive = true },
                new Country { Id = 6, Name = "Albania", Code = "ALB", IsActive = true },
                new Country { Id = 7, Name = "Slovenia", Code = "SVN", IsActive = true }
            );

            // Seed Cities - Bosnia and Herzegovina (Id = 1)
            int cityId = 1;
            modelBuilder.Entity<City>().HasData(
                // Bosnia and Herzegovina cities
                new City { Id = cityId++, Name = "Sarajevo", CountryId = 1, IsActive = true },
                new City { Id = cityId++, Name = "Banja Luka", CountryId = 1, IsActive = true },
                new City { Id = cityId++, Name = "Tuzla", CountryId = 1, IsActive = true },
                new City { Id = cityId++, Name = "Zenica", CountryId = 1, IsActive = true },
                new City { Id = cityId++, Name = "Mostar", CountryId = 1, IsActive = true },
                new City { Id = cityId++, Name = "Bijeljina", CountryId = 1, IsActive = true },
                new City { Id = cityId++, Name = "Prijedor", CountryId = 1, IsActive = true },
                new City { Id = cityId++, Name = "Brčko", CountryId = 1, IsActive = true },
                new City { Id = cityId++, Name = "Doboj", CountryId = 1, IsActive = true },
                new City { Id = cityId++, Name = "Zvornik", CountryId = 1, IsActive = true },

                // Croatia cities
                new City { Id = cityId++, Name = "Zagreb", CountryId = 2, IsActive = true },
                new City { Id = cityId++, Name = "Split", CountryId = 2, IsActive = true },
                new City { Id = cityId++, Name = "Rijeka", CountryId = 2, IsActive = true },
                new City { Id = cityId++, Name = "Osijek", CountryId = 2, IsActive = true },
                new City { Id = cityId++, Name = "Zadar", CountryId = 2, IsActive = true },
                new City { Id = cityId++, Name = "Slavonski Brod", CountryId = 2, IsActive = true },
                new City { Id = cityId++, Name = "Pula", CountryId = 2, IsActive = true },
                new City { Id = cityId++, Name = "Sesvete", CountryId = 2, IsActive = true },
                new City { Id = cityId++, Name = "Karlovac", CountryId = 2, IsActive = true },
                new City { Id = cityId++, Name = "Varaždin", CountryId = 2, IsActive = true },

                // Serbia cities
                new City { Id = cityId++, Name = "Belgrade", CountryId = 3, IsActive = true },
                new City { Id = cityId++, Name = "Novi Sad", CountryId = 3, IsActive = true },
                new City { Id = cityId++, Name = "Niš", CountryId = 3, IsActive = true },
                new City { Id = cityId++, Name = "Kragujevac", CountryId = 3, IsActive = true },
                new City { Id = cityId++, Name = "Subotica", CountryId = 3, IsActive = true },
                new City { Id = cityId++, Name = "Zrenjanin", CountryId = 3, IsActive = true },
                new City { Id = cityId++, Name = "Pančevo", CountryId = 3, IsActive = true },
                new City { Id = cityId++, Name = "Čačak", CountryId = 3, IsActive = true },
                new City { Id = cityId++, Name = "Novi Pazar", CountryId = 3, IsActive = true },
                new City { Id = cityId++, Name = "Kraljevo", CountryId = 3, IsActive = true },

                // Montenegro cities
                new City { Id = cityId++, Name = "Podgorica", CountryId = 4, IsActive = true },
                new City { Id = cityId++, Name = "Nikšić", CountryId = 4, IsActive = true },
                new City { Id = cityId++, Name = "Pljevlja", CountryId = 4, IsActive = true },
                new City { Id = cityId++, Name = "Bijelo Polje", CountryId = 4, IsActive = true },
                new City { Id = cityId++, Name = "Cetinje", CountryId = 4, IsActive = true },
                new City { Id = cityId++, Name = "Bar", CountryId = 4, IsActive = true },
                new City { Id = cityId++, Name = "Herceg Novi", CountryId = 4, IsActive = true },
                new City { Id = cityId++, Name = "Budva", CountryId = 4, IsActive = true },
                new City { Id = cityId++, Name = "Berane", CountryId = 4, IsActive = true },
                new City { Id = cityId++, Name = "Ulcinj", CountryId = 4, IsActive = true },

                // North Macedonia cities
                new City { Id = cityId++, Name = "Skopje", CountryId = 5, IsActive = true },
                new City { Id = cityId++, Name = "Bitola", CountryId = 5, IsActive = true },
                new City { Id = cityId++, Name = "Kumanovo", CountryId = 5, IsActive = true },
                new City { Id = cityId++, Name = "Prilep", CountryId = 5, IsActive = true },
                new City { Id = cityId++, Name = "Tetovo", CountryId = 5, IsActive = true },
                new City { Id = cityId++, Name = "Veles", CountryId = 5, IsActive = true },
                new City { Id = cityId++, Name = "Štip", CountryId = 5, IsActive = true },
                new City { Id = cityId++, Name = "Ohrid", CountryId = 5, IsActive = true },
                new City { Id = cityId++, Name = "Gostivar", CountryId = 5, IsActive = true },
                new City { Id = cityId++, Name = "Strumica", CountryId = 5, IsActive = true },

                // Albania cities
                new City { Id = cityId++, Name = "Tirana", CountryId = 6, IsActive = true },
                new City { Id = cityId++, Name = "Durrës", CountryId = 6, IsActive = true },
                new City { Id = cityId++, Name = "Vlorë", CountryId = 6, IsActive = true },
                new City { Id = cityId++, Name = "Shkodër", CountryId = 6, IsActive = true },
                new City { Id = cityId++, Name = "Fier", CountryId = 6, IsActive = true },
                new City { Id = cityId++, Name = "Korçë", CountryId = 6, IsActive = true },
                new City { Id = cityId++, Name = "Elbasan", CountryId = 6, IsActive = true },
                new City { Id = cityId++, Name = "Kavajë", CountryId = 6, IsActive = true },
                new City { Id = cityId++, Name = "Gjirokastër", CountryId = 6, IsActive = true },
                new City { Id = cityId++, Name = "Sarandë", CountryId = 6, IsActive = true },

                // Slovenia cities
                new City { Id = cityId++, Name = "Ljubljana", CountryId = 7, IsActive = true },
                new City { Id = cityId++, Name = "Maribor", CountryId = 7, IsActive = true },
                new City { Id = cityId++, Name = "Celje", CountryId = 7, IsActive = true },
                new City { Id = cityId++, Name = "Kranj", CountryId = 7, IsActive = true },
                new City { Id = cityId++, Name = "Velenje", CountryId = 7, IsActive = true },
                new City { Id = cityId++, Name = "Koper", CountryId = 7, IsActive = true },
                new City { Id = cityId++, Name = "Novo Mesto", CountryId = 7, IsActive = true },
                new City { Id = cityId++, Name = "Ptuj", CountryId = 7, IsActive = true },
                new City { Id = cityId++, Name = "Trbovlje", CountryId = 7, IsActive = true },
                new City { Id = cityId++, Name = "Kamnik", CountryId = 7, IsActive = true }
            );
        }
    }
} 