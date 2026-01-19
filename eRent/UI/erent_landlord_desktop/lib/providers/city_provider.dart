import 'package:erent_landlord_desktop/model/city.dart';
import 'package:erent_landlord_desktop/providers/base_provider.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(dynamic json) {
    return City.fromJson(json);
  }
}
