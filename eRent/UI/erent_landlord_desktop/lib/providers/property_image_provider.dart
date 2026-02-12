import 'package:erent_landlord_desktop/model/property_image.dart';
import 'package:erent_landlord_desktop/providers/base_provider.dart';

class PropertyImageProvider extends BaseProvider<PropertyImage> {
  PropertyImageProvider() : super('PropertyImage');

  @override
  PropertyImage fromJson(dynamic json) {
    return PropertyImage.fromJson(json as Map<String, dynamic>);
  }
}
