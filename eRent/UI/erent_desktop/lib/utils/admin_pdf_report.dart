import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erent_desktop/model/analytics.dart';
import 'package:intl/intl.dart';

class AdminPdfReport {
  static const _primary = PdfColor.fromInt(0xFF5B9BD5);
  static const _primaryDark = PdfColor.fromInt(0xFF3A7BBD);
  static const _accent = PdfColor.fromInt(0xFF2ECC71);
  static const _dark = PdfColor.fromInt(0xFF1F2937);
  static const _grey = PdfColor.fromInt(0xFF6B7280);
  static const _lightBg = PdfColor.fromInt(0xFFF8FAFC);
  static const _white = PdfColors.white;
  static const _tableBorder = PdfColor.fromInt(0xFFE5E7EB);

  static Future<void> generateAndPrint(Analytics analytics) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.interRegular(),
        bold: await PdfGoogleFonts.interBold(),
        italic: await PdfGoogleFonts.interItalic(),
        boldItalic: await PdfGoogleFonts.interBoldItalic(),
      ),
    );

    final now = DateTime.now();
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(now);

    // PAGE 1: Executive Summary
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader('Platform Analytics Report', dateStr),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildExecutiveSummary(analytics),
          pw.SizedBox(height: 20),
          _buildRevenueSection(analytics),
          pw.SizedBox(height: 20),
          _buildRentalOperationsSection(analytics),
          pw.SizedBox(height: 20),
          _buildPropertyPortfolioSection(analytics),
          pw.SizedBox(height: 20),
          _buildUserBaseSection(analytics),
          pw.SizedBox(height: 20),
          _buildReviewsSection(analytics),
          pw.SizedBox(height: 20),
          _buildMonthlyTrendsSection(analytics),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'eRent_Admin_Report_${DateFormat('yyyyMMdd_HHmm').format(now)}',
    );
  }

  // ─── HEADER & FOOTER ─────────────────────────────────────────────

  static pw.Widget _buildHeader(String title, String date) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'eRent',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: _primary,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 14,
                  color: _dark,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated: $date',
                style: const pw.TextStyle(fontSize: 9, color: _grey),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Admin Dashboard Report',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: _grey,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _tableBorder, width: 0.5)),
      ),
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'eRent Platform - Confidential',
            style: pw.TextStyle(fontSize: 8, color: _grey, fontStyle: pw.FontStyle.italic),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _grey),
          ),
        ],
      ),
    );
  }

  // ─── SECTION: EXECUTIVE SUMMARY ──────────────────────────────────

  static pw.Widget _buildExecutiveSummary(Analytics a) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Executive Summary'),
        pw.SizedBox(height: 12),
        pw.Row(
          children: [
            _kpiCard('Total Revenue', _eur(a.totalRevenue), _primary),
            pw.SizedBox(width: 10),
            _kpiCard('Monthly Revenue', _eur(a.monthlyRevenue), _accent),
            pw.SizedBox(width: 10),
            _kpiCard('Total Properties', a.totalProperties.toString(), PdfColor.fromInt(0xFFF59E0B)),
            pw.SizedBox(width: 10),
            _kpiCard('Total Rents', a.totalRents.toString(), PdfColor.fromInt(0xFF8B5CF6)),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            _kpiCard('Active Rents', a.activeRents.toString(), PdfColor.fromInt(0xFF14B8A6)),
            pw.SizedBox(width: 10),
            _kpiCard('Active Properties', a.activeProperties.toString(), PdfColor.fromInt(0xFF3B82F6)),
            pw.SizedBox(width: 10),
            _kpiCard('Total Users', a.totalUsers.toString(), PdfColor.fromInt(0xFF6366F1)),
            pw.SizedBox(width: 10),
            _kpiCard('Avg Rating', '${a.averageRating.toStringAsFixed(1)} / 5.0', PdfColor.fromInt(0xFFF59E0B)),
          ],
        ),
      ],
    );
  }

  // ─── SECTION: REVENUE ────────────────────────────────────────────

  static pw.Widget _buildRevenueSection(Analytics a) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Revenue Analysis'),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _buildMiniStat('Total Revenue', _eur(a.totalRevenue)),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _buildMiniStat('Monthly Revenue', _eur(a.monthlyRevenue)),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: _buildMiniStat('Avg Rent Price', _eur(a.averageRentPrice)),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        // Revenue by Property Type table
        if (a.revenueByPropertyType.isNotEmpty) ...[
          _subSectionTitle('Revenue by Property Type'),
          pw.SizedBox(height: 6),
          _buildStyledTable(
            headers: ['Property Type', 'Revenue', 'Rent Count'],
            rows: a.revenueByPropertyType
                .map((e) => [e.propertyTypeName, _eur(e.revenue), e.rentCount.toString()])
                .toList(),
          ),
          pw.SizedBox(height: 12),
        ],
        // Revenue by City table
        if (a.revenueByCity.isNotEmpty) ...[
          _subSectionTitle('Revenue by City (Top 5)'),
          pw.SizedBox(height: 6),
          _buildStyledTable(
            headers: ['City', 'Revenue', 'Rent Count'],
            rows: a.revenueByCity
                .take(5)
                .map((e) => [e.cityName, _eur(e.revenue), e.rentCount.toString()])
                .toList(),
          ),
        ],
      ],
    );
  }

  // ─── SECTION: RENTAL OPERATIONS ──────────────────────────────────

  static pw.Widget _buildRentalOperationsSection(Analytics a) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Rental Operations'),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(child: _buildMiniStat('Occupancy Rate', '${a.occupancyRate.toStringAsFixed(1)}%')),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildMiniStat('Avg Duration', '${a.averageRentalDuration.toStringAsFixed(1)} days')),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildMiniStat('Daily Rentals', a.dailyRentals.toString())),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildMiniStat('Monthly Rentals', a.monthlyRentals.toString())),
          ],
        ),
        pw.SizedBox(height: 12),
        _subSectionTitle('Rent Status Breakdown'),
        pw.SizedBox(height: 6),
        _buildStyledTable(
          headers: ['Status', 'Count', 'Percentage'],
          rows: _rentStatusRows(a),
        ),
      ],
    );
  }

  static List<List<String>> _rentStatusRows(Analytics a) {
    final total = a.totalRents > 0 ? a.totalRents : 1;
    String pct(int v) => '${(v / total * 100).toStringAsFixed(1)}%';
    return [
      ['Active', a.activeRents.toString(), pct(a.activeRents)],
      ['Pending', a.pendingRents.toString(), pct(a.pendingRents)],
      ['Paid', a.paidRents.toString(), pct(a.paidRents)],
      ['Accepted', a.acceptedRents.toString(), pct(a.acceptedRents)],
      ['Cancelled', a.cancelledRents.toString(), pct(a.cancelledRents)],
      ['Rejected', a.rejectedRents.toString(), pct(a.rejectedRents)],
    ];
  }

  // ─── SECTION: PROPERTY PORTFOLIO ─────────────────────────────────

  static pw.Widget _buildPropertyPortfolioSection(Analytics a) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Property Portfolio'),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(child: _buildMiniStat('Total', a.totalProperties.toString())),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildMiniStat('Active', a.activeProperties.toString())),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildMiniStat('Inactive', a.inactiveProperties.toString())),
          ],
        ),
        pw.SizedBox(height: 12),
        if (a.propertiesByType.isNotEmpty) ...[
          _subSectionTitle('Properties by Type'),
          pw.SizedBox(height: 6),
          _buildStyledTable(
            headers: ['Type', 'Total', 'Active'],
            rows: a.propertiesByType
                .map((e) => [e.propertyTypeName, e.count.toString(), e.activeCount.toString()])
                .toList(),
          ),
          pw.SizedBox(height: 12),
        ],
        if (a.propertiesByCity.isNotEmpty) ...[
          _subSectionTitle('Properties by City (Top 5)'),
          pw.SizedBox(height: 6),
          _buildStyledTable(
            headers: ['City', 'Total', 'Active'],
            rows: a.propertiesByCity
                .take(5)
                .map((e) => [e.cityName, e.count.toString(), e.activeCount.toString()])
                .toList(),
          ),
        ],
      ],
    );
  }

  // ─── SECTION: USER BASE ──────────────────────────────────────────

  static pw.Widget _buildUserBaseSection(Analytics a) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('User Base'),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(child: _buildMiniStat('Total Users', a.totalUsers.toString())),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildMiniStat('Active Users', a.activeUsers.toString())),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildMiniStat('Landlords', a.totalLandlords.toString())),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildMiniStat('Tenants', a.totalTenants.toString())),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildMiniStat('Admins', a.totalAdmins.toString())),
          ],
        ),
      ],
    );
  }

  // ─── SECTION: REVIEWS ────────────────────────────────────────────

  static pw.Widget _buildReviewsSection(Analytics a) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Reviews & Ratings'),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            pw.Expanded(child: _buildMiniStat('Total Reviews', a.totalReviews.toString())),
            pw.SizedBox(width: 8),
            pw.Expanded(child: _buildMiniStat('Avg Rating', '${a.averageRating.toStringAsFixed(2)} / 5.0')),
          ],
        ),
        pw.SizedBox(height: 12),
        _subSectionTitle('Rating Distribution'),
        pw.SizedBox(height: 6),
        _buildStyledTable(
          headers: ['Rating', 'Count', 'Percentage'],
          rows: _ratingRows(a),
        ),
        pw.SizedBox(height: 8),
        _buildRatingBar(a),
      ],
    );
  }

  static List<List<String>> _ratingRows(Analytics a) {
    final total = a.totalReviews > 0 ? a.totalReviews : 1;
    String pct(int v) => '${(v / total * 100).toStringAsFixed(1)}%';
    return [
      ['5 Stars', a.rating5Count.toString(), pct(a.rating5Count)],
      ['4 Stars', a.rating4Count.toString(), pct(a.rating4Count)],
      ['3 Stars', a.rating3Count.toString(), pct(a.rating3Count)],
      ['2 Stars', a.rating2Count.toString(), pct(a.rating2Count)],
      ['1 Star', a.rating1Count.toString(), pct(a.rating1Count)],
    ];
  }

  static pw.Widget _buildRatingBar(Analytics a) {
    final total = a.totalReviews > 0 ? a.totalReviews : 1;
    final segments = [
      _BarSegment(a.rating5Count / total, PdfColor.fromInt(0xFF22C55E)),
      _BarSegment(a.rating4Count / total, PdfColor.fromInt(0xFF84CC16)),
      _BarSegment(a.rating3Count / total, PdfColor.fromInt(0xFFF59E0B)),
      _BarSegment(a.rating2Count / total, PdfColor.fromInt(0xFFEF4444)),
      _BarSegment(a.rating1Count / total, PdfColor.fromInt(0xFFDC2626)),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          height: 12,
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.ClipRRect(
            horizontalRadius: 6,
            verticalRadius: 6,
            child: pw.Row(
              children: segments
                  .where((s) => s.fraction > 0)
                  .map((s) => pw.Expanded(
                        flex: (s.fraction * 1000).round().clamp(1, 1000),
                        child: pw.Container(color: s.color),
                      ))
                  .toList(),
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            _legendDot(PdfColor.fromInt(0xFF22C55E), '5'),
            pw.SizedBox(width: 8),
            _legendDot(PdfColor.fromInt(0xFF84CC16), '4'),
            pw.SizedBox(width: 8),
            _legendDot(PdfColor.fromInt(0xFFF59E0B), '3'),
            pw.SizedBox(width: 8),
            _legendDot(PdfColor.fromInt(0xFFEF4444), '2'),
            pw.SizedBox(width: 8),
            _legendDot(PdfColor.fromInt(0xFFDC2626), '1'),
          ],
        ),
      ],
    );
  }

  // ─── SECTION: MONTHLY TRENDS ─────────────────────────────────────

  static pw.Widget _buildMonthlyTrendsSection(Analytics a) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Monthly Trends (Last 12 Months)'),
        pw.SizedBox(height: 8),
        if (a.monthlyRevenueTrend.isNotEmpty) ...[
          _subSectionTitle('Monthly Revenue'),
          pw.SizedBox(height: 6),
          _buildStyledTable(
            headers: ['Month', 'Revenue', 'Rent Count'],
            rows: a.monthlyRevenueTrend
                .map((e) => [e.month, _eur(e.revenue), e.rentCount.toString()])
                .toList(),
          ),
          pw.SizedBox(height: 12),
        ],
        if (a.monthlyUserGrowth.isNotEmpty) ...[
          _subSectionTitle('User Growth'),
          pw.SizedBox(height: 6),
          _buildStyledTable(
            headers: ['Month', 'New Users', 'Total Users'],
            rows: a.monthlyUserGrowth
                .map((e) => [e.month, e.newUsers.toString(), e.totalUsers.toString()])
                .toList(),
          ),
          pw.SizedBox(height: 12),
        ],
        if (a.monthlyPropertyGrowth.isNotEmpty) ...[
          _subSectionTitle('Property Growth'),
          pw.SizedBox(height: 6),
          _buildStyledTable(
            headers: ['Month', 'New Properties', 'Total Properties'],
            rows: a.monthlyPropertyGrowth
                .map((e) => [e.month, e.newProperties.toString(), e.totalProperties.toString()])
                .toList(),
          ),
          pw.SizedBox(height: 12),
        ],
        if (a.monthlyRentGrowth.isNotEmpty) ...[
          _subSectionTitle('Rent Growth'),
          pw.SizedBox(height: 6),
          _buildStyledTable(
            headers: ['Month', 'New Rents', 'Total Rents'],
            rows: a.monthlyRentGrowth
                .map((e) => [e.month, e.newRents.toString(), e.totalRents.toString()])
                .toList(),
          ),
        ],
      ],
    );
  }

  // ─── REUSABLE COMPONENTS ─────────────────────────────────────────

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          color: _white,
        ),
      ),
    );
  }

  static pw.Widget _subSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFEFF6FF),
        borderRadius: pw.BorderRadius.circular(3),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFBFDBFE), width: 0.5),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: _primaryDark,
        ),
      ),
    );
  }

  static pw.Widget _kpiCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.ClipRRect(
        horizontalRadius: 6,
        verticalRadius: 6,
        child: pw.Container(
          decoration: const pw.BoxDecoration(color: _lightBg),
          child: pw.Row(
            children: [
              pw.Container(width: 3, height: 50, color: color),
              pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        label,
                        style: const pw.TextStyle(fontSize: 8, color: _grey),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        value,
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: _dark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildMiniStat(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _lightBg,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: _tableBorder, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _grey)),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _dark),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStyledTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _white),
      headerDecoration: const pw.BoxDecoration(color: _primaryDark),
      headerPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      cellStyle: const pw.TextStyle(fontSize: 9, color: _dark),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      cellDecoration: (index, data, rowNum) {
        return pw.BoxDecoration(
          color: rowNum % 2 == 0 ? _white : _lightBg,
          border: pw.Border(bottom: pw.BorderSide(color: _tableBorder, width: 0.5)),
        );
      },
      headerAlignments: {
        for (int i = 0; i < headers.length; i++)
          i: i == 0 ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
      },
      cellAlignments: {
        for (int i = 0; i < headers.length; i++)
          i: i == 0 ? pw.Alignment.centerLeft : pw.Alignment.centerRight,
      },
      headers: headers,
      data: rows,
    );
  }

  static pw.Widget _legendDot(PdfColor color, String label) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(width: 8, height: 8, decoration: pw.BoxDecoration(color: color, shape: pw.BoxShape.circle)),
        pw.SizedBox(width: 3),
        pw.Text('$label star', style: const pw.TextStyle(fontSize: 7, color: _grey)),
      ],
    );
  }

  static String _eur(double v) => 'EUR ${v.toStringAsFixed(2)}';
}

class _BarSegment {
  final double fraction;
  final PdfColor color;
  const _BarSegment(this.fraction, this.color);
}
