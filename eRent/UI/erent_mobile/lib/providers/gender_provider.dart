import 'package:erent_mobile/model/gender.dart';
import 'package:erent_mobile/providers/base_provider.dart';

class GenderProvider extends BaseProvider<Gender> {
  GenderProvider() : super('Gender');

  @override
  Gender fromJson(dynamic json) {
    return Gender.fromJson(json as Map<String, dynamic>);
  }
}
