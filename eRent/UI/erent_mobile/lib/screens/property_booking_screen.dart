import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erent_mobile/model/property.dart';
import 'package:erent_mobile/providers/rent_provider.dart';
import 'package:erent_mobile/providers/user_provider.dart';
import 'package:erent_mobile/screens/booking_details_screen.dart';
import 'package:provider/provider.dart';

class PropertyBookingScreen extends StatefulWidget {
  final Property property;

  const PropertyBookingScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyBookingScreen> createState() => _PropertyBookingScreenState();
}

class _PropertyBookingScreenState extends State<PropertyBookingScreen> {
  late RentProvider rentProvider;
  late UserProvider userProvider;
  bool _isLoading = false;

  bool _isDailyRental = false;
  DateTime? _startDate;
  int _numberOfMonths = 1;
  int _numberOfDays = 1;
  final TextEditingController _monthsController = TextEditingController(text: '1');
  final TextEditingController _daysController = TextEditingController(text: '1');
  bool _isCheckingConflicts = false;
  bool _hasConflict = false;
  String? _conflictMessage;
  double _calculatedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    rentProvider = Provider.of<RentProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Set default to daily if allowed, otherwise monthly
    _isDailyRental = widget.property.allowDailyRental;
    
    _monthsController.addListener(_onMonthsChanged);
    _daysController.addListener(_onDaysChanged);
  }

  @override
  void dispose() {
    _monthsController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _onMonthsChanged() {
    final value = int.tryParse(_monthsController.text);
    if (value != null && value > 0) {
      setState(() {
        _numberOfMonths = value;
      });
      _calculatePrice();
      _checkForConflicts();
    }
  }

  void _onDaysChanged() {
    final value = int.tryParse(_daysController.text);
    if (value != null && value > 0) {
      setState(() {
        _numberOfDays = value;
      });
      _calculatePrice();
      _checkForConflicts();
    }
  }

  DateTime? get _endDate {
    if (_startDate == null) return null;
    
    if (_isDailyRental) {
      return _startDate!.add(Duration(days: _numberOfDays));
    } else {
      // Add months
      int year = _startDate!.year;
      int month = _startDate!.month;
      int day = _startDate!.day;
      
      month += _numberOfMonths;
      while (month > 12) {
        month -= 12;
        year += 1;
      }
      
      // Handle edge case where day doesn't exist in target month (e.g., Jan 31 -> Feb 31)
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final finalDay = day > daysInMonth ? daysInMonth : day;
      
      return DateTime(year, month, finalDay);
    }
  }

  void _calculatePrice() {
    if (_startDate == null) {
      setState(() {
        _calculatedPrice = 0.0;
      });
      return;
    }

    if (_isDailyRental && widget.property.allowDailyRental && widget.property.pricePerDay != null) {
      if (_numberOfDays <= 0) {
        setState(() {
          _calculatedPrice = 0.0;
        });
        return;
      }
      _calculatedPrice = widget.property.pricePerDay! * _numberOfDays;
    } else {
      if (_numberOfMonths <= 0) {
        setState(() {
          _calculatedPrice = 0.0;
        });
        return;
      }
      _calculatedPrice = widget.property.pricePerMonth * _numberOfMonths;
    }

    setState(() {});
  }

  Future<void> _checkForConflicts() async {
    if (_startDate == null) {
      setState(() {
        _hasConflict = false;
        _conflictMessage = null;
      });
      return;
    }

    final endDate = _endDate;
    if (endDate == null) {
      setState(() {
        _hasConflict = false;
        _conflictMessage = null;
      });
      return;
    }

    if (_isDailyRental && _numberOfDays <= 0) {
      setState(() {
        _hasConflict = true;
        _conflictMessage = 'Number of days must be greater than 0';
      });
      return;
    }

    if (!_isDailyRental && _numberOfMonths <= 0) {
      setState(() {
        _hasConflict = true;
        _conflictMessage = 'Number of months must be greater than 0';
      });
      return;
    }

    setState(() {
      _isCheckingConflicts = true;
      _hasConflict = false;
      _conflictMessage = null;
    });

    try {
      // Check for existing rents with Accepted (4) or Paid (5) status
      final result = await rentProvider.get(filter: {
        'propertyId': widget.property.id,
        'isActive': true,
        'retrieveAll': true,
      });

      final conflictingRents = result.items?.where((rent) {
        // Only check Accepted (4) or Paid (5) statuses
        if (rent.rentStatusId != 4 && rent.rentStatusId != 5) {
          return false;
        }

        // Check for overlap
        return (rent.startDate.isBefore(endDate) && rent.endDate.isAfter(_startDate!));
      }).toList();

      if (mounted) {
        setState(() {
          _isCheckingConflicts = false;
          if (conflictingRents != null && conflictingRents.isNotEmpty) {
            _hasConflict = true;
            final conflict = conflictingRents.first;
            _conflictMessage = 'Property is already booked from ${_formatDate(conflict.startDate)} to ${_formatDate(conflict.endDate)}';
          } else {
            _hasConflict = false;
            _conflictMessage = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingConflicts = false;
          _hasConflict = true;
          _conflictMessage = 'Error checking availability: $e';
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B9BD5),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

      if (picked != null) {
        setState(() {
          _startDate = picked;
        });
        _calculatePrice();
        _checkForConflicts();
      }
  }


  void _onRentalTypeChanged(bool? value) {
    if (value == null) return;
    
    setState(() {
      _isDailyRental = value;
    });
    _calculatePrice();
    _checkForConflicts();
  }

  Future<void> _onPayNow() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isDailyRental && _numberOfDays <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter number of days'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isDailyRental && _numberOfMonths <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter number of months'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hasConflict) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_conflictMessage ?? 'There is a conflict with the selected dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_calculatedPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid date range'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final endDate = _endDate;
    if (endDate == null) {
      return;
    }

    // Create rent request directly (without payment)
    setState(() => _isLoading = true);

    try {
      final user = UserProvider.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to create a booking'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final request = {
        'propertyId': widget.property.id,
        'userId': user.id,
        'startDate': _startDate!.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isDailyRental': _isDailyRental,
      };

      final rent = await rentProvider.insert(request);

      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to booking details screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailsScreen(
              rentId: rent.id,
              property: widget.property,
              startDate: _startDate!,
              endDate: endDate,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Property',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Text(
                    widget.property.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${widget.property.cityName}${widget.property.address != null ? ', ${widget.property.address}' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Rental Type Selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    'Rental Type',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRentalTypeOption(
                          title: 'Monthly',
                          price: '€${widget.property.pricePerMonth.toStringAsFixed(0)}/mo',
                          isSelected: !_isDailyRental,
                          onTap: () => _onRentalTypeChanged(false),
                        ),
                      ),
                      if (widget.property.allowDailyRental) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildRentalTypeOption(
                            title: 'Daily',
                            price: widget.property.pricePerDay != null
                                ? '€${widget.property.pricePerDay!.toStringAsFixed(0)}/day'
                                : 'N/A',
                            isSelected: _isDailyRental,
                            onTap: () => _onRentalTypeChanged(true),
                            isEnabled: widget.property.pricePerDay != null && widget.property.pricePerDay! > 0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Date and Duration Selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    'Select Start Date & Duration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Start Date',
                          date: _startDate,
                          onTap: _selectStartDate,
                          icon: Icons.calendar_today_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDurationField(),
                      ),
                    ],
                  ),
                  if (_startDate != null && _endDate != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_available_rounded, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'End Date: ${_formatDate(_endDate!)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_isCheckingConflicts) ...[
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Checking availability...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5B9BD5),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_hasConflict && _conflictMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, size: 18, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _conflictMessage!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!_hasConflict && _startDate != null && _endDate != null && !_isCheckingConflicts && ((_isDailyRental && _numberOfDays > 0) || (!_isDailyRental && _numberOfMonths > 0))) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 18, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Dates available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Price Summary
            if (_calculatedPrice > 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B9BD5), Color(0xFF7AB8CC)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B9BD5).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isDailyRental ? 'Days' : 'Months',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          _isDailyRental ? '$_numberOfDays' : '$_numberOfMonths',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_startDate != null && _endDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'End Date',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            _formatDate(_endDate!),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '€${_calculatedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Book Now Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onPayNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9BD5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF5B9BD5).withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_work_rounded, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalTypeOption({
    required String title,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF5B9BD5).withOpacity(0.1)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF5B9BD5)
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isEnabled
                      ? (isSelected ? const Color(0xFF5B9BD5) : const Color(0xFF1F2937))
                      : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: TextStyle(
                  fontSize: 14,
                  color: isEnabled
                      ? (isSelected ? const Color(0xFF5B9BD5) : Colors.grey[600])
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                date != null ? _formatDate(date) : 'Select date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                  color: date != null ? const Color(0xFF1F2937) : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationField() {
    if (_isDailyRental) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12),
              child: Row(
                children: [
                  const Icon(Icons.calendar_view_day_rounded, size: 16, color: Color(0xFF5B9BD5)),
                  const SizedBox(width: 6),
                  Text(
                    'Days',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_numberOfDays > 1) {
                      setState(() {
                        _numberOfDays--;
                        _daysController.text = _numberOfDays.toString();
                      });
                      _calculatePrice();
                      _checkForConflicts();
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF5B9BD5)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      final numValue = int.tryParse(value);
                      if (numValue != null && numValue > 0) {
                        setState(() {
                          _numberOfDays = numValue;
                        });
                        _calculatePrice();
                        _checkForConflicts();
                      } else if (value.isEmpty) {
                        setState(() {
                          _numberOfDays = 0;
                        });
                        _calculatePrice();
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _numberOfDays++;
                      _daysController.text = _numberOfDays.toString();
                    });
                    _calculatePrice();
                    _checkForConflicts();
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5B9BD5)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF5B9BD5)),
                  const SizedBox(width: 6),
                  Text(
                    'Months',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_numberOfMonths > 1) {
                      setState(() {
                        _numberOfMonths--;
                        _monthsController.text = _numberOfMonths.toString();
                      });
                      _calculatePrice();
                      _checkForConflicts();
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF5B9BD5)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Expanded(
                  child: TextField(
                    controller: _monthsController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      final numValue = int.tryParse(value);
                      if (numValue != null && numValue > 0) {
                        setState(() {
                          _numberOfMonths = numValue;
                        });
                        _calculatePrice();
                        _checkForConflicts();
                      } else if (value.isEmpty) {
                        setState(() {
                          _numberOfMonths = 0;
                        });
                        _calculatePrice();
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _numberOfMonths++;
                      _monthsController.text = _numberOfMonths.toString();
                    });
                    _calculatePrice();
                    _checkForConflicts();
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5B9BD5)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
