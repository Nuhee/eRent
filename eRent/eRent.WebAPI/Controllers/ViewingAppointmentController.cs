using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eRent.WebAPI.Controllers
{
    public class ViewingAppointmentController : BaseCRUDController<ViewingAppointmentResponse, ViewingAppointmentSearchObject, ViewingAppointmentUpsertRequest, ViewingAppointmentUpsertRequest>
    {
        private readonly IViewingAppointmentService _viewingService;

        public ViewingAppointmentController(IViewingAppointmentService service) : base(service)
        {
            _viewingService = service;
        }

        [AllowAnonymous]
        public override async Task<PagedResult<ViewingAppointmentResponse>> Get([FromQuery] ViewingAppointmentSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<ViewingAppointmentResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpPost("{id}/approve")]
        public async Task<ViewingAppointmentResponse?> Approve(int id, [FromQuery] string? landlordNote = null)
        {
            return await _viewingService.ApproveAsync(id, landlordNote);
        }

        [HttpPost("{id}/reject")]
        public async Task<ViewingAppointmentResponse?> Reject(int id, [FromQuery] string? landlordNote = null)
        {
            return await _viewingService.RejectAsync(id, landlordNote);
        }

        [HttpPost("{id}/cancel")]
        public async Task<ViewingAppointmentResponse?> Cancel(int id)
        {
            return await _viewingService.CancelAsync(id);
        }
    }
}
