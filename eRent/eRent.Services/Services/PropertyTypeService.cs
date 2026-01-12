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
    public class PropertyTypeService : BaseCRUDService<PropertyTypeResponse, PropertyTypeSearchObject, PropertyType, PropertyTypeUpsertRequest, PropertyTypeUpsertRequest>, IPropertyTypeService
    {
        public PropertyTypeService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<PropertyType> ApplyFilter(IQueryable<PropertyType> query, PropertyTypeSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(PropertyType entity, PropertyTypeUpsertRequest request)
        {
            if (await _context.PropertyTypes.AnyAsync(pt => pt.Name == request.Name))
            {
                throw new InvalidOperationException("A property type with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(PropertyType entity, PropertyTypeUpsertRequest request)
        {
            if (await _context.PropertyTypes.AnyAsync(pt => pt.Name == request.Name && pt.Id != entity.Id))
            {
                throw new InvalidOperationException("A property type with this name already exists.");
            }
        }
    }
}
