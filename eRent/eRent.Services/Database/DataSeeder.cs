using eRent.Services.Helpers;
using Microsoft.EntityFrameworkCore;
using System;

namespace eRent.Services.Database
{
    public static class DataSeeder
    {
        private const string DefaultPhoneNumber = "+387 61 111 111";

        public static void SeedData(this ModelBuilder modelBuilder)
        {
            // Use a fixed date for all timestamps
            var fixedDate = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc);

            // Seed Roles
            modelBuilder.Entity<Role>().HasData(
                   new Role
                   {
                       Id = 1,
                       Name = "Administrator",
                       Description = "Full system access and administrative privileges",
                       CreatedAt = fixedDate,
                       IsActive = true
                   },
                   new Role
                   {
                       Id = 2,
                       Name = "User",
                       Description = "Standard user with limited system access",
                       CreatedAt = fixedDate,
                       IsActive = true
                   },
                   new Role
                   {
                       Id = 3,
                       Name = "Landlord",
                       Description = "Landlord with property management access",
                       CreatedAt = fixedDate,
                       IsActive = true
                   }
            );


            const string defaultPassword = "test";

            // Admin user (desktop)
            var desktopSalt = PasswordGenerator.GenerateDeterministicSalt("desktop");
            var desktopHash = PasswordGenerator.GenerateHash(defaultPassword, desktopSalt);

            // Landlord users
            var landlord1Salt = PasswordGenerator.GenerateDeterministicSalt("landlord");
            var landlord1Hash = PasswordGenerator.GenerateHash(defaultPassword, landlord1Salt);
            var landlord2Salt = PasswordGenerator.GenerateDeterministicSalt("landlord2");
            var landlord2Hash = PasswordGenerator.GenerateHash(defaultPassword, landlord2Salt);
            var landlord3Salt = PasswordGenerator.GenerateDeterministicSalt("landlord3");
            var landlord3Hash = PasswordGenerator.GenerateHash(defaultPassword, landlord3Salt);

            // Regular users
            var user1Salt = PasswordGenerator.GenerateDeterministicSalt("user");
            var user1Hash = PasswordGenerator.GenerateHash(defaultPassword, user1Salt);
            var user2Salt = PasswordGenerator.GenerateDeterministicSalt("user2");
            var user2Hash = PasswordGenerator.GenerateHash(defaultPassword, user2Salt);
            var user3Salt = PasswordGenerator.GenerateDeterministicSalt("user3");
            var user3Hash = PasswordGenerator.GenerateHash(defaultPassword, user3Salt);



            // Seed Users
            modelBuilder.Entity<User>().HasData(
                // Admin user (desktop)
                new User
                {
                    Id = 1,
                    FirstName = "Vedad",
                    LastName = "Nuhić",
                    Email = "admin@erent.com",
                    Username = "desktop",
                    PasswordHash = desktopHash,
                    PasswordSalt = desktopSalt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, 
                    CityId = 1, 
                },
                // Landlord 1
                new User
                {
                    Id = 2,
                    FirstName = "Adil",
                    LastName = "Joldić",
                    Email = "landlord1@erent.com",
                    Username = "landlord",
                    PasswordHash = landlord1Hash,
                    PasswordSalt = landlord1Salt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, 
                    CityId = 1, 
                },
                // Landlord 2
                new User
                {
                    Id = 3,
                    FirstName = "Elmir",
                    LastName = "Babović",
                    Email = "landlord2@erent.com",
                    Username = "landlord2",
                    PasswordHash = landlord2Hash,
                    PasswordSalt = landlord2Salt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, 
                    CityId = 5, 
                },
                // Landlord 3
                new User
                {
                    Id = 4,
                    FirstName = "Denis",
                    LastName = "Mušić",
                    Email = "landlord3@erent.com",
                    Username = "landlord3",
                    PasswordHash = landlord3Hash,
                    PasswordSalt = landlord3Salt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1,
                    CityId = 3, 
                },
                // User 1
                new User
                {
                    Id = 5,
                    FirstName = "Amel",
                    LastName = "Musić",
                    Email = "test.vedadnuhic@gmail.com",
                    Username = "user",
                    PasswordHash = user1Hash,
                    PasswordSalt = user1Salt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, 
                    CityId = 1, 
                },
                // User 2
                new User
                {
                    Id = 6,
                    FirstName = "Nina",
                    LastName = "Bijedić",
                    Email = "user2@erent.com",
                    Username = "user2",
                    PasswordHash = user2Hash,
                    PasswordSalt = user2Salt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 2, 
                    CityId = 5, 
                },
                // User 3
                new User
                {
                    Id = 7,
                    FirstName = "Goran",
                    LastName = "Škondrić",
                    Email = "user3@erent.com",
                    Username = "user3",
                    PasswordHash = user3Hash,
                    PasswordSalt = user3Salt,
                    IsActive = true,
                    CreatedAt = fixedDate,
                    PhoneNumber = DefaultPhoneNumber,
                    GenderId = 1, 
                    CityId = 3, 
                }
            );

