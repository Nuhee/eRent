import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/analytics.dart';
import 'package:erent_desktop/providers/analytics_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Analytics? analytics;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final provider = context.read<AnalyticsProvider>();
      final data = await provider.getAnalytics();
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
      title: 'Business Analytics',
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Key Metrics Cards
                          _buildKeyMetricsSection(),
                          const SizedBox(height: 24),
                          // Revenue Section
                          _buildRevenueSection(),
                          const SizedBox(height: 24),
                          // Rents Section
                          _buildRentsSection(),
                          const SizedBox(height: 24),
                          // Properties Section
                          _buildPropertiesSection(),
                          const SizedBox(height: 24),
                          // Users Section
                          _buildUsersSection(),
                          const SizedBox(height: 24),
                          // Reviews Section
                          _buildReviewsSection(),
                          const SizedBox(height: 24),
                          // Growth Trends
                          _buildGrowthTrendsSection(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildKeyMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Revenue',
                '${analytics!.totalRevenue.toStringAsFixed(2)} BAM',
                Icons.attach_money_rounded,
                const Color(0xFF5B9BD5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Monthly Revenue',
                '${analytics!.monthlyRevenue.toStringAsFixed(2)} BAM',
                Icons.trending_up_rounded,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Total Properties',
                analytics!.totalProperties.toString(),
                Icons.home_rounded,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Total Rents',
                analytics!.totalRents.toString(),
                Icons.receipt_long_rounded,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
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
    );
  }

  Widget _buildRevenueSection() {
    return _buildSectionCard(
      title: 'Revenue Analytics',
      icon: Icons.attach_money_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Average Rent Price',
                '${analytics!.averageRentPrice.toStringAsFixed(2)} BAM',
                Icons.calculate_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildChartCard(
                'Revenue by Property Type',
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
                _buildRevenueByCityChart(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildChartCard(
                'Monthly Revenue Trend',
                _buildMonthlyRevenueChart(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRentsSection() {
    return _buildSectionCard(
      title: 'Rent Analytics',
      icon: Icons.receipt_long_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Active Rents',
                analytics!.activeRents.toString(),
                Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Occupancy Rate',
                '${analytics!.occupancyRate.toStringAsFixed(1)}%',
                Icons.hotel_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Avg Rental Duration',
                '${analytics!.averageRentalDuration.toStringAsFixed(1)} days',
                Icons.calendar_today_rounded,
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
                _buildRentStatusChart(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildChartCard(
                'Daily vs Monthly',
                _buildRentalTypeChart(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertiesSection() {
    return _buildSectionCard(
      title: 'Property Analytics',
      icon: Icons.home_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Active Properties',
                analytics!.activeProperties.toString(),
                Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Inactive Properties',
                analytics!.inactiveProperties.toString(),
                Icons.cancel_rounded,
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
                _buildPropertiesByTypeChart(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildChartCard(
                'Properties by City',
                _buildPropertiesByCityChart(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersSection() {
    return _buildSectionCard(
      title: 'User Analytics',
      icon: Icons.people_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Total Users',
                analytics!.totalUsers.toString(),
                Icons.people_outline_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Active Users',
                analytics!.activeUsers.toString(),
                Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Landlords',
                analytics!.totalLandlords.toString(),
                Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Tenants',
                analytics!.totalTenants.toString(),
                Icons.person_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'User Growth Trend',
          _buildUserGrowthChart(),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return _buildSectionCard(
      title: 'Review Analytics',
      icon: Icons.star_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Total Reviews',
                analytics!.totalReviews.toString(),
                Icons.rate_review_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Average Rating',
                analytics!.averageRating.toStringAsFixed(2),
                Icons.star_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          'Rating Distribution',
          _buildRatingDistributionChart(),
        ),
      ],
    );
  }

  Widget _buildGrowthTrendsSection() {
    return _buildSectionCard(
      title: 'Growth Trends',
      icon: Icons.trending_up_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildChartCard(
                'Property Growth',
                _buildPropertyGrowthChart(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildChartCard(
                'Rent Growth',
                _buildRentGrowthChart(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF5B9BD5), size: 20),
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
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
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
              Icon(icon, size: 20, color: const Color(0xFF5B9BD5)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
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
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
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
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
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
            const Color(0xFF5B9BD5),
            Colors.green,
            Colors.orange,
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
                color: const Color(0xFF5B9BD5),
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
            color: const Color(0xFF5B9BD5),
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF5B9BD5).withOpacity(0.1),
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
      {'name': 'Pending', 'value': analytics!.pendingRents, 'color': Colors.orange},
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
                color: Colors.orange,
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

  Widget _buildUserGrowthChart() {
    if (analytics!.monthlyUserGrowth.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    final maxUsers = analytics!.monthlyUserGrowth
        .map((e) => e.totalUsers)
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
                if (value.toInt() >= analytics!.monthlyUserGrowth.length) {
                  return const Text('');
                }
                final month = analytics!.monthlyUserGrowth[value.toInt()].month;
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
            spots: analytics!.monthlyUserGrowth.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.totalUsers.toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: maxUsers * 1.2,
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
          final colors = [Colors.green, Colors.lightGreen, Colors.orange, Colors.deepOrange, Colors.red];
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
            color: Colors.orange,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
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
