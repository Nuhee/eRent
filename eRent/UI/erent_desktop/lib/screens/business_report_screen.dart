import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/business_report.dart';
import 'package:erent_desktop/providers/business_report_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class BusinessReportScreen extends StatefulWidget {
  static const String routeName = 'BusinessReportScreen';
  
  const BusinessReportScreen({super.key});

  @override
  State<BusinessReportScreen> createState() => _BusinessReportScreenState();
}

class _BusinessReportScreenState extends State<BusinessReportScreen> {
  late BusinessReportProvider businessReportProvider;
  BusinessReport? report;
  bool isLoading = true;
  String? errorMessage;

  final Color _brownPrimary = const Color(0xFF8B6F47);
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  final NumberFormat _numberFormat = NumberFormat('#,##0');
  
  // Hover state tracking for charts
  String? _hoveredChart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      businessReportProvider = context.read<BusinessReportProvider>();
      await _loadReport();
    });
  }

  Future<void> _loadReport() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final reportData = await businessReportProvider.getReport();
      
      setState(() {
        report = reportData;
        isLoading = false;
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
      title: 'Business Report',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : report == null
                  ? const Center(child: Text('No data available'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOverallStats(),
                            const SizedBox(height: 20),
                            // Charts Row 1: Pie and Bar Charts
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildRevenueByTypePieChart()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildReservationsByTypeBarChart()),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Charts Row 2: Revenue and Reservations by Zone
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildRevenueByZoneBarChart()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildReservationsByZoneBarChart()),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Charts Row 3: Popular Zones and Donut Chart
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildPopularZonesHorizontalBar()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildReservationsDistributionDonut()),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Detailed Tables
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildRevenueByTypeTable()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildReservationsByTypeTable()),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildRevenueByZoneTable()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildPopularZonesTable()),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildRecentReservations(),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading business report',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red[600]),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unknown error',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadReport,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: _brownPrimary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: _brownPrimary, size: 28),
              const SizedBox(width: 12),
              Text(
                'Overall Statistics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _brownPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Revenue', _currencyFormat.format(report!.totalRevenue), Icons.attach_money, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Total Reservations', _numberFormat.format(report!.totalReservations), Icons.event, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Active Users', _numberFormat.format(report!.activeUsers), Icons.people, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Parking Spots', '${report!.activeParkingSpots}/${report!.totalParkingSpots}', Icons.local_parking, Colors.purple)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Avg. Reservation Price', _currencyFormat.format(report!.averageReservationPrice), Icons.trending_up, Colors.teal)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
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
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Chart Colors
  final List<Color> _chartColors = [
    const Color(0xFF8B6F47), // Brown primary
    const Color(0xFF10B981), // Green
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFF59E0B), // Orange
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEF4444), // Red
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFEC4899), // Pink
  ];

  Color _getChartColor(int index) {
    return _chartColors[index % _chartColors.length];
  }

  Widget _buildRevenueByTypePieChart() {
    if (report!.revenueByReservationType.isEmpty) {
      return _buildCard(
        title: 'Revenue by Reservation Type',
        icon: Icons.pie_chart,
        child: const Center(child: Text('No data available', style: TextStyle(color: Colors.grey))),
        chartId: 'revenue_pie',
      );
    }

    final totalRevenue = report!.revenueByReservationType.fold<double>(0, (sum, item) => sum + item.revenue);
    
    return _buildCard(
      title: 'Revenue by Reservation Type',
      icon: Icons.pie_chart,
      chartId: 'revenue_pie',
      child: SizedBox(
        height: 300,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: report!.revenueByReservationType.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    double percentage = totalRevenue > 0 ? (item.revenue / totalRevenue * 100) : 0;
                    return PieChartSectionData(
                      value: item.revenue,
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: _getChartColor(index),
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: report!.revenueByReservationType.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  final legendKey = 'revenue_pie_legend_$index';
                  final isHovered = _hoveredChart == legendKey;
                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoveredChart = legendKey),
                    onExit: (_) => setState(() => _hoveredChart = null),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(isHovered ? 8 : 0),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isHovered ? _getChartColor(index).withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isHovered ? 20 : 16,
                            height: isHovered ? 20 : 16,
                            decoration: BoxDecoration(
                              color: _getChartColor(index),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isHovered ? [
                                BoxShadow(
                                  color: _getChartColor(index).withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ] : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.reservationTypeName,
                                  style: TextStyle(
                                    fontSize: isHovered ? 13 : 12,
                                    fontWeight: FontWeight.w600,
                                    color: isHovered ? _getChartColor(index) : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _currencyFormat.format(item.revenue),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsByTypeBarChart() {
    if (report!.reservationsByType.isEmpty) {
      return _buildCard(
        title: 'Reservations by Type',
        icon: Icons.bar_chart,
        child: const Center(child: Text('No data available', style: TextStyle(color: Colors.grey))),
        chartId: 'reservations_bar',
      );
    }

    final maxCount = report!.reservationsByType.fold<int>(0, (max, item) => item.count > max ? item.count : max);

    return _buildCard(
      title: 'Reservations by Type',
      icon: Icons.bar_chart,
      chartId: 'reservations_bar',
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxCount * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => _brownPrimary,
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  var item = report!.reservationsByType[groupIndex];
                  return BarTooltipItem(
                    '${item.reservationTypeName}\n${_numberFormat.format(item.count)} reservations',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < report!.reservationsByType.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          report!.reservationsByType[value.toInt()].reservationTypeName,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 50,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _numberFormat.format(value.toInt()),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: report!.reservationsByType.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: item.count.toDouble(),
                    color: _getChartColor(index),
                    width: 30,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueByZoneBarChart() {
    if (report!.revenueByZone.isEmpty) {
      return _buildCard(
        title: 'Revenue by Zone',
        icon: Icons.location_on,
        child: const Center(child: Text('No data available', style: TextStyle(color: Colors.grey))),
        chartId: 'revenue_zone_bar',
      );
    }

    final maxRevenue = report!.revenueByZone.fold<double>(0, (max, item) => item.revenue > max ? item.revenue : max);

    return _buildCard(
      title: 'Revenue by Zone',
      icon: Icons.location_on,
      chartId: 'revenue_zone_bar',
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxRevenue * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => _brownPrimary,
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  var item = report!.revenueByZone[groupIndex];
                  return BarTooltipItem(
                    '${item.zoneName}\n${_currencyFormat.format(item.revenue)}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < report!.revenueByZone.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          report!.revenueByZone[value.toInt()].zoneName,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 50,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${_numberFormat.format(value.toInt())}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: report!.revenueByZone.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: item.revenue,
                    color: _getChartColor(index),
                    width: 30,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationsByZoneBarChart() {
    if (report!.reservationsByZone.isEmpty) {
      return _buildCard(
        title: 'Reservations by Zone',
        icon: Icons.location_city,
        child: const Center(child: Text('No data available', style: TextStyle(color: Colors.grey))),
        chartId: 'reservations_zone_bar',
      );
    }

    final maxCount = report!.reservationsByZone.fold<int>(0, (max, item) => item.count > max ? item.count : max);

    return _buildCard(
      title: 'Reservations by Zone',
      icon: Icons.location_city,
      chartId: 'reservations_zone_bar',
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxCount * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => _brownPrimary,
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  var item = report!.reservationsByZone[groupIndex];
                  return BarTooltipItem(
                    '${item.zoneName}\n${_numberFormat.format(item.count)} reservations',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < report!.reservationsByZone.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          report!.reservationsByZone[value.toInt()].zoneName,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 50,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _numberFormat.format(value.toInt()),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: report!.reservationsByZone.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: item.count.toDouble(),
                    color: _getChartColor(index),
                    width: 30,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularZonesHorizontalBar() {
    if (report!.mostPopularZones.isEmpty) {
      return _buildCard(
        title: 'Most Popular Zones',
        icon: Icons.star,
        child: const Center(child: Text('No data available', style: TextStyle(color: Colors.grey))),
        chartId: 'popular_zones_bar',
      );
    }

    final maxRevenue = report!.mostPopularZones.fold<double>(0, (max, item) => item.totalRevenue > max ? item.totalRevenue : max);

    return _buildCard(
      title: 'Most Popular Zones',
      icon: Icons.star,
      chartId: 'popular_zones_bar',
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxRevenue * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => _brownPrimary,
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  var zone = report!.mostPopularZones[groupIndex];
                  return BarTooltipItem(
                    '${zone.zoneName}\n${_currencyFormat.format(zone.totalRevenue)}\n${zone.reservationCount} reservations',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${_numberFormat.format(value.toInt())}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < report!.mostPopularZones.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${value.toInt() + 1}. ${report!.mostPopularZones[value.toInt()].zoneName}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 50,
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: report!.mostPopularZones.asMap().entries.map((entry) {
              int index = entry.key;
              var zone = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: zone.totalRevenue,
                    color: _getChartColor(index),
                    width: 30,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationsDistributionDonut() {
    if (report!.reservationsByType.isEmpty) {
      return _buildCard(
        title: 'Reservations Distribution',
        icon: Icons.donut_large,
        child: const Center(child: Text('No data available', style: TextStyle(color: Colors.grey))),
        chartId: 'reservations_donut',
      );
    }

    final totalReservations = report!.reservationsByType.fold<int>(0, (sum, item) => sum + item.count);
    
    return _buildCard(
      title: 'Reservations Distribution',
      icon: Icons.donut_large,
      chartId: 'reservations_donut',
      child: SizedBox(
        height: 300,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 80,
                  sections: report!.reservationsByType.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;
                    double percentage = totalReservations > 0 ? (item.count / totalReservations * 100) : 0;
                    return PieChartSectionData(
                      value: item.count.toDouble(),
                      title: '${percentage.toStringAsFixed(1)}%',
                      color: _getChartColor(index),
                      radius: 70,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: report!.reservationsByType.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  final legendKey = 'reservations_donut_legend_$index';
                  final isHovered = _hoveredChart == legendKey;
                  return MouseRegion(
                    onEnter: (_) => setState(() => _hoveredChart = legendKey),
                    onExit: (_) => setState(() => _hoveredChart = null),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(isHovered ? 8 : 0),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isHovered ? _getChartColor(index).withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isHovered ? 20 : 16,
                            height: isHovered ? 20 : 16,
                            decoration: BoxDecoration(
                              color: _getChartColor(index),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isHovered ? [
                                BoxShadow(
                                  color: _getChartColor(index).withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ] : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.reservationTypeName,
                                  style: TextStyle(
                                    fontSize: isHovered ? 13 : 12,
                                    fontWeight: FontWeight.w600,
                                    color: isHovered ? _getChartColor(index) : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${_numberFormat.format(item.count)} reservations',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Table versions for detailed view
  Widget _buildRevenueByTypeTable() {
    return _buildCard(
      title: 'Revenue by Type (Detailed)',
      icon: Icons.table_chart,
      child: report!.revenueByReservationType.isEmpty
          ? const Center(child: Text('No data available', style: TextStyle(color: Colors.grey)))
          : Column(
              children: report!.revenueByReservationType.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getChartColor(index),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.reservationTypeName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        _currencyFormat.format(item.revenue),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _brownPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _brownPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.count}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _brownPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildReservationsByTypeTable() {
    return _buildCard(
      title: 'Reservations by Type (Detailed)',
      icon: Icons.list,
      child: report!.reservationsByType.isEmpty
          ? const Center(child: Text('No data available', style: TextStyle(color: Colors.grey)))
          : Column(
              children: report!.reservationsByType.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getChartColor(index),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.reservationTypeName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _brownPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _numberFormat.format(item.count),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _brownPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildRevenueByZoneTable() {
    return _buildCard(
      title: 'Revenue by Zone (Detailed)',
      icon: Icons.location_on,
      child: report!.revenueByZone.isEmpty
          ? const Center(child: Text('No data available', style: TextStyle(color: Colors.grey)))
          : Column(
              children: report!.revenueByZone.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getChartColor(index),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.zoneName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        _currencyFormat.format(item.revenue),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _brownPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _brownPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.count}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _brownPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildPopularZonesTable() {
    return _buildCard(
      title: 'Most Popular Zones (Detailed)',
      icon: Icons.star,
      child: report!.mostPopularZones.isEmpty
          ? const Center(child: Text('No data available', style: TextStyle(color: Colors.grey)))
          : Column(
              children: report!.mostPopularZones.asMap().entries.map((entry) {
                int index = entry.key;
                PopularZone zone = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _brownPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _brownPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              zone.zoneName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${zone.reservationCount} reservations',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _currencyFormat.format(zone.totalRevenue),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _brownPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }


  Widget _buildRecentReservations() {
    return _buildCard(
      title: 'Recent Reservations',
      icon: Icons.history,
      child: report!.recentReservations.isEmpty
          ? const Center(child: Text('No recent reservations'))
          : Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(1.5),
                5: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: _brownPrimary.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  children: [
                    _buildTableHeader('ID'),
                    _buildTableHeader('Spot'),
                    _buildTableHeader('Zone'),
                    _buildTableHeader('User'),
                    _buildTableHeader('Type'),
                    _buildTableHeader('Price'),
                  ],
                ),
                ...report!.recentReservations.map((reservation) {
                  return TableRow(
                    children: [
                      _buildTableCell('${reservation.id}'),
                      _buildTableCell(reservation.parkingSpotNumber),
                      _buildTableCell(reservation.zoneName),
                      _buildTableCell(reservation.userFullName),
                      _buildTableCell(reservation.reservationTypeName),
                      _buildTableCell(_currencyFormat.format(reservation.finalPrice)),
                    ],
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child, String? chartId}) {
    final isHovered = chartId != null && _hoveredChart == chartId;
    
    return MouseRegion(
      onEnter: chartId != null ? (_) => setState(() => _hoveredChart = chartId) : null,
      onExit: chartId != null ? (_) => setState(() => _hoveredChart = null) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHovered ? _brownPrimary.withOpacity(0.5) : const Color(0xFFE2E8F0),
            width: isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered 
                  ? _brownPrimary.withOpacity(0.2)
                  : _brownPrimary.withOpacity(0.1),
              blurRadius: isHovered ? 30 : 20,
              offset: Offset(0, isHovered ? 12 : 8),
              spreadRadius: isHovered ? 2 : 0,
            ),
          ],
        ),
        transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isHovered ? 8 : 0),
                  child: Icon(
                    icon,
                    color: _brownPrimary,
                    size: isHovered ? 28 : 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _brownPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _brownPrimary,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

