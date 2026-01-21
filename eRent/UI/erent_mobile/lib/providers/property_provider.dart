import 'package:erent_mobile/model/property.dart';
import 'package:erent_mobile/providers/base_provider.dart';

class PropertyProvider extends BaseProvider<Property> {
  PropertyProvider() : super('Property');

  @override
  Property fromJson(dynamic json) {
    return Property.fromJson(json as Map<String, dynamic>);
  }
}
