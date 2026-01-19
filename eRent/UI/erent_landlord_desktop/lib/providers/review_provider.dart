import 'package:erent_landlord_desktop/model/review.dart';
import 'package:erent_landlord_desktop/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super('ReviewRent');

  @override
  Review fromJson(dynamic json) {
    return Review.fromJson(json as Map<String, dynamic>);
  }
}
