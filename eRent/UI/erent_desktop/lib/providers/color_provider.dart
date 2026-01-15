import 'package:erent_desktop/model/color.dart';
import 'package:erent_desktop/providers/base_provider.dart';

class ColorProvider extends BaseProvider<CarColor> {
  ColorProvider() : super("Color");

  @override
  CarColor fromJson(dynamic json) {
    return CarColor.fromJson(json);
  }
}

