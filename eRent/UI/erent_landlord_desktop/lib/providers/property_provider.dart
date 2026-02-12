import 'package:erent_landlord_desktop/model/property.dart';
import 'package:erent_landlord_desktop/providers/base_provider.dart';

class PropertyProvider extends BaseProvider<Property> {
  PropertyProvider() : super('Property');

  @override
  Property fromJson(dynamic json) {
    return Property.fromJson(json as Map<String, dynamic>);
  }
}
