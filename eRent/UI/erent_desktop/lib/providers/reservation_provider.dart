import 'package:erent_desktop/model/reservation.dart';
import 'package:erent_desktop/providers/base_provider.dart';

class ReservationProvider extends BaseProvider<Reservation> {
  ReservationProvider() : super("Reservation");

  @override
  Reservation fromJson(dynamic json) {
    return Reservation.fromJson(json);
  }
}

