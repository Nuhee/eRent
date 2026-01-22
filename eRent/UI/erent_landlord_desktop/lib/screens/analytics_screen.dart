import 'package:flutter/material.dart';
import 'package:erent_landlord_desktop/layouts/master_screen.dart';
import 'package:erent_landlord_desktop/model/landlord_analytics.dart';
import 'package:erent_landlord_desktop/providers/landlord_analytics_provider.dart';
import 'package:erent_landlord_desktop/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  LandlordAnalytics? analytics;
  bool isLoading = true;
  String? errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    try {
      final landlordId = UserProvider.currentUser?.id;
      if (landlordId == null) {
        setState(() {
          isLoading = false;
          errorMessage = "User not authenticated. Please login again.";
        });
        return;
      }
      final provider = context.read<LandlordAnalyticsProvider>();
      final data = await provider.getLandlordAnalytics(landlordId);
      setState(() {
        analytics = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'My Business Analytics',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading analytics',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadAnalytics,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : analytics == null
                  ? const Center(child: Text('No data available'))
                  : Column(
                      children: [
                        // Tab Bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: const Color(0xFFFFB84D),
                            unselectedLabelColor: Colors.grey[600],
                            indicatorColor: const Color(0xFFFFB84D),
                            indicatorWeight: 3,
                            tabs: const [
                              Tab(text: 'Overview', icon: Icon(Icons.dashboard_rounded, size: 20)),
                              Tab(text: 'Revenue', icon: Icon(Icons.attach_money_rounded, size: 20)),
                              Tab(text: 'Rents', icon: Icon(Icons.receipt_long_rounded, size: 20)),
                              Tab(text: 'Properties', icon: Icon(Icons.home_rounded, size: 20)),
                              Tab(text: 'Reviews', icon: Icon(Icons.star_rounded, size: 20)),
                              Tab(text: 'Growth', icon: Icon(Icons.trending_up_rounded, size: 20)),
                            ],
                          ),
                        ),
                        // Tab Content
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildOverviewSection(),
                              _buildRevenueSection(),
                              _buildRentsSection(),
                              _buildPropertiesSection(),
                              _buildReviewsSection(),
                              _buildGrowthTrendsSection(),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildOverviewSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'My Key Metrics',
            Icons.dashboard_rounded,
            'Overview of your business performance. These metrics show revenue, properties, and rents for your listings only.',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Revenue',
                  '€${analytics!.totalRevenue.toStringAsFixed(2)}',
                  Icons.attach_money_rounded,
                  const Color(0xFFFFB84D),
                  'Total revenue from all paid rents for your properties since the beginning. This represents your cumulative income from completed rental transactions.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Monthly Revenue',
                  '€${analytics!.monthlyRevenue.toStringAsFixed(2)}',
                  Icons.trending_up_rounded,
                  Colors.green,
                  'Revenue generated from paid rents for your properties in the current month. This helps track your recent business performance.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Total Properties',
                  analytics!.totalProperties.toString(),
                  Icons.home_rounded,
                  const Color(0xFFFFB84D),
                  'Total number of your properties, including both active and inactive listings.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Total Rents',
                  analytics!.totalRents.toString(),
                  Icons.receipt_long_rounded,
                  Colors.purple,
                  'Total number of rental transactions for your properties, regardless of their status.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Active Rents',
                  analytics!.activeRents.toString(),
                  Icons.check_circle_rounded,
                  Colors.teal,
                  'Number of rental transactions that are currently active (ongoing rentals).',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Active Properties',
                  analytics!.activeProperties.toString(),
                  Icons.home_work_rounded,
                  Colors.blue,
                  'Properties currently available for rent and visible to users.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  'Average Rating',
                  '${analytics!.averageRating.toStringAsFixed(2)} / 5.0',
                  Icons.star_rounded,
                  Colors.amber,
                  'Average rating across all reviews for your properties. Higher ratings indicate better tenant satisfaction.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Revenue Analytics',
            Icons.attach_money_rounded,
            'Detailed analysis of your revenue generation, including breakdowns by property type, city, and monthly trends.',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Average Rent Price',
                  '€${analytics!.averageRentPrice.toStringAsFixed(2)}',
                  Icons.calculate_rounded,
                  'The average price of all paid rental transactions. This helps understand pricing trends and market positioning.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Revenue by Property Type',
                  'Shows how revenue is distributed across different property types. Larger segments indicate higher revenue generation.',
                  _buildRevenueByPropertyTypeChart(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildChartCard(
                  'Revenue by City',
                  'Top 5 cities ranked by total revenue. This helps identify the most profitable locations.',
                  _buildRevenueByCityChart(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Monthly Revenue Trend',
                  'Revenue trend over the last 12 months. The line shows how revenue has changed over time, helping identify growth patterns.',
                  _buildMonthlyRevenueChart(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRentsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Rent Analytics',
            Icons.receipt_long_rounded,
            'Comprehensive analysis of rental transactions for your properties, including status distribution, rental types, and occupancy metrics.',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Active Rents',
                  analytics!.activeRents.toString(),
                  Icons.check_circle_rounded,
                  'Number of rental transactions that are currently active (ongoing rentals).',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Occupancy Rate',
                  '${analytics!.occupancyRate.toStringAsFixed(1)}%',
                  Icons.hotel_rounded,
                  'Percentage of active properties that are currently rented. Higher rates indicate better property utilization.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Avg Rental Duration',
                  '${analytics!.averageRentalDuration.toStringAsFixed(1)} days',
                  Icons.calendar_today_rounded,
                  'Average number of days for completed rental periods. This helps understand typical rental patterns.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Pending Rents',
                  analytics!.pendingRents.toString(),
                  Icons.pending_actions_rounded,
                  'Rental requests awaiting approval or payment.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Paid Rents',
                  analytics!.paidRents.toString(),
                  Icons.payment_rounded,
                  'Rentals that have been fully paid and completed.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Cancelled Rents',
                  analytics!.cancelledRents.toString(),
                  Icons.cancel_rounded,
                  'Rentals that were cancelled before completion.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildChartCard(
                  'Rents by Status',
                  'Distribution of rentals across different statuses. This shows the breakdown of pending, paid, accepted, cancelled, and rejected rentals.',
                  _buildRentStatusChart(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Daily vs Monthly Rentals',
                  'Comparison between daily and monthly rental types. This shows which rental model is more popular.',
                  _buildRentalTypeChart(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Property Analytics',
            Icons.home_rounded,
            'Analysis of your property inventory, including distribution by type, city, and status.',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Active Properties',
                  analytics!.activeProperties.toString(),
                  Icons.check_circle_rounded,
                  'Properties currently available for rent and visible to users.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Inactive Properties',
                  analytics!.inactiveProperties.toString(),
                  Icons.cancel_rounded,
                  'Properties that are temporarily or permanently unavailable for rent.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildChartCard(
                  'Properties by Type',
                  'Distribution of properties across different types (e.g., Apartment, House, Studio). Shows which property types are most common.',
                  _buildPropertiesByTypeChart(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Properties by City',
                  'Top 5 cities ranked by number of properties. Helps identify where most listings are located.',
                  _buildPropertiesByCityChart(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Review Analytics',
            Icons.star_rounded,
            'Analysis of reviews and ratings for your properties, including average rating and distribution across different rating levels.',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Total Reviews',
                  analytics!.totalReviews.toString(),
                  Icons.rate_review_rounded,
                  'Total number of reviews submitted by tenants for your rental properties.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Average Rating',
                  '${analytics!.averageRating.toStringAsFixed(2)} / 5.0',
                  Icons.star_rounded,
                  'Average rating across all reviews for your properties. Higher ratings indicate better tenant satisfaction.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  '5 Star Reviews',
                  analytics!.rating5Count.toString(),
                  Icons.star,
                  'Number of reviews with the highest rating (5 stars).',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  '4 Star Reviews',
                  analytics!.rating4Count.toString(),
                  Icons.star,
                  'Number of reviews with 4-star rating.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  '3 Star Reviews',
                  analytics!.rating3Count.toString(),
                  Icons.star,
                  'Number of reviews with 3-star (average) rating.',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  '1-2 Star Reviews',
                  '${analytics!.rating1Count + analytics!.rating2Count}',
                  Icons.star,
                  'Number of reviews with low ratings (1-2 stars).',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildChartCard(
            'Rating Distribution',
            'Visual breakdown of reviews by rating. Green bars indicate positive reviews, while red bars show areas needing improvement.',
            _buildRatingDistributionChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthTrendsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Growth Trends',
            Icons.trending_up_rounded,
            'Long-term growth analysis showing how your properties and rents have grown over the last 12 months.',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildChartCard(
                  'Property Growth Trend',
                  'Shows the cumulative number of properties added over time. The line represents total properties, helping track inventory growth.',
                  _buildPropertyGrowthChart(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildChartCard(
                  'Rent Growth Trend',
                  'Shows the cumulative number of rental transactions over time. Helps track business activity and demand trends.',
                  _buildRentGrowthChart(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB84D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFFFFB84D), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[100]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFFFFB84D)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, String description, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Tooltip(
                message: description,
                child: Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildRevenueByPropertyTypeChart() {
    if (analytics!.revenueByPropertyType.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    return PieChart(
      PieChartData(
        sections: analytics!.revenueByPropertyType.asMap().entries.map((entry) {
          final colors = [
            const Color(0xFFFFB84D),
            Colors.green,
            const Color(0xFFFFB84D),
            Colors.purple,
            Colors.red,
            Colors.teal,
          ];
          return PieChartSectionData(
            value: entry.value.revenue,
            title: entry.value.propertyTypeName.length > 10
                ? '${entry.value.propertyTypeName.substring(0, 10)}...'
                : entry.value.propertyTypeName,
            color: colors[entry.key % colors.length],
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildRevenueByCityChart() {
    if (analytics!.revenueByCity.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    final topCities = analytics!.revenueByCity.take(5).toList();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: topCities.isNotEmpty
            ? topCities.map((e) => e.revenue).reduce((a, b) => a > b ? a : b) * 1.2
            : 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= topCities.length) return const Text('');
                final city = topCities[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    city.cityName.length > 8
                        ? '${city.cityName.substring(0, 8)}...'
                        : city.cityName,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: topCities.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.revenue,
                color: const Color(0xFFFFB84D),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyRevenueChart() {
    if (analytics!.monthlyRevenueTrend.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    final maxRevenue = analytics!.monthlyRevenueTrend
        .map((e) => e.revenue)
        .reduce((a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= analytics!.monthlyRevenueTrend.length) {
                  return const Text('');
                }
                final month = analytics!.monthlyRevenueTrend[value.toInt()].month;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    month.substring(5),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: analytics!.monthlyRevenueTrend.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.revenue);
            }).toList(),
            isCurved: true,
            color: const Color(0xFFFFB84D),
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFFFB84D).withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: maxRevenue * 1.2,
      ),
    );
  }

  Widget _buildRentStatusChart() {
    final statusData = [
      {'name': 'Pending', 'value': analytics!.pendingRents, 'color': const Color(0xFFFFB84D)},
      {'name': 'Paid', 'value': analytics!.paidRents, 'color': Colors.green},
      {'name': 'Accepted', 'value': analytics!.acceptedRents, 'color': Colors.blue},
      {'name': 'Cancelled', 'value': analytics!.cancelledRents, 'color': Colors.red},
      {'name': 'Rejected', 'value': analytics!.rejectedRents, 'color': Colors.red[700]!},
    ];
    final total = statusData.fold<int>(0, (sum, item) => sum + (item['value'] as int));
    if (total == 0) {
      return const Center(child: Text('No data available'));
    }
    return PieChart(
      PieChartData(
        sections: statusData.map((item) {
          final value = item['value'] as int;
          return PieChartSectionData(
            value: value.toDouble(),
            title: value > 0 ? '${((value / total) * 100).toStringAsFixed(0)}%' : '',
            color: item['color'] as Color,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildRentalTypeChart() {
    final total = analytics!.dailyRentals + analytics!.monthlyRentals;
    if (total == 0) {
      return const Center(child: Text('No data available'));
    }
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: analytics!.dailyRentals.toDouble(),
            title: 'Daily\n${((analytics!.dailyRentals / total) * 100).toStringAsFixed(0)}%',
            color: Colors.blue,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: analytics!.monthlyRentals.toDouble(),
            title: 'Monthly\n${((analytics!.monthlyRentals / total) * 100).toStringAsFixed(0)}%',
            color: Colors.green,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildPropertiesByTypeChart() {
    if (analytics!.propertiesByType.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    final topTypes = analytics!.propertiesByType.take(5).toList();
    final maxCount = topTypes.isNotEmpty
        ? topTypes.map((e) => e.count).reduce((a, b) => a > b ? a : b)
        : 10;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxCount * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= topTypes.length) return const Text('');
                final type = topTypes[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    type.propertyTypeName.length > 8
                        ? '${type.propertyTypeName.substring(0, 8)}...'
                        : type.propertyTypeName,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: topTypes.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.count.toDouble(),
                color: const Color(0xFFFFB84D),
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPropertiesByCityChart() {
    if (analytics!.propertiesByCity.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    final topCities = analytics!.propertiesByCity.take(5).toList();
    final maxCount = topCities.isNotEmpty
        ? topCities.map((e) => e.count).reduce((a, b) => a > b ? a : b)
        : 10;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxCount * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= topCities.length) return const Text('');
                final city = topCities[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    city.cityName.length > 8
                        ? '${city.cityName.substring(0, 8)}...'
                        : city.cityName,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: topCities.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.count.toDouble(),
                color: Colors.purple,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRatingDistributionChart() {
    final ratingData = [
      analytics!.rating5Count,
      analytics!.rating4Count,
      analytics!.rating3Count,
      analytics!.rating2Count,
      analytics!.rating1Count,
    ];
    final maxRating = ratingData.reduce((a, b) => a > b ? a : b);
    if (maxRating == 0) {
      return const Center(child: Text('No data available'));
    }
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxRating * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final ratings = ['5★', '4★', '3★', '2★', '1★'];
                if (value.toInt() >= ratings.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    ratings[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: ratingData.asMap().entries.map((entry) {
          final colors = [Colors.green, Colors.lightGreen, const Color(0xFFFFB84D), Colors.deepOrange, Colors.red];
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: colors[entry.key],
                width: 30,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPropertyGrowthChart() {
    if (analytics!.monthlyPropertyGrowth.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    final maxProperties = analytics!.monthlyPropertyGrowth
        .map((e) => e.totalProperties)
        .reduce((a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= analytics!.monthlyPropertyGrowth.length) {
                  return const Text('');
                }
                final month = analytics!.monthlyPropertyGrowth[value.toInt()].month;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    month.substring(5),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: analytics!.monthlyPropertyGrowth.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.totalProperties.toDouble());
            }).toList(),
            isCurved: true,
            color: const Color(0xFFFFB84D),
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFFFFB84D).withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: maxProperties * 1.2,
      ),
    );
  }

  Widget _buildRentGrowthChart() {
    if (analytics!.monthlyRentGrowth.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    final maxRents = analytics!.monthlyRentGrowth
        .map((e) => e.totalRents)
        .reduce((a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= analytics!.monthlyRentGrowth.length) {
                  return const Text('');
                }
                final month = analytics!.monthlyRentGrowth[value.toInt()].month;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    month.substring(5),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: analytics!.monthlyRentGrowth.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.totalRents.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: maxRents * 1.2,
      ),
    );
  }
}
