import 'package:erent_mobile/model/amenity.dart';
import 'package:erent_mobile/providers/base_provider.dart';

class AmenityProvider extends BaseProvider<Amenity> {
  AmenityProvider() : super('Amenity');

  @override
  Amenity fromJson(dynamic json) {
    return Amenity.fromJson(json as Map<String, dynamic>);
  }
}
