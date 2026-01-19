import 'package:erent_landlord_desktop/model/rent.dart';
import 'package:erent_landlord_desktop/providers/base_provider.dart';

class RentProvider extends BaseProvider<Rent> {
  RentProvider() : super('Rent');

  @override
  Rent fromJson(dynamic json) {
    return Rent.fromJson(json as Map<String, dynamic>);
  }
}
