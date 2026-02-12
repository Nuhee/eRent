import 'package:erent_desktop/model/viewing_appointment.dart';
import 'package:erent_desktop/providers/base_provider.dart';

class ViewingAppointmentProvider extends BaseProvider<ViewingAppointment> {
  ViewingAppointmentProvider() : super('ViewingAppointment');

  @override
  ViewingAppointment fromJson(dynamic json) {
    return ViewingAppointment.fromJson(json as Map<String, dynamic>);
  }
}
