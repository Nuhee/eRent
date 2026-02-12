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
    public class PropertyImageService : BaseCRUDService<PropertyImageResponse, PropertyImageSearchObject, PropertyImage, PropertyImageUpsertRequest, PropertyImageUpsertRequest>, IPropertyImageService
    {
        public PropertyImageService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<PagedResult<PropertyImageResponse>> GetAsync(PropertyImageSearchObject search)
        {
            var query = _context.PropertyImages
                .Include(pi => pi.Property)
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

            var list = await query.OrderBy(pi => pi.DisplayOrder).ThenBy(pi => pi.CreatedAt).ToListAsync();
            return new PagedResult<PropertyImageResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        protected override IQueryable<PropertyImage> ApplyFilter(IQueryable<PropertyImage> query, PropertyImageSearchObject search)
        {
            if (search.PropertyId.HasValue)
            {
                query = query.Where(pi => pi.PropertyId == search.PropertyId.Value);
            }

            if (search.IsCover.HasValue)
            {
                query = query.Where(pi => pi.IsCover == search.IsCover.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(pi => pi.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected PropertyImageResponse MapToResponse(PropertyImage entity)
        {
            var response = _mapper.Map<PropertyImageResponse>(entity);
            
            if (entity.Property != null)
            {
                response.PropertyTitle = entity.Property.Title;
            }

            return response;
        }

        public override async Task<PropertyImageResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.PropertyImages
                .Include(pi => pi.Property)
                .FirstOrDefaultAsync(pi => pi.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public override async Task<PropertyImageResponse> CreateAsync(PropertyImageUpsertRequest request)
        {
            var entity = new PropertyImage();
            MapInsertToEntity(entity, request);
            entity.CreatedAt = DateTime.Now;

            _context.PropertyImages.Add(entity);

            await BeforeInsert(entity, request);

            await _context.SaveChangesAsync();

            // Reload with relationship
            await _context.Entry(entity).Reference(pi => pi.Property).LoadAsync();

            return MapToResponse(entity);
        }

        public override async Task<PropertyImageResponse?> UpdateAsync(int id, PropertyImageUpsertRequest request)
        {
            var entity = await _context.PropertyImages.FindAsync(id);
            if (entity == null)
                return null;

            await BeforeUpdate(entity, request);

            MapUpdateToEntity(entity, request);

            await _context.SaveChangesAsync();

            // Reload with relationship
            await _context.Entry(entity).Reference(pi => pi.Property).LoadAsync();

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(PropertyImage entity, PropertyImageUpsertRequest request)
        {
            // Validate Property exists
            if (!await _context.Properties.AnyAsync(p => p.Id == request.PropertyId))
            {
                throw new InvalidOperationException("Property does not exist.");
            }

            // If setting as cover, unset other covers for this property
            if (request.IsCover)
            {
                var existingCovers = await _context.PropertyImages
                    .Where(pi => pi.PropertyId == request.PropertyId && pi.IsCover)
                    .ToListAsync();

                foreach (var cover in existingCovers)
                {
                    cover.IsCover = false;
                }
            }
        }

        protected override async Task BeforeUpdate(PropertyImage entity, PropertyImageUpsertRequest request)
        {
            // Validate Property exists
            if (!await _context.Properties.AnyAsync(p => p.Id == request.PropertyId))
            {
                throw new InvalidOperationException("Property does not exist.");
            }

            // If setting as cover, unset other covers for this property (excluding current entity)
            if (request.IsCover && !entity.IsCover)
            {
                var existingCovers = await _context.PropertyImages
                    .Where(pi => pi.PropertyId == request.PropertyId && pi.IsCover && pi.Id != entity.Id)
                    .ToListAsync();

                foreach (var cover in existingCovers)
                {
                    cover.IsCover = false;
                }
            }
        }
    }
}
