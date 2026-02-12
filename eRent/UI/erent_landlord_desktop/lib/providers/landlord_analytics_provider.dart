import 'package:erent_landlord_desktop/model/landlord_analytics.dart';
import 'package:erent_landlord_desktop/providers/base_provider.dart';

class LandlordAnalyticsProvider extends BaseProvider<LandlordAnalytics> {
  LandlordAnalyticsProvider() : super("LandlordAnalytics");

  @override
  LandlordAnalytics fromJson(dynamic json) {
    return LandlordAnalytics.fromJson(json);
  }

  Future<LandlordAnalytics> getLandlordAnalytics(int landlordId) async {
    final result = await getById(landlordId);
    if (result == null) {
      throw Exception("Failed to fetch landlord analytics");
    }
    return result;
  }
}
