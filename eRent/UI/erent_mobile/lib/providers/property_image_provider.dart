import 'package:erent_mobile/model/property_image.dart';
import 'package:erent_mobile/providers/base_provider.dart';

class PropertyImageProvider extends BaseProvider<PropertyImage> {
  PropertyImageProvider() : super('PropertyImage');

  @override
  PropertyImage fromJson(dynamic json) {
    return PropertyImage.fromJson(json as Map<String, dynamic>);
  }
}