            // Seed UserRoles
            modelBuilder.Entity<UserRole>().HasData(
                // Admin user (desktop) - Administrator role
                new UserRole { Id = 1, UserId = 1, RoleId = 1, DateAssigned = fixedDate },
                // Landlord 1 - Landlord role
                new UserRole { Id = 2, UserId = 2, RoleId = 3, DateAssigned = fixedDate },
                // Landlord 2 - Landlord role
                new UserRole { Id = 3, UserId = 3, RoleId = 3, DateAssigned = fixedDate },
                // Landlord 3 - Landlord role
                new UserRole { Id = 4, UserId = 4, RoleId = 3, DateAssigned = fixedDate },
                // User 1 - User role
                new UserRole { Id = 5, UserId = 5, RoleId = 2, DateAssigned = fixedDate },
                // User 2 - User role
                new UserRole { Id = 6, UserId = 6, RoleId = 2, DateAssigned = fixedDate },
                // User 3 - User role
                new UserRole { Id = 7, UserId = 7, RoleId = 2, DateAssigned = fixedDate }
            );

            // Seed Genders
            modelBuilder.Entity<Gender>().HasData(
                new Gender { Id = 1, Name = "Male" },
                new Gender { Id = 2, Name = "Female" }
            );

            // Seed PropertyTypes
            modelBuilder.Entity<PropertyType>().HasData(
                new PropertyType { Id = 1, Name = "Apartment", IsActive = true },
                new PropertyType { Id = 2, Name = "House", IsActive = true },
                new PropertyType { Id = 3, Name = "Villa", IsActive = true },
                new PropertyType { Id = 4, Name = "Studio", IsActive = true },
                new PropertyType { Id = 5, Name = "Condo", IsActive = true },
                new PropertyType { Id = 6, Name = "Townhouse", IsActive = true },
                new PropertyType { Id = 7, Name = "Penthouse", IsActive = true },
                new PropertyType { Id = 8, Name = "Cottage", IsActive = true },
                new PropertyType { Id = 9, Name = "Duplex", IsActive = true },
                new PropertyType { Id = 10, Name = "Loft", IsActive = true }
            );

            // Seed Amenities
            modelBuilder.Entity<Amenity>().HasData(
                new Amenity { Id = 1, Name = "WiFi", IsActive = true },
                new Amenity { Id = 2, Name = "Parking", IsActive = true },
                new Amenity { Id = 3, Name = "Air Conditioning", IsActive = true },
                new Amenity { Id = 4, Name = "TV", IsActive = true },
                new Amenity { Id = 5, Name = "Washing Machine", IsActive = true },
                new Amenity { Id = 6, Name = "Dishwasher", IsActive = true },
                new Amenity { Id = 7, Name = "Heating", IsActive = true },
                new Amenity { Id = 8, Name = "Kitchen", IsActive = true },
                new Amenity { Id = 9, Name = "Balcony", IsActive = true },
                new Amenity { Id = 10, Name = "Garden", IsActive = true },
                new Amenity { Id = 11, Name = "Pool", IsActive = true },
                new Amenity { Id = 12, Name = "Gym", IsActive = true },
                new Amenity { Id = 13, Name = "Elevator", IsActive = true },
                new Amenity { Id = 14, Name = "Pet Friendly", IsActive = true },
                new Amenity { Id = 15, Name = "Smoking Allowed", IsActive = true },
                new Amenity { Id = 16, Name = "Fireplace", IsActive = true },
                new Amenity { Id = 17, Name = "Security System", IsActive = true },
                new Amenity { Id = 18, Name = "Furnished", IsActive = true }
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