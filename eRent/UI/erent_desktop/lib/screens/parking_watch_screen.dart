import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erent_desktop/model/parking_zone.dart';
import 'package:erent_desktop/model/parking_spot.dart';
import 'package:erent_desktop/model/parking_spot_type.dart';
import 'package:erent_desktop/model/reservation.dart';
import 'package:erent_desktop/providers/parking_zone_provider.dart';
import 'package:erent_desktop/providers/parking_spot_provider.dart';
import 'package:erent_desktop/providers/parking_spot_type_provider.dart';
import 'package:erent_desktop/providers/reservation_provider.dart';
import 'package:erent_desktop/layouts/master_screen.dart';

// Brown color scheme matching the app
const Color _brownPrimary = Color(0xFF8B6F47);

class ParkingWatchScreen extends StatefulWidget {
  const ParkingWatchScreen({super.key});

  @override
  State<ParkingWatchScreen> createState() => _ParkingWatchScreenState();
}

class _ParkingWatchScreenState extends State<ParkingWatchScreen> {
  late ParkingZoneProvider parkingZoneProvider;
  late ParkingSpotProvider parkingSpotProvider;
  late ParkingSpotTypeProvider parkingSpotTypeProvider;
  late ReservationProvider reservationProvider;

  List<ParkingZone> zones = [];
  int? selectedZoneId; // Store zone ID instead of object reference
  ParkingZone? selectedZone; // Keep for display
  List<ParkingSpot> spots = [];
  List<ParkingSpotType> spotTypes = [];
  List<Reservation> reservations = [];
  Map<String, List<ParkingSpot>> groupedSpots = {};
  Map<int, ParkingSpotType> spotTypesMap = {};
  Map<int, List<Reservation>> spotReservationsMap = {}; // Map spot ID to reservations for selected day
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;
  String? errorMessage;
  int? hoveredSpotId; // Track which individual spot is being hovered

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      parkingZoneProvider = context.read<ParkingZoneProvider>();
      parkingSpotProvider = context.read<ParkingSpotProvider>();
      parkingSpotTypeProvider = context.read<ParkingSpotTypeProvider>();
      reservationProvider = context.read<ReservationProvider>();
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load zones
      final zonesResult = await parkingZoneProvider.get(filter: {"pageSize": 1000, "isActive": true});
      final zonesList = zonesResult.items ?? [];
      
      if (zonesList.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "No parking zones available";
        });
        return;
      }

      // Select first zone if none selected, or find zone by ID
      final zoneToLoad = selectedZoneId != null
          ? zonesList.firstWhere(
              (z) => z.id == selectedZoneId,
              orElse: () => zonesList.first,
            )
          : zonesList.first;
      
      // Update selected zone ID
      final zoneIdToLoad = zoneToLoad.id;

      // Load spot types
      final typesResult = await parkingSpotTypeProvider.get(filter: {"pageSize": 1000});
      final spotTypesList = typesResult.items ?? [];

      // Load spots for selected zone
      final spotsResult = await parkingSpotProvider.get(filter: {
        "parkingZoneId": zoneToLoad.id,
        "pageSize": 1000,
      });

      // Load reservations for selected zone and date range
      // Use date range that includes the selected date to get all potentially overlapping reservations
      final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
      
      // Get reservations that might overlap with selected date
      // We check: reservations that start before or on the selected date and end after or on the selected date
      final reservationsResult = await reservationProvider.get(filter: {
        "startDateTo": endOfDay.toIso8601String(), // Reservations that start before/on selected date
        "endDateFrom": startOfDay.toIso8601String(), // Reservations that end after/on selected date
        "pageSize": 1000,
        "includePictures": false, // Optimize payload
      });

      // Process spots
      Map<String, List<ParkingSpot>> grouped = {};
      for (var spot in spotsResult.items ?? []) {
        if (spot.parkingNumber.isNotEmpty) {
          String rowLetter = spot.parkingNumber[0];
          if (!grouped.containsKey(rowLetter)) {
            grouped[rowLetter] = [];
          }
          grouped[rowLetter]!.add(spot);
        }
      }

      // Sort spots within each row by number
      for (var row in grouped.keys) {
        grouped[row]!.sort((a, b) {
          int aNum = int.tryParse(a.parkingNumber.substring(1)) ?? 0;
          int bNum = int.tryParse(b.parkingNumber.substring(1)) ?? 0;
          return aNum.compareTo(bNum);
        });
      }

      // Process reservations - filter by date and zone, then map to spots
      final spotsList = spotsResult.items ?? [];
      Map<int, List<Reservation>> spotReservations = {};
      for (var reservation in reservationsResult.items ?? []) {
        // Check if reservation is for a spot in the selected zone and active for selected date
        final spot = spotsList.firstWhere(
          (s) => s.id == reservation.parkingSpotId,
          orElse: () => ParkingSpot(id: -1, parkingNumber: '', parkingSpotTypeId: 0, parkingZoneId: 0),
        );
        
        if (spot.id != -1 && spot.parkingZoneId == zoneIdToLoad &&
            _isReservationActiveForDate(reservation, selectedDate)) {
          if (!spotReservations.containsKey(reservation.parkingSpotId)) {
            spotReservations[reservation.parkingSpotId] = [];
          }
          spotReservations[reservation.parkingSpotId]!.add(reservation);
        }
      }

      setState(() {
        zones = zonesList;
        selectedZone = zoneToLoad; // Update for display
        selectedZoneId = zoneIdToLoad; // Keep ID in sync
        spots = spotsList;
        spotTypes = spotTypesList;
        spotTypesMap = {for (var type in spotTypesList) type.id: type};
        groupedSpots = grouped;
        reservations = reservationsResult.items ?? [];
        spotReservationsMap = spotReservations;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  bool _isReservationActiveForDate(Reservation reservation, DateTime date) {
    if (reservation.startDate == null || reservation.endDate == null) {
      return false;
    }

    final startDate = reservation.startDate!;
    final endDate = reservation.endDate!;
    final checkDate = DateTime(date.year, date.month, date.day);
    final checkDateStart = checkDate;
    final checkDateEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // Check if the reservation period overlaps with the selected date
    // Two periods overlap if: start1 <= end2 && start2 <= end1
    return startDate.isBefore(checkDateEnd) && checkDateStart.isBefore(endDate);
  }

  Color _parseColor(String? hexCode) {
    if (hexCode == null || hexCode.isEmpty) {
      return Colors.grey;
    }
    try {
      // Remove # if present
      String hex = hexCode.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (e) {
      // If parsing fails, return grey
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Live Parking Watch",
      showBackButton: false,
      child: SingleChildScrollView(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading parking data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
            
                        if (spots.isEmpty) _buildEmptyState(),
                        if (spots.isNotEmpty) ...[
                          _buildParkingLot(),
                        ],
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildZoneCarousel() {
    if (zones.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentIndex = selectedZoneId != null
        ? zones.indexWhere((z) => z.id == selectedZoneId)
        : 0;
    final displayIndex = currentIndex >= 0 ? currentIndex : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _brownPrimary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: _brownPrimary,
              size: 24,
            ),
            onPressed: displayIndex > 0
                ? () {
                    final newIndex = displayIndex - 1;
                    final newZone = zones[newIndex];
                    setState(() {
                      selectedZoneId = newZone.id;
                      selectedZone = newZone;
                    });
                    _loadData();
                  }
                : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                zones[displayIndex].name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _brownPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _brownPrimary,
              size: 24,
            ),
            onPressed: displayIndex < zones.length - 1
                ? () {
                    final newIndex = displayIndex + 1;
                    final newZone = zones[newIndex];
                    setState(() {
                      selectedZoneId = newZone.id;
                      selectedZone = newZone;
                    });
                    _loadData();
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _brownPrimary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: _brownPrimary,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.subtract(const Duration(days: 1));
              });
              _loadData();
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                  _loadData();
                }
              },
              child: Center(
                child: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _brownPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _brownPrimary,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.add(const Duration(days: 1));
              });
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
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
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.local_parking_outlined,
              size: 64,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No parking spots found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This parking zone doesn\'t have any spots configured.',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildParkingLot() {
    if (groupedSpots.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
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
      child: Stack(
        children: [
          Column(
            children: [
              // Parking lot entrance/exit with zone carousel and date picker
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _brownPrimary.withOpacity(0.2),
                      _brownPrimary.withOpacity(0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _brownPrimary.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _brownPrimary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                  
                  
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Zone carousel
                          Expanded(
                            child: _buildZoneCarousel(),
                          ),
                          const SizedBox(width: 20),
                          // Date picker
                          Expanded(
                            child: _buildDatePicker(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // const SizedBox(height: 10),
              
              // Parking spots grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildParkingRows(),
              ),
              const SizedBox(height: 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParkingRows() {
    var sortedRows = groupedSpots.keys.toList()..sort();
    
    List<Widget> widgets = [];
    for (int i = 0; i < sortedRows.length; i++) {
      widgets.add(_buildParkingRow(sortedRows[i], groupedSpots[sortedRows[i]]!));
      
      if (i < sortedRows.length - 1 && (i + 1) % 2 == 0) {
        int spotCount = groupedSpots[sortedRows[i]]!.length;
        widgets.add(_buildRoadSeparator(spotCount));
      }
    }
    
    return Column(children: widgets);
  }

  Widget _buildRoadSeparator(int spotCount) {
    double roadWidth = (spotCount * 50) + ((spotCount - 1) * 8);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 50),
          const SizedBox(width: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 50,
                    width: roadWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A5568),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2D3748),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4A5568),
                                const Color(0xFF2D3748),
                                const Color(0xFF4A5568),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Center(
                          child: CustomPaint(
                            size: Size(roadWidth, 4),
                            painter: _DashedLinePainter(
                              color: Colors.yellow[700]!,
                              strokeWidth: 3,
                              dashWidth: 20,
                              dashSpace: 10,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 3,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 3,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingRow(String rowLetter, List<ParkingSpot> rowSpots) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _brownPrimary.withOpacity(0.2),
                  _brownPrimary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _brownPrimary.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _brownPrimary.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                rowLetter,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _brownPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: rowSpots.asMap().entries.map((entry) {
                  int index = entry.key;
                  ParkingSpot spot = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(right: index < rowSpots.length - 1 ? 8 : 0),
                    child: _buildParkingSpot(spot),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingSpot(ParkingSpot spot) {
    Color spotColor = _getSpotTypeColor(spot.parkingSpotTypeId);
    String spotNumber = spot.parkingNumber.length > 1 ? spot.parkingNumber.substring(1) : spot.parkingNumber;
    List<Reservation> spotReservations = spotReservationsMap[spot.id] ?? [];
    bool hasReservation = spotReservations.isNotEmpty;
    Color? carColor = hasReservation ? _parseColor(spotReservations.first.carColorHexCode) : null;
    bool isHovered = hoveredSpotId == spot.id;
    
    return Tooltip(
      message: hasReservation 
          ? '${spot.parkingNumber}\nReserved: ${spotReservations.length} reservation(s)\nClick to view details'
          : '${spot.parkingNumber}\nAvailable\nClick to view details',
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            hoveredSpotId = spot.id;
          });
        },
        onExit: (_) {
          setState(() {
            hoveredSpotId = null;
          });
        },
        child: GestureDetector(
          onTap: () => _showReservationDetails(spot, spotReservations),
          child: SizedBox(
            width: 50,
            height: 80,
            child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: hasReservation ? const Color(0xFF10B981) : const Color(0xFFE2E8F0), // Green for reserved
                width: hasReservation ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasReservation 
                      ? const Color(0xFF10B981).withOpacity(0.3) // Green shadow for reserved
                      : Colors.black.withOpacity(0.1),
                  blurRadius: hasReservation ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Parking spot lines
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
                // Corner markers
                Positioned(
                  top: 2,
                  left: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: const Color(0xFF94A3B8), width: 2),
                        left: BorderSide(color: const Color(0xFF94A3B8), width: 2),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: const Color(0xFF94A3B8), width: 2),
                        right: BorderSide(color: const Color(0xFF94A3B8), width: 2),
                      ),
                    ),
                  ),
                ),
                // Color indicator
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    width: 18,
                    height: 8,
                    decoration: BoxDecoration(
                      color: spotColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // Car icon if reserved
                if (hasReservation)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: carColor ?? Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                // Spot number
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        spotNumber,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: hasReservation ? Colors.white : const Color(0xFF1E293B),
                          shadows: [
                            Shadow(
                              color: hasReservation 
                                  ? Colors.black.withOpacity(0.8)
                                  : Colors.black12,
                              blurRadius: hasReservation ? 3 : 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      if (!spot.isActive)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: const Text(
                            'X',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                ),
              ),
              // Highlight border when this spot is hovered
              if (isHovered)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: spotColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: spotColor.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
        ),
      ),
    );
  }

  Color _getSpotTypeColor(int? spotTypeId) {
    if (spotTypeId == null) {
      return const Color(0xFF6B7280);
    }
    
    ParkingSpotType? spotType = spotTypesMap[spotTypeId];
    if (spotType == null) {
      return const Color(0xFF6B7280);
    }
    
    String name = spotType.name.toLowerCase();
    
    if (name.contains('regular') || name.contains('standard') || name.contains('normal')) {
      return const Color(0xFF10B981); // Green
    }
    if (name.contains('compact')) {
      return const Color(0xFFEF4444); // Red
    }
    if (name.contains('electric')) {
      return const Color(0xFFF59E0B); // Orange
    }
    if (name.contains('disabled') || name.contains('handicap')) {
      return const Color(0xFF3B82F6); // Blue
    }
    if (name.contains('large')) {
      return const Color(0xFF8B5CF6); // Purple
    }
    
    int hash = spotTypeId % 5;
    switch (hash) {
      case 0:
        return const Color(0xFF10B981);
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  void _showReservationDetails(ParkingSpot spot, List<Reservation> reservations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_parking,
                      color: _brownPrimary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Parking Spot ${spot.parkingNumber}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: _brownPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Reservations for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
                if (reservations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reservations for this date',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: reservations.length,
                      itemBuilder: (context, index) {
                        final reservation = reservations[index];
                        final carColor = _parseColor(reservation.carColorHexCode);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: carColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: carColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${reservation.carBrandName ?? "Unknown"} ${reservation.carModel ?? ""}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        Text(
                                          'License: ${reservation.carLicensePlate ?? "N/A"}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildReservationInfo(
                                      Icons.person,
                                      'User',
                                      reservation.userFullName ?? "Unknown",
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildReservationInfo(
                                      Icons.event,
                                      'Type',
                                      reservation.reservationTypeName ?? "Unknown",
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildReservationInfo(
                                      Icons.access_time,
                                      'Start',
                                      reservation.startDate != null
                                          ? '${reservation.startDate!.day}/${reservation.startDate!.month}/${reservation.startDate!.year} ${reservation.startDate!.hour.toString().padLeft(2, '0')}:${reservation.startDate!.minute.toString().padLeft(2, '0')}'
                                          : "N/A",
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildReservationInfo(
                                      Icons.access_time_filled,
                                      'End',
                                      reservation.endDate != null
                                          ? '${reservation.endDate!.day}/${reservation.endDate!.month}/${reservation.endDate!.year} ${reservation.endDate!.hour.toString().padLeft(2, '0')}:${reservation.endDate!.minute.toString().padLeft(2, '0')}'
                                          : "N/A",
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _brownPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Price:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    Text(
                                      '\$${reservation.finalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _brownPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReservationInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom painter for dashed road lines
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

