using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Database;
using eRent.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eRent.Services.Services
{
    public class PropertyService : BaseCRUDService<PropertyResponse, PropertySearchObject, Property, PropertyUpsertRequest, PropertyUpsertRequest>, IPropertyService
    {
        private static MLContext _mlContext = null;
        private static object _mlLock = new object();
        private static ITransformer? _model = null;

        public PropertyService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
            if (_mlContext == null)
            {
                lock (_mlLock)
                {
                    if (_mlContext == null)
                    {
                        _mlContext = new MLContext();
                    }
                }
            }
        }

        public override async Task<PagedResult<PropertyResponse>> GetAsync(PropertySearchObject search)
        {
            var query = _context.Properties
                .Include(x => x.PropertyType)
                .Include(x => x.City)
                .Include(x => x.Landlord)
                .Include(x => x.PropertyAmenities)
                    .ThenInclude(pa => pa.Amenity)
                .Include(x => x.PropertyImages)
                .AsQueryable();

            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            return new PagedResult<PropertyResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        protected override IQueryable<Property> ApplyFilter(IQueryable<Property> query, PropertySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Title))
            {
                query = query.Where(x => x.Title.Contains(search.Title));
            }

            if (search.PropertyTypeId.HasValue)
            {
                query = query.Where(x => x.PropertyTypeId == search.PropertyTypeId.Value);
            }

            if (search.CityId.HasValue)
            {
                query = query.Where(x => x.CityId == search.CityId.Value);
            }

            if (search.CountryId.HasValue)
            {
                query = query.Where(x => x.City != null && x.City.CountryId == search.CountryId.Value);
            }

            if (search.LandlordId.HasValue)
            {
                query = query.Where(x => x.LandlordId == search.LandlordId.Value);
            }

            if (search.MinPricePerMonth.HasValue)
            {
                query = query.Where(x => x.PricePerMonth >= search.MinPricePerMonth.Value);
            }

            if (search.MaxPricePerMonth.HasValue)
            {
                query = query.Where(x => x.PricePerMonth <= search.MaxPricePerMonth.Value);
            }

            if (search.MinPricePerDay.HasValue)
            {
                query = query.Where(x => x.PricePerDay.HasValue && x.PricePerDay.Value >= search.MinPricePerDay.Value);
            }

            if (search.MaxPricePerDay.HasValue)
            {
                query = query.Where(x => x.PricePerDay.HasValue && x.PricePerDay.Value <= search.MaxPricePerDay.Value);
            }

            if (search.AllowDailyRental.HasValue)
            {
                query = query.Where(x => x.AllowDailyRental == search.AllowDailyRental.Value);
            }

            if (search.MinBedrooms.HasValue)
            {
                query = query.Where(x => x.Bedrooms >= search.MinBedrooms.Value);
            }

            if (search.MaxBedrooms.HasValue)
            {
                query = query.Where(x => x.Bedrooms <= search.MaxBedrooms.Value);
            }

            if (search.AmenityIds != null && search.AmenityIds.Count > 0)
            {
                // Property must have ALL selected amenities (AND logic, not OR)
                query = query.Where(x => search.AmenityIds.All(amenityId => 
                    x.PropertyAmenities.Any(pa => pa.AmenityId == amenityId)));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected PropertyResponse MapToResponse(Property entity)
        {
            var response = _mapper.Map<PropertyResponse>(entity);
            
            if (entity.PropertyType != null)
            {
                response.PropertyTypeName = entity.PropertyType.Name;
            }

            if (entity.City != null)
            {
                response.CityName = entity.City.Name;
            }

            if (entity.Landlord != null)
            {
                response.LandlordName = $"{entity.Landlord.FirstName} {entity.Landlord.LastName}";
            }

            if (entity.PropertyAmenities != null && entity.PropertyAmenities.Any())
            {
                response.Amenities = entity.PropertyAmenities
                    .Where(pa => pa.Amenity != null)
                    .Select(pa => new AmenityResponse
                    {
                        Id = pa.Amenity.Id,
                        Name = pa.Amenity.Name,
                        IsActive = pa.Amenity.IsActive
                    })
                    .ToList();
            }

            if (entity.PropertyImages != null && entity.PropertyImages.Any())
            {
                response.Images = entity.PropertyImages
                    .OrderBy(pi => pi.DisplayOrder)
                    .ThenBy(pi => pi.CreatedAt)
                    .Select(pi => new PropertyImageResponse
                    {
                        Id = pi.Id,
                        PropertyId = pi.PropertyId,
                        PropertyTitle = entity.Title,
                        ImageData = pi.ImageData,
                        DisplayOrder = pi.DisplayOrder,
                        IsCover = pi.IsCover,
                        IsActive = pi.IsActive,
                        CreatedAt = pi.CreatedAt
                    })
                    .ToList();
            }

            return response;
        }

        public override async Task<PropertyResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Properties
                .Include(x => x.PropertyType)
                .Include(x => x.City)
                .Include(x => x.Landlord)
                .Include(x => x.PropertyAmenities)
                    .ThenInclude(pa => pa.Amenity)
                .Include(x => x.PropertyImages)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public override async Task<PropertyResponse> CreateAsync(PropertyUpsertRequest request)
        {
            // Validate first
            await ValidateRequest(request);

            // Create entity manually to ensure all fields are mapped correctly
            var entity = new Property
            {
                Title = request.Title,
                Description = request.Description,
                PricePerMonth = request.PricePerMonth,
                PricePerDay = request.AllowDailyRental ? request.PricePerDay : null,
                AllowDailyRental = request.AllowDailyRental,
                Bedrooms = request.Bedrooms,
                Bathrooms = request.Bathrooms,
                Area = request.Area,
                PropertyTypeId = request.PropertyTypeId,
                CityId = request.CityId,
                LandlordId = request.LandlordId,
                Address = request.Address,
                Latitude = request.Latitude,
                Longitude = request.Longitude,
                IsActive = request.IsActive,
                CreatedAt = DateTime.Now
            };

            _context.Properties.Add(entity);
            await _context.SaveChangesAsync();

            // Handle amenities after property is saved (so we have the ID)
            if (request.AmenityIds != null && request.AmenityIds.Count > 0)
            {
                foreach (var amenityId in request.AmenityIds)
                {
                    var propertyAmenity = new PropertyAmenity
                    {
                        PropertyId = entity.Id,
                        AmenityId = amenityId,
                        DateAdded = DateTime.Now
                    };
                    _context.PropertyAmenities.Add(propertyAmenity);
                }
                await _context.SaveChangesAsync();
            }

            // Reload with all relationships
            return await GetByIdAsync(entity.Id) ?? throw new InvalidOperationException("Failed to reload property after creation");
        }

        public override async Task<PropertyResponse?> UpdateAsync(int id, PropertyUpsertRequest request)
        {
            var entity = await _context.Properties
                .Include(x => x.PropertyAmenities)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            // Validate
            await ValidateRequest(request, id);

            // Update entity fields manually
            entity.Title = request.Title;
            entity.Description = request.Description;
            entity.PricePerMonth = request.PricePerMonth;
            entity.PricePerDay = request.AllowDailyRental ? request.PricePerDay : null;
            entity.AllowDailyRental = request.AllowDailyRental;
            entity.Bedrooms = request.Bedrooms;
            entity.Bathrooms = request.Bathrooms;
            entity.Area = request.Area;
            entity.PropertyTypeId = request.PropertyTypeId;
            entity.CityId = request.CityId;
            entity.LandlordId = request.LandlordId;
            entity.Address = request.Address;
            entity.Latitude = request.Latitude;
            entity.Longitude = request.Longitude;
            entity.IsActive = request.IsActive;
            entity.UpdatedAt = DateTime.Now;

            // Update amenities - remove all existing and add new ones
            var existingAmenities = await _context.PropertyAmenities
                .Where(pa => pa.PropertyId == id)
                .ToListAsync();
            
            _context.PropertyAmenities.RemoveRange(existingAmenities);
            await _context.SaveChangesAsync();

            // Add new amenities
            if (request.AmenityIds != null && request.AmenityIds.Count > 0)
            {
                foreach (var amenityId in request.AmenityIds)
                {
                    var propertyAmenity = new PropertyAmenity
                    {
                        PropertyId = entity.Id,
                        AmenityId = amenityId,
                        DateAdded = DateTime.Now
                    };
                    _context.PropertyAmenities.Add(propertyAmenity);
                }
            }

            await _context.SaveChangesAsync();

            // Reload with all relationships
            return await GetByIdAsync(entity.Id);
        }

        private async Task ValidateRequest(PropertyUpsertRequest request, int? existingId = null)
        {
            // Validate PropertyType exists
            if (!await _context.PropertyTypes.AnyAsync(pt => pt.Id == request.PropertyTypeId))
            {
                throw new InvalidOperationException("Property type does not exist.");
            }

            // Validate City exists
            if (!await _context.Cities.AnyAsync(c => c.Id == request.CityId))
            {
                throw new InvalidOperationException("City does not exist.");
            }

            // Validate Landlord exists
            if (!await _context.Users.AnyAsync(u => u.Id == request.LandlordId))
            {
                throw new InvalidOperationException("Landlord does not exist.");
            }

            // Validate amenities exist
            if (request.AmenityIds != null && request.AmenityIds.Count > 0)
            {
                var existingAmenityIds = await _context.Amenities
                    .Where(a => request.AmenityIds.Contains(a.Id))
                    .Select(a => a.Id)
                    .ToListAsync();

                var invalidIds = request.AmenityIds.Except(existingAmenityIds).ToList();
                if (invalidIds.Any())
                {
                    throw new InvalidOperationException($"Amenities with IDs {string.Join(", ", invalidIds)} do not exist.");
                }
            }

            // Validate daily rental pricing (only validate if daily rental is allowed)
            if (request.AllowDailyRental && (!request.PricePerDay.HasValue || request.PricePerDay.Value <= 0))
            {
                throw new InvalidOperationException("PricePerDay must be provided and greater than 0 when AllowDailyRental is true.");
            }
        }

        public async Task<List<PropertyResponse>> GetRecommendedPropertiesAsync(int userId, int count = 1)
        {
            if (_model == null)
            {
                // Fallback: recommend using heuristic approach
                return await RecommendHeuristic(userId, count);
            }

            var predictionEngine = _mlContext.Model.CreatePredictionEngine<FeedbackEntry, PropertyScorePrediction>(_model);

            // Get properties user has rented before
            var userRents = await _context.Rents
                .Include(r => r.Property)
                .Where(r => r.UserId == userId && r.IsActive)
                .ToListAsync();
            
            var usedPropertyIds = userRents
                .Select(r => r.PropertyId)
                .Distinct()
                .ToList();

            // Get properties user has reviewed positively (rating >= 4)
            var userReviews = await _context.ReviewRents
                .Include(rr => rr.Rent)
                .ThenInclude(r => r.Property)
                .Where(rr => rr.UserId == userId && rr.Rating >= 4 && rr.IsActive)
                .ToListAsync();
            
            var highlyRatedPropertyIds = userReviews
                .Select(rr => rr.Rent.PropertyId)
                .Distinct()
                .ToList();

            // Get preferred property types from user's past experiences
            var userRentsWithProperty = await _context.Rents
                .Include(r => r.Property)
                .Where(r => r.UserId == userId && r.IsActive)
                .ToListAsync();
            
            var reviewedRentIds = await _context.ReviewRents
                .Where(rr => rr.UserId == userId && rr.Rating >= 4 && rr.IsActive)
                .Select(rr => rr.RentId)
                .ToListAsync();
            
            var reviewedRents = await _context.Rents
                .Include(r => r.Property)
                .Where(r => reviewedRentIds.Contains(r.Id) && r.IsActive)
                .ToListAsync();
            
            var preferredPropertyTypeIds = userRentsWithProperty
                .Union(reviewedRents)
                .Select(r => r.Property.PropertyTypeId)
                .Distinct()
                .ToList();

            // Get preferred amenities from user's past positive reviews
            var preferredAmenityIds = new List<int>();
            foreach (var review in userReviews)
            {
                var property = await _context.Properties
                    .Include(p => p.PropertyAmenities)
                    .FirstOrDefaultAsync(p => p.Id == review.Rent.PropertyId);
                
                if (property != null && property.PropertyAmenities.Any())
                {
                    preferredAmenityIds.AddRange(property.PropertyAmenities.Select(pa => pa.AmenityId));
                }
            }
            preferredAmenityIds = preferredAmenityIds.Distinct().ToList();

            // Get candidate properties that user hasn't rented
            var candidateProperties = await _context.Properties
                .Include(x => x.PropertyType)
                .Include(x => x.City)
                .Include(x => x.Landlord)
                .Include(x => x.PropertyAmenities)
                    .ThenInclude(pa => pa.Amenity)
                .Include(x => x.PropertyImages)
                .Where(p => p.IsActive && !usedPropertyIds.Contains(p.Id))
                .ToListAsync();

            if (!candidateProperties.Any())
            {
                // If all properties have been rented, include them but still prioritize preferred types/amenities
                candidateProperties = await _context.Properties
                    .Include(x => x.PropertyType)
                    .Include(x => x.City)
                    .Include(x => x.Landlord)
                    .Include(x => x.PropertyAmenities)
                        .ThenInclude(pa => pa.Amenity)
                    .Include(x => x.PropertyImages)
                    .Where(p => p.IsActive)
                    .ToListAsync();
            }

            if (!candidateProperties.Any())
            {
                return new List<PropertyResponse>();
            }

            // Score all candidates
            var scored = candidateProperties
                .Select(p => new
                {
                    Property = p,
                    MLScore = predictionEngine.Predict(new FeedbackEntry
                    {
                        UserId = (uint)userId,
                        PropertyId = (uint)p.Id
                    }).Score,
                    // Boost score if property type is preferred
                    TypeBoost = preferredPropertyTypeIds.Contains(p.PropertyTypeId) ? 0.5f : 0f,
                    // Boost score if property was highly rated
                    RatingBoost = highlyRatedPropertyIds.Contains(p.Id) ? 0.3f : 0f,
                    // Boost score based on matching amenities
                    AmenityBoost = p.PropertyAmenities != null && p.PropertyAmenities.Any() 
                        ? (float)p.PropertyAmenities.Count(pa => preferredAmenityIds.Contains(pa.AmenityId)) / Math.Max(preferredAmenityIds.Count, 1) * 0.4f
                        : 0f
                })
                .Select(x => new
                {
                    x.Property,
                    FinalScore = x.MLScore + x.TypeBoost + x.RatingBoost + x.AmenityBoost
                })
                .OrderByDescending(x => x.FinalScore)
                .Take(count)
                .Select(x => MapToResponse(x.Property))
                .ToList();

            return scored;
        }

        private async Task<List<PropertyResponse>> RecommendHeuristic(int userId, int count)
        {
            // Get properties user has rented before
            var userRents = await _context.Rents
                .Include(r => r.Property)
                .Where(r => r.UserId == userId && r.IsActive)
                .ToListAsync();
            
            var usedPropertyIds = userRents
                .Select(r => r.PropertyId)
                .Distinct()
                .ToList();

            // Get highly rated properties (rating >= 4) from user's reviews
            var userReviews = await _context.ReviewRents
                .Include(rr => rr.Rent)
                .ThenInclude(r => r.Property)
                .Where(rr => rr.UserId == userId && rr.Rating >= 4 && rr.IsActive)
                .ToListAsync();
            
            var highlyRatedPropertyIds = userReviews
                .Select(rr => rr.Rent.PropertyId)
                .Distinct()
                .ToList();

            // Get preferred property types
            var userRentsWithProperty = await _context.Rents
                .Include(r => r.Property)
                .Where(r => r.UserId == userId && r.IsActive)
                .ToListAsync();
            
            var reviewedRentIds = await _context.ReviewRents
                .Where(rr => rr.UserId == userId && rr.Rating >= 4 && rr.IsActive)
                .Select(rr => rr.RentId)
                .ToListAsync();
            
            var reviewedRents = await _context.Rents
                .Include(r => r.Property)
                .Where(r => reviewedRentIds.Contains(r.Id) && r.IsActive)
                .ToListAsync();
            
            var preferredPropertyTypeIds = userRentsWithProperty
                .Union(reviewedRents)
                .Select(r => r.Property.PropertyTypeId)
                .Distinct()
                .ToList();

            // Get preferred amenities from positive reviews
            var preferredAmenityIds = new List<int>();
            foreach (var review in userReviews)
            {
                var property = await _context.Properties
                    .Include(p => p.PropertyAmenities)
                    .FirstOrDefaultAsync(p => p.Id == review.Rent.PropertyId);
                
                if (property != null && property.PropertyAmenities.Any())
                {
                    preferredAmenityIds.AddRange(property.PropertyAmenities.Select(pa => pa.AmenityId));
                }
            }
            preferredAmenityIds = preferredAmenityIds.Distinct().ToList();

            // Find properties in preferred types with preferred amenities that user hasn't rented
            var candidateProperties = await _context.Properties
                .Include(x => x.PropertyType)
                .Include(x => x.City)
                .Include(x => x.Landlord)
                .Include(x => x.PropertyAmenities)
                    .ThenInclude(pa => pa.Amenity)
                .Include(x => x.PropertyImages)
                .Where(p => p.IsActive)
                .ToListAsync();

            if (!candidateProperties.Any())
            {
                return new List<PropertyResponse>();
            }

            // Prioritize new properties in preferred types with preferred amenities
            var newProperties = candidateProperties
                .Where(p => !usedPropertyIds.Contains(p.Id) 
                    && preferredPropertyTypeIds.Contains(p.PropertyTypeId)
                    && p.PropertyAmenities != null 
                    && p.PropertyAmenities.Any(pa => preferredAmenityIds.Contains(pa.AmenityId)))
                .ToList();

            List<Property> recommendedProperties;

            if (newProperties.Any())
            {
                var random = new Random();
                recommendedProperties = newProperties
                    .OrderBy(x => random.Next())
                    .Take(count)
                    .ToList();
            }
            else
            {
                // Fallback to any new property in preferred types, or highly rated property
                var fallbackProperties = candidateProperties
                    .Where(p => (!usedPropertyIds.Contains(p.Id) && preferredPropertyTypeIds.Contains(p.PropertyTypeId))
                        || highlyRatedPropertyIds.Contains(p.Id))
                    .ToList();

                if (fallbackProperties.Any())
                {
                    var random = new Random();
                    recommendedProperties = fallbackProperties
                        .OrderBy(x => random.Next())
                        .Take(count)
                        .ToList();
                }
                else
                {
                    // Final fallback: any new property
                    var finalFallback = candidateProperties
                        .Where(p => !usedPropertyIds.Contains(p.Id))
                        .ToList();
                    
                    if (finalFallback.Any())
                    {
                        var random = new Random();
                        recommendedProperties = finalFallback
                            .OrderBy(x => random.Next())
                            .Take(count)
                            .ToList();
                    }
                    else
                    {
                        // Last resort: any property
                        var random = new Random();
                        recommendedProperties = candidateProperties
                            .OrderBy(x => random.Next())
                            .Take(count)
                            .ToList();
                    }
                }
            }

            return recommendedProperties.Select(MapToResponse).ToList();
        }

        // Train recommender using Matrix Factorization on (User, Property) implicit feedback
        public static void TrainRecommenderAtStartup(IServiceProvider serviceProvider)
        {
            lock (_mlLock)
            {
                if (_mlContext == null)
                {
                    _mlContext = new MLContext();
                }
                using var scope = serviceProvider.CreateScope();
                var db = scope.ServiceProvider.GetRequiredService<eRentDbContext>();

                // Build implicit feedback dataset from rents (users booking properties)
                var positiveEntries = db.Rents
                    .Where(r => r.IsActive && (r.RentStatusId == 4 || r.RentStatusId == 5)) // Accepted or Paid
                    .Select(r => new FeedbackEntry
                    {
                        UserId = (uint)r.UserId,
                        PropertyId = (uint)r.PropertyId,
                        Label = 1f
                    })
                    .ToList();

                // Add positive feedback from highly rated reviews
                var positiveReviewEntries = db.ReviewRents
                    .Where(rr => rr.Rating >= 4 && rr.IsActive)
                    .Include(rr => rr.Rent)
                    .Select(rr => new FeedbackEntry
                    {
                        UserId = (uint)rr.UserId,
                        PropertyId = (uint)rr.Rent.PropertyId,
                        Label = 1.5f // Higher weight for highly rated properties
                    })
                    .ToList();

                positiveEntries.AddRange(positiveReviewEntries);

                if (!positiveEntries.Any())
                {
                    _model = null;
                    return;
                }

                var trainData = _mlContext.Data.LoadFromEnumerable(positiveEntries);
                var options = new Microsoft.ML.Trainers.MatrixFactorizationTrainer.Options
                {
                    MatrixColumnIndexColumnName = nameof(FeedbackEntry.UserId),
                    MatrixRowIndexColumnName = nameof(FeedbackEntry.PropertyId),
                    LabelColumnName = nameof(FeedbackEntry.Label),
                    LossFunction = Microsoft.ML.Trainers.MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                    Alpha = 0.01,
                    Lambda = 0.025,
                    NumberOfIterations = 50,
                    C = 0.00001
                };

                var estimator = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
                _model = estimator.Fit(trainData);
            }
        }

        private class FeedbackEntry
        {
            [KeyType(count: 100000)]
            public uint UserId { get; set; }
            [KeyType(count: 100000)]
            public uint PropertyId { get; set; }
            public float Label { get; set; }
        }

        private class PropertyScorePrediction
        {
            public float Score { get; set; }
        }
    }
}
