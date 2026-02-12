using eRent.Model;
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
    public class ViewingAppointmentService
        : BaseCRUDService<ViewingAppointmentResponse, ViewingAppointmentSearchObject, ViewingAppointment, ViewingAppointmentUpsertRequest, ViewingAppointmentUpsertRequest>,
          IViewingAppointmentService
    {
        private static readonly string[] StatusNames = { "Pending", "Approved", "Rejected", "Cancelled", "Completed" };

        public ViewingAppointmentService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<ViewingAppointmentResponse> CreateAsync(ViewingAppointmentUpsertRequest request)
        {
            // Validate appointment is in the future
            if (request.AppointmentDate <= DateTime.Now)
            {
                throw new UserException("Appointment date must be in the future.");
            }

            var endTime = request.AppointmentDate.AddHours(2);

            // Check for conflicts: existing appointments for the same property
            // where status is Pending (0) or Approved (1) and times overlap
            var hasConflict = await _context.ViewingAppointments
                .AnyAsync(va =>
                    va.PropertyId == request.PropertyId &&
                    (va.Status == 0 || va.Status == 1) &&
                    va.AppointmentDate < endTime &&
                    va.EndTime > request.AppointmentDate);

            if (hasConflict)
            {
                throw new UserException("There is already a viewing appointment scheduled for this property at the selected time. Please choose a different time slot.");
            }

            // Create the entity manually to set EndTime
            var entity = new ViewingAppointment
            {
                PropertyId = request.PropertyId,
                TenantId = request.TenantId,
                AppointmentDate = request.AppointmentDate,
                EndTime = endTime,
                Status = 0, // Pending
                TenantNote = request.TenantNote,
                CreatedAt = DateTime.Now
            };

            _context.ViewingAppointments.Add(entity);
            await _context.SaveChangesAsync();

            // Reload with includes for response mapping
            var saved = await _context.ViewingAppointments
                .Include(x => x.Property)
                    .ThenInclude(p => p.Landlord)
                .Include(x => x.Tenant)
                .FirstAsync(x => x.Id == entity.Id);

            return MapToResponse(saved);
        }

        public override async Task<PagedResult<ViewingAppointmentResponse>> GetAsync(ViewingAppointmentSearchObject search)
        {
            var query = _context.ViewingAppointments
                .Include(x => x.Property)
                    .ThenInclude(p => p.Landlord)
                .Include(x => x.Tenant)
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
                    query = query.Skip(search.Page.Value * search.PageSize!.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            return new PagedResult<ViewingAppointmentResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public override async Task<ViewingAppointmentResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.ViewingAppointments
                .Include(x => x.Property)
                    .ThenInclude(p => p.Landlord)
                .Include(x => x.Tenant)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override IQueryable<ViewingAppointment> ApplyFilter(IQueryable<ViewingAppointment> query, ViewingAppointmentSearchObject search)
        {
            if (search.PropertyId.HasValue)
            {
                query = query.Where(x => x.PropertyId == search.PropertyId.Value);
            }

            if (search.TenantId.HasValue)
            {
                query = query.Where(x => x.TenantId == search.TenantId.Value);
            }

            if (search.LandlordId.HasValue)
            {
                query = query.Where(x => x.Property != null && x.Property.LandlordId == search.LandlordId.Value);
            }

            if (search.Status.HasValue)
            {
                query = query.Where(x => x.Status == search.Status.Value);
            }

            if (search.DateFrom.HasValue)
            {
                query = query.Where(x => x.AppointmentDate >= search.DateFrom.Value);
            }

            if (search.DateTo.HasValue)
            {
                query = query.Where(x => x.AppointmentDate <= search.DateTo.Value);
            }

            // Order by appointment date descending (newest first)
            return query.OrderByDescending(x => x.AppointmentDate);
        }

        public async Task<ViewingAppointmentResponse?> ApproveAsync(int id, string? landlordNote = null)
        {
            var entity = await _context.ViewingAppointments
                .Include(x => x.Property)
                    .ThenInclude(p => p.Landlord)
                .Include(x => x.Tenant)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            if (entity.Status != 0)
            {
                throw new UserException("Only pending viewing appointments can be approved.");
            }

            entity.Status = 1; // Approved
            entity.LandlordNote = landlordNote;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        public async Task<ViewingAppointmentResponse?> RejectAsync(int id, string? landlordNote = null)
        {
            var entity = await _context.ViewingAppointments
                .Include(x => x.Property)
                    .ThenInclude(p => p.Landlord)
                .Include(x => x.Tenant)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            if (entity.Status != 0)
            {
                throw new UserException("Only pending viewing appointments can be rejected.");
            }

            entity.Status = 2; // Rejected
            entity.LandlordNote = landlordNote;
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        public async Task<ViewingAppointmentResponse?> CancelAsync(int id)
        {
            var entity = await _context.ViewingAppointments
                .Include(x => x.Property)
                    .ThenInclude(p => p.Landlord)
                .Include(x => x.Tenant)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            if (entity.Status != 0 && entity.Status != 1)
            {
                throw new UserException("Only pending or approved viewing appointments can be cancelled.");
            }

            entity.Status = 3; // Cancelled
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return MapToResponse(entity);
        }

        private new ViewingAppointmentResponse MapToResponse(ViewingAppointment entity)
        {
            var response = new ViewingAppointmentResponse
            {
                Id = entity.Id,
                PropertyId = entity.PropertyId,
                TenantId = entity.TenantId,
                AppointmentDate = entity.AppointmentDate,
                EndTime = entity.EndTime,
                Status = entity.Status,
                StatusName = entity.Status >= 0 && entity.Status < StatusNames.Length
                    ? StatusNames[entity.Status]
                    : "Unknown",
                TenantNote = entity.TenantNote,
                LandlordNote = entity.LandlordNote,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt
            };

            if (entity.Property != null)
            {
                response.PropertyTitle = entity.Property.Title;
                response.PropertyAddress = entity.Property.Address ?? string.Empty;

                if (entity.Property.Landlord != null)
                {
                    response.LandlordId = entity.Property.LandlordId;
                }
            }

            if (entity.Tenant != null)
            {
                response.TenantName = $"{entity.Tenant.FirstName} {entity.Tenant.LastName}";
            }

            return response;
        }
    }
}
