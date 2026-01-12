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
    public class RentStatusService : BaseCRUDService<RentStatusResponse, RentStatusSearchObject, RentStatus, RentStatusUpsertRequest, RentStatusUpsertRequest>, IRentStatusService
    {
        public RentStatusService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<RentStatus> ApplyFilter(IQueryable<RentStatus> query, RentStatusSearchObject search)
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

        protected override async Task BeforeInsert(RentStatus entity, RentStatusUpsertRequest request)
        {
            if (await _context.RentStatuses.AnyAsync(rs => rs.Name == request.Name))
            {
                throw new InvalidOperationException("A rent status with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(RentStatus entity, RentStatusUpsertRequest request)
        {
            if (await _context.RentStatuses.AnyAsync(rs => rs.Name == request.Name && rs.Id != entity.Id))
            {
                throw new InvalidOperationException("A rent status with this name already exists.");
            }
        }
    }
}
