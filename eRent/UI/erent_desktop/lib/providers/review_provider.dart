import 'package:erent_desktop/model/review.dart';
import 'package:erent_desktop/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super('Review');

  @override
  Review fromJson(dynamic json) {
    return Review.fromJson(json as Map<String, dynamic>);
  }
}
