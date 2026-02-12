using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Database;
using eRent.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace eRent.Services.Services
{
    public class PropertyAmenityService : BaseCRUDService<PropertyAmenityResponse, PropertyAmenitySearchObject, PropertyAmenity, PropertyAmenityUpsertRequest, PropertyAmenityUpsertRequest>, IPropertyAmenityService
    {
        public PropertyAmenityService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<PagedResult<PropertyAmenityResponse>> GetAsync(PropertyAmenitySearchObject search)
        {
            var query = _context.PropertyAmenities
                .Include(pa => pa.Property)
                .Include(pa => pa.Amenity)
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
            return new PagedResult<PropertyAmenityResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        protected override IQueryable<PropertyAmenity> ApplyFilter(IQueryable<PropertyAmenity> query, PropertyAmenitySearchObject search)
        {
            if (search.PropertyId.HasValue)
            {
                query = query.Where(pa => pa.PropertyId == search.PropertyId.Value);
            }

            if (search.AmenityId.HasValue)
            {
                query = query.Where(pa => pa.AmenityId == search.AmenityId.Value);
            }

            return query;
        }

        protected PropertyAmenityResponse MapToResponse(PropertyAmenity entity)
        {
            var response = _mapper.Map<PropertyAmenityResponse>(entity);
            
            if (entity.Property != null)
            {
                response.PropertyTitle = entity.Property.Title;
            }

            if (entity.Amenity != null)
            {
                response.AmenityName = entity.Amenity.Name;
            }

            return response;
        }

        public override async Task<PropertyAmenityResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.PropertyAmenities
                .Include(pa => pa.Property)
                .Include(pa => pa.Amenity)
                .FirstOrDefaultAsync(pa => pa.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public override async Task<PropertyAmenityResponse> CreateAsync(PropertyAmenityUpsertRequest request)
        {
            var entity = new PropertyAmenity();
            MapInsertToEntity(entity, request);
            entity.DateAdded = DateTime.Now;

            _context.PropertyAmenities.Add(entity);

            await BeforeInsert(entity, request);

            await _context.SaveChangesAsync();

            // Reload with relationships
            await _context.Entry(entity).Reference(pa => pa.Property).LoadAsync();
            await _context.Entry(entity).Reference(pa => pa.Amenity).LoadAsync();

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(PropertyAmenity entity, PropertyAmenityUpsertRequest request)
        {
            // Validate Property exists
            if (!await _context.Properties.AnyAsync(p => p.Id == request.PropertyId))
            {
                throw new InvalidOperationException("Property does not exist.");
            }

            // Validate Amenity exists
            if (!await _context.Amenities.AnyAsync(a => a.Id == request.AmenityId))
            {
                throw new InvalidOperationException("Amenity does not exist.");
            }

            // Check if relationship already exists
            if (await _context.PropertyAmenities.AnyAsync(pa => pa.PropertyId == request.PropertyId && pa.AmenityId == request.AmenityId))
            {
                throw new InvalidOperationException("This amenity is already associated with this property.");
            }
        }

        protected override async Task BeforeUpdate(PropertyAmenity entity, PropertyAmenityUpsertRequest request)
        {
            // Validate Property exists
            if (!await _context.Properties.AnyAsync(p => p.Id == request.PropertyId))
            {
                throw new InvalidOperationException("Property does not exist.");
            }

            // Validate Amenity exists
            if (!await _context.Amenities.AnyAsync(a => a.Id == request.AmenityId))
            {
                throw new InvalidOperationException("Amenity does not exist.");
            }

            // Check if relationship already exists (excluding current entity)
            if (await _context.PropertyAmenities.AnyAsync(pa => pa.PropertyId == request.PropertyId && pa.AmenityId == request.AmenityId && pa.Id != entity.Id))
            {
                throw new InvalidOperationException("This amenity is already associated with this property.");
            }
        }
    }
}
