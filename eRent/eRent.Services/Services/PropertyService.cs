using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Database;
using eRent.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eRent.Services.Services
{
    public class PropertyService : BaseCRUDService<PropertyResponse, PropertySearchObject, Property, PropertyUpsertRequest, PropertyUpsertRequest>, IPropertyService
    {
        public PropertyService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
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
    }
}
