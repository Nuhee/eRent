import 'package:erent_desktop/model/reservation_type.dart';
import 'package:erent_desktop/providers/base_provider.dart';

class ReservationTypeProvider extends BaseProvider<ReservationType> {
  ReservationTypeProvider() : super("ReservationType");

  @override
  ReservationType fromJson(dynamic json) {
    return ReservationType.fromJson(json);
  }
}

