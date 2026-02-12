import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erent_mobile/model/payment.dart';
import 'package:erent_mobile/providers/payment_provider.dart';
import 'package:erent_mobile/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late PaymentProvider paymentProvider;
  late AnimationController _animController;

  List<Payment> _payments = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, succeeded, pending, failed
  String _selectedPeriod = 'all'; // all, month, year

  // Summary
  double _totalSpent = 0;
  double _monthlySpent = 0;
  int _totalTransactions = 0;
  int _pendingCount = 0;

  static const Color primaryColor = Color(0xFF5B9BD5);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFB84D);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    _loadPayments();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPayments();
    }
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);

    try {
      final user = UserProvider.currentUser;
      if (user == null) {
        setState(() {
          _payments = [];
          _isLoading = false;
        });
        return;
      }

      DateTime? dateFrom;
      if (_selectedPeriod == 'month') {
        final now = DateTime.now();
        dateFrom = DateTime(now.year, now.month, 1);
      } else if (_selectedPeriod == 'year') {
        final now = DateTime.now();
        dateFrom = DateTime(now.year, 1, 1);
      }

      final result = await paymentProvider.getPayments(
        userId: user.id,
        status: _selectedFilter == 'all' ? null : _selectedFilter,
        dateFrom: dateFrom,
        pageSize: 200,
        includeTotalCount: true,
      );

      if (mounted) {
        final payments = result.items ?? [];
        _calculateSummary(payments);
        setState(() {
          _payments = payments;
          _isLoading = false;
        });
        _animController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading expenses: $e'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _calculateSummary(List<Payment> payments) {
    final now = DateTime.now();
    _totalSpent = 0;
    _monthlySpent = 0;
    _totalTransactions = payments.length;
    _pendingCount = 0;

    for (final p in payments) {
      if (p.status.toLowerCase() == 'succeeded') {
        _totalSpent += p.amount;
        if (p.createdAt.year == now.year && p.createdAt.month == now.month) {
          _monthlySpent += p.amount;
        }
      }
      if (p.status.toLowerCase() == 'pending') {
        _pendingCount++;
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return successColor;
      case 'pending':
        return warningColor;
      case 'failed':
        return errorColor;
      case 'canceled':
      case 'cancelled':
        return Colors.grey;
      case 'refunded':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'succeeded':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      case 'failed':
        return Icons.error_rounded;
      case 'canceled':
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'refunded':
        return Icons.replay_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  IconData _getPaymentMethodIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'card':
        return Icons.credit_card_rounded;
      case 'bank_transfer':
        return Icons.account_balance_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _loadPayments,
        color: primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            // Summary cards
            SliverToBoxAdapter(
              child: _buildSummaryCards(),
            ),
            // Filters
            SliverToBoxAdapter(
              child: _buildFilters(),
            ),
            // Content
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              )
            else if (_payments.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              _buildPaymentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'My Expenses',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: primaryColor),
                onPressed: _loadPayments,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Track your rental payments and expenses',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Main spending card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5B9BD5),
                  Color(0xFF7AB8CC),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Total Spent',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  currencyFormat.format(_totalSpent),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_totalTransactions} transaction${_totalTransactions == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Small stat cards
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'This Month',
                  value: currencyFormat.format(_monthlySpent),
                  color: const Color(0xFF5B9BD5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  icon: Icons.schedule_rounded,
                  label: 'Pending',
                  value: _pendingCount.toString(),
                  color: warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          // Period filter
          Row(
            children: [
              const Text(
                'Period',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              const SizedBox(width: 12),
              _buildPeriodChip('All Time', 'all'),
              const SizedBox(width: 6),
              _buildPeriodChip('This Month', 'month'),
              const SizedBox(width: 6),
              _buildPeriodChip('This Year', 'year'),
            ],
          ),
          const SizedBox(height: 10),
          // Status filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', Icons.list_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('Paid', 'succeeded', Icons.check_circle_outline_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending', Icons.schedule_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('Failed', 'failed', Icons.error_outline_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = value);
        _loadPayments();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = value);
        _loadPayments();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? primaryColor : textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primaryColor : textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList() {
    // Group payments by month
    final grouped = <String, List<Payment>>{};
    for (final p in _payments) {
      final key = DateFormat('MMMM yyyy').format(p.createdAt);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(p);
    }

    final sections = grouped.entries.toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= sections.length) return null;
          final section = sections[index];
          final monthTotal = section.value
              .where((p) => p.status.toLowerCase() == 'succeeded')
              .fold<double>(0, (sum, p) => sum + p.amount);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      section.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      NumberFormat.currency(symbol: '€', decimalDigits: 2)
                          .format(monthTotal),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Payments in section
              ...section.value.map((payment) => _buildPaymentCard(payment)),
            ],
          );
        },
        childCount: sections.length,
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final statusColor = _getStatusColor(payment.status);
    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: () => _showPaymentDetail(payment),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
            ),
            child: Row(
              children: [
                // Payment method icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getStatusIcon(payment.status),
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.propertyTitle.isNotEmpty
                            ? payment.propertyTitle
                            : 'Payment #${payment.id}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getPaymentMethodIcon(payment.paymentMethod),
                            size: 13,
                            color: textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(payment.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Amount and status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(payment.amount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        payment.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 42,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Expenses Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your payment history will appear here\nonce you make a rental payment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDetail(Payment payment) {
    final currencyFormat = NumberFormat.currency(symbol: '€', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final statusColor = _getStatusColor(payment.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status icon and amount
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(payment.status),
                        color: statusColor,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(payment.amount),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        payment.statusLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Details
              _buildDetailSection('Payment Details', [
                _buildDetailRow(
                    'Property', payment.propertyTitle, Icons.home_rounded),
                _buildDetailRow('Date', dateFormat.format(payment.createdAt),
                    Icons.calendar_today_rounded),
                _buildDetailRow(
                    'Currency',
                    payment.currency.toUpperCase(),
                    Icons.monetization_on_rounded),
                if (payment.paymentMethod != null)
                  _buildDetailRow(
                      'Method',
                      _formatPaymentMethod(payment.paymentMethod!),
                      _getPaymentMethodIcon(payment.paymentMethod)),
                if (payment.rentId != null)
                  _buildDetailRow('Rent ID', '#${payment.rentId}',
                      Icons.receipt_rounded),
              ]),

              if (payment.customerName != null ||
                  payment.customerEmail != null) ...[
                const SizedBox(height: 20),
                _buildDetailSection('Billing Information', [
                  if (payment.customerName != null)
                    _buildDetailRow('Name', payment.customerName!,
                        Icons.person_rounded),
                  if (payment.customerEmail != null)
                    _buildDetailRow('Email', payment.customerEmail!,
                        Icons.email_rounded),
                  if (payment.billingAddress != null)
                    _buildDetailRow('Address', payment.billingAddress!,
                        Icons.location_on_rounded),
                  if (payment.billingCity != null)
                    _buildDetailRow(
                        'City', payment.billingCity!, Icons.location_city_rounded),
                  if (payment.billingCountry != null)
                    _buildDetailRow('Country', payment.billingCountry!,
                        Icons.flag_rounded),
                ]),
              ],

              const SizedBox(height: 16),
              // Transaction ID
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tag_rounded, size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Transaction: ${payment.stripePaymentIntentId}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return 'Credit/Debit Card';
      case 'bank_transfer':
        return 'Bank Transfer';
      default:
        return method;
    }
  }
}
