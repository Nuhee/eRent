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
                    //Picture = ImageConversion.ConvertImageToByteArray("Assets", "pic1.png")
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
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "adil.png")

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
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "denis.png")

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
                    Picture = ImageConversion.ConvertImageToByteArray("Assets", "amel.png")

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

            // Seed Properties
            modelBuilder.Entity<Property>().HasData(
                // Property 1 - Landlord 1 (User Id = 2)
                new Property
                {
                    Id = 1,
                    Title = "Modern Apartment in Sarajevo Center",
                    Description = "Beautiful 2-bedroom apartment located in the heart of Sarajevo. Fully furnished with modern amenities. Close to shopping centers and public transportation.",
                    PricePerMonth = 800.00m,
                    PricePerDay = 35.00m,
                    AllowDailyRental = true,
                    Bedrooms = 2,
                    Bathrooms = 1,
                    Area = 65.5m,
                    PropertyTypeId = 1, // Apartment
                    CityId = 1, // Sarajevo
                    LandlordId = 2, // Landlord 1
                    Address = "Ferhadija 12, Sarajevo",
                    Latitude = 43.8563m,
                    Longitude = 18.4131m,
                    IsActive = true,
                    CreatedAt = fixedDate
                },
                // Property 2 - Landlord 2 (User Id = 3)
                new Property
                {
                    Id = 2,
                    Title = "Spacious House in Mostar",
                    Description = "Luxurious 3-bedroom house with garden and parking. Perfect for families. Located in a quiet neighborhood with easy access to city center.",
                    PricePerMonth = 1200.00m,
                    PricePerDay = 50.00m,
                    AllowDailyRental = true,
                    Bedrooms = 3,
                    Bathrooms = 2,
                    Area = 120.0m,
                    PropertyTypeId = 2, // House
                    CityId = 5, // Mostar
                    LandlordId = 3, // Landlord 2
                    Address = "Bulevar 45, Mostar",
                    Latitude = 43.3433m,
                    Longitude = 17.8078m,
                    IsActive = true,
                    CreatedAt = fixedDate
                },
                // Property 3 - Landlord 3 (User Id = 4)
                new Property
                {
                    Id = 3,
                    Title = "Cozy Studio in Tuzla",
                    Description = "Compact and well-designed studio apartment ideal for students or young professionals. Includes all necessary amenities and is close to university.",
                    PricePerMonth = 450.00m,
                    PricePerDay = null, // No daily rental
                    AllowDailyRental = false,
                    Bedrooms = 0,
                    Bathrooms = 1,
                    Area = 35.0m,
                    PropertyTypeId = 4, // Studio
                    CityId = 3, // Tuzla
                    LandlordId = 4, // Landlord 3
                    Address = "Slatina 8, Tuzla",
                    Latitude = 44.5384m,
                    Longitude = 18.6678m,
                    IsActive = true,
                    CreatedAt = fixedDate
                }
            );

            // Seed PropertyAmenities (many-to-many)
            modelBuilder.Entity<PropertyAmenity>().HasData(
                // Property 1 amenities
                new PropertyAmenity { Id = 1, PropertyId = 1, AmenityId = 1, DateAdded = fixedDate }, // WiFi
                new PropertyAmenity { Id = 2, PropertyId = 1, AmenityId = 2, DateAdded = fixedDate }, // Parking
                new PropertyAmenity { Id = 3, PropertyId = 1, AmenityId = 3, DateAdded = fixedDate }, // Air Conditioning
                new PropertyAmenity { Id = 4, PropertyId = 1, AmenityId = 4, DateAdded = fixedDate }, // TV
                new PropertyAmenity { Id = 5, PropertyId = 1, AmenityId = 5, DateAdded = fixedDate }, // Washing Machine
                new PropertyAmenity { Id = 6, PropertyId = 1, AmenityId = 8, DateAdded = fixedDate }, // Kitchen
                new PropertyAmenity { Id = 7, PropertyId = 1, AmenityId = 9, DateAdded = fixedDate }, // Balcony
                new PropertyAmenity { Id = 8, PropertyId = 1, AmenityId = 13, DateAdded = fixedDate }, // Elevator
                new PropertyAmenity { Id = 9, PropertyId = 1, AmenityId = 18, DateAdded = fixedDate }, // Furnished

                // Property 2 amenities
                new PropertyAmenity { Id = 10, PropertyId = 2, AmenityId = 1, DateAdded = fixedDate }, // WiFi
                new PropertyAmenity { Id = 11, PropertyId = 2, AmenityId = 2, DateAdded = fixedDate }, // Parking
                new PropertyAmenity { Id = 12, PropertyId = 2, AmenityId = 3, DateAdded = fixedDate }, // Air Conditioning
                new PropertyAmenity { Id = 13, PropertyId = 2, AmenityId = 4, DateAdded = fixedDate }, // TV
                new PropertyAmenity { Id = 14, PropertyId = 2, AmenityId = 5, DateAdded = fixedDate }, // Washing Machine
                new PropertyAmenity { Id = 15, PropertyId = 2, AmenityId = 6, DateAdded = fixedDate }, // Dishwasher
                new PropertyAmenity { Id = 16, PropertyId = 2, AmenityId = 7, DateAdded = fixedDate }, // Heating
                new PropertyAmenity { Id = 17, PropertyId = 2, AmenityId = 8, DateAdded = fixedDate }, // Kitchen
                new PropertyAmenity { Id = 18, PropertyId = 2, AmenityId = 10, DateAdded = fixedDate }, // Garden
                new PropertyAmenity { Id = 19, PropertyId = 2, AmenityId = 14, DateAdded = fixedDate }, // Pet Friendly
                new PropertyAmenity { Id = 20, PropertyId = 2, AmenityId = 18, DateAdded = fixedDate }, // Furnished

                // Property 3 amenities
                new PropertyAmenity { Id = 21, PropertyId = 3, AmenityId = 1, DateAdded = fixedDate }, // WiFi
                new PropertyAmenity { Id = 22, PropertyId = 3, AmenityId = 3, DateAdded = fixedDate }, // Air Conditioning
                new PropertyAmenity { Id = 23, PropertyId = 3, AmenityId = 4, DateAdded = fixedDate }, // TV
                new PropertyAmenity { Id = 24, PropertyId = 3, AmenityId = 5, DateAdded = fixedDate }, // Washing Machine
                new PropertyAmenity { Id = 25, PropertyId = 3, AmenityId = 7, DateAdded = fixedDate }, // Heating
                new PropertyAmenity { Id = 26, PropertyId = 3, AmenityId = 8, DateAdded = fixedDate }, // Kitchen
                new PropertyAmenity { Id = 27, PropertyId = 3, AmenityId = 18, DateAdded = fixedDate } // Furnished
            );

            // Seed PropertyImages
            modelBuilder.Entity<PropertyImage>().HasData(
                // Property 1 images (ap1_1.jpg, ap1_2.jpg, ap1_3.jpg)
                new PropertyImage
                {
                    Id = 1,
                    PropertyId = 1,
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "ap1_1.jpg"),
                    DisplayOrder = 1,
                    IsCover = true,
                    IsActive = true,
                    CreatedAt = fixedDate
                },
                new PropertyImage
                {
                    Id = 2,
                    PropertyId = 1,
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "ap1_2.jpg"),
                    DisplayOrder = 2,
                    IsCover = false,
                    IsActive = true,
                    CreatedAt = fixedDate
                },
                new PropertyImage
                {
                    Id = 3,
                    PropertyId = 1,
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "ap1_3.jpg"),
                    DisplayOrder = 3,
                    IsCover = false,
                    IsActive = true,
                    CreatedAt = fixedDate
                },

                // Property 2 images (ap2_1.jpg, ap2_2.jpg, ap2_3.jpg)
                new PropertyImage
                {
                    Id = 4,
                    PropertyId = 2,
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "ap2_1.jpg"),
                    DisplayOrder = 1,
                    IsCover = true,
                    IsActive = true,
                    CreatedAt = fixedDate
                },
                new PropertyImage
                {
                    Id = 5,
                    PropertyId = 2,
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "ap2_2.jpg"),
                    DisplayOrder = 2,
                    IsCover = false,
                    IsActive = true,
                    CreatedAt = fixedDate
                },
                new PropertyImage
                {
                    Id = 6,
                    PropertyId = 2,
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "ap2_3.jpg"),
                    DisplayOrder = 3,
                    IsCover = false,
                    IsActive = true,
                    CreatedAt = fixedDate
                },

                // Property 3 images (ap3_1.jpg, ap3_2.jpg, ap3_3.jpg)
                new PropertyImage
                {
                    Id = 7,
                    PropertyId = 3,
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "ap3_1.jpg"),
                    DisplayOrder = 1,
                    IsCover = true,
                    IsActive = true,
                    CreatedAt = fixedDate
                },
                new PropertyImage
                {
                    Id = 8,
                    PropertyId = 3,
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "ap3_2.jpg"),
                    DisplayOrder = 2,
                    IsCover = false,
                    IsActive = true,
                    CreatedAt = fixedDate
                },
                new PropertyImage
                {
                    Id = 9,
                    PropertyId = 3,
                    ImageData = ImageConversion.ConvertImageToByteArray("Assets", "ap3_3.jpg"),
                    DisplayOrder = 3,
                    IsCover = false,
                    IsActive = true,
                    CreatedAt = fixedDate
                }
            );

            // Seed Rents
            var rentFixedDate = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc);
            
            modelBuilder.Entity<Rent>().HasData(
                // Daily rent for User 5 (Amel) - Property 1, 3 days in January 2025
                new Rent
                {
                    Id = 1,
                    PropertyId = 1, // Modern Apartment in Sarajevo Center
                    UserId = 5, // Amel (regular user 1)
                    StartDate = new DateTime(2025, 1, 15, 0, 0, 0, DateTimeKind.Utc),
                    EndDate = new DateTime(2025, 1, 18, 0, 0, 0, DateTimeKind.Utc),
                    IsDailyRental = true,
                    TotalPrice = 105.00m, // 35.00 * 3 days
                    Status = "Completed",
                    IsActive = true,
                    CreatedAt = rentFixedDate
                },
                // Monthly rent for User 6 (Nina) - Property 1, January 2025
                new Rent
                {
                    Id = 2,
                    PropertyId = 1, // Modern Apartment in Sarajevo Center
                    UserId = 6, // Nina (regular user 2)
                    StartDate = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                    EndDate = new DateTime(2025, 1, 31, 23, 59, 59, DateTimeKind.Utc),
                    IsDailyRental = false,
                    TotalPrice = 800.00m, // Monthly price
                    Status = "Completed",
                    IsActive = true,
                    CreatedAt = rentFixedDate
                },
                // Monthly rent for User 7 (Goran) - Property 2, February 2025
                new Rent
                {
                    Id = 3,
                    PropertyId = 2, // Spacious House in Mostar
                    UserId = 7, // Goran (regular user 3)
                    StartDate = new DateTime(2025, 2, 1, 0, 0, 0, DateTimeKind.Utc),
                    EndDate = new DateTime(2025, 2, 28, 23, 59, 59, DateTimeKind.Utc),
                    IsDailyRental = false,
                    TotalPrice = 1200.00m, // Monthly price
                    Status = "Active",
                    IsActive = true,
                    CreatedAt = rentFixedDate
                },
                // Monthly rent for User 6 (Nina) - Property 3, March-April 2025 (2 months)
                new Rent
                {
                    Id = 4,
                    PropertyId = 3, // Cozy Studio in Tuzla
                    UserId = 6, // Nina (regular user 2)
                    StartDate = new DateTime(2025, 3, 1, 0, 0, 0, DateTimeKind.Utc),
                    EndDate = new DateTime(2025, 4, 30, 23, 59, 59, DateTimeKind.Utc),
                    IsDailyRental = false,
                    TotalPrice = 900.00m, // 450.00 * 2 months
                    Status = "Pending",
                    IsActive = true,
                    CreatedAt = rentFixedDate
                }
            );


        }
    }
}