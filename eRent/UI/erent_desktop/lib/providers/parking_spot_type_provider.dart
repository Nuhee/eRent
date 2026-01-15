import 'package:erent_desktop/model/parking_spot_type.dart';
import 'package:erent_desktop/providers/base_provider.dart';

class ParkingSpotTypeProvider extends BaseProvider<ParkingSpotType> {
  ParkingSpotTypeProvider() : super("ParkingSpotType");

  @override
  ParkingSpotType fromJson(dynamic json) {
    return ParkingSpotType.fromJson(json);
  }
}

