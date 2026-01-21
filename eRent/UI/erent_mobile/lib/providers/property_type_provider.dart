import 'package:erent_mobile/model/property_type.dart';
import 'package:erent_mobile/providers/base_provider.dart';

class PropertyTypeProvider extends BaseProvider<PropertyType> {
  PropertyTypeProvider() : super('PropertyType');

  @override
  PropertyType fromJson(dynamic json) {
    return PropertyType.fromJson(json as Map<String, dynamic>);
  }
}
