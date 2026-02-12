using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using System.Threading.Tasks;

namespace eRent.Services.Interfaces
{
    public interface IViewingAppointmentService : ICRUDService<ViewingAppointmentResponse, ViewingAppointmentSearchObject, ViewingAppointmentUpsertRequest, ViewingAppointmentUpsertRequest>
    {
        Task<ViewingAppointmentResponse?> ApproveAsync(int id, string? landlordNote = null);
        Task<ViewingAppointmentResponse?> RejectAsync(int id, string? landlordNote = null);
        Task<ViewingAppointmentResponse?> CancelAsync(int id);
    }
}
