import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erent_desktop/model/parking_zone.dart';
import 'package:erent_desktop/model/parking_spot.dart';
import 'package:erent_desktop/model/parking_spot_type.dart';
import 'package:erent_desktop/providers/parking_spot_provider.dart';
import 'package:erent_desktop/providers/parking_spot_type_provider.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/screens/parking_spot_edit_screen.dart';

// Brown color scheme matching the app
const Color _brownPrimary = Color(0xFF8B6F47);

class ParkingSpotListScreen extends StatefulWidget {
  final ParkingZone parkingZone;

  const ParkingSpotListScreen({super.key, required this.parkingZone});

  @override
  State<ParkingSpotListScreen> createState() => _ParkingSpotListScreenState();
}

class _ParkingSpotListScreenState extends State<ParkingSpotListScreen> {
  late ParkingSpotProvider parkingSpotProvider;
  late ParkingSpotTypeProvider parkingSpotTypeProvider;

  List<ParkingSpot> spots = [];
  List<ParkingSpotType> spotTypes = [];
  Map<String, List<ParkingSpot>> groupedSpots = {};
  Map<int, ParkingSpotType> spotTypesMap = {};
  bool isLoading = true;
  String? errorMessage;
  int? hoveredSpotTypeId; // Track which spot type is being hovered in legend
  int? hoveredSpotId; // Track which individual spot is being hovered

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      parkingSpotProvider = context.read<ParkingSpotProvider>();
      parkingSpotTypeProvider = context.read<ParkingSpotTypeProvider>();
      await _loadSpots();
    });
  }

  Future<void> _loadSpots() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load spot types first
      final typesResult = await parkingSpotTypeProvider.get(filter: {"pageSize": 1000});
      setState(() {
        spotTypes = typesResult.items ?? [];
        spotTypesMap = {for (var type in typesResult.items ?? []) type.id: type};
      });

      // Load spots for this zone
      final spotsResult = await parkingSpotProvider.get(filter: {
        "parkingZoneId": widget.parkingZone.id,
        "pageSize": 1000,
      });
      
      // Group spots by row (first letter of parking number)
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
          // Extract numeric part and compare
          int aNum = int.tryParse(a.parkingNumber.substring(1)) ?? 0;
          int bNum = int.tryParse(b.parkingNumber.substring(1)) ?? 0;
          return aNum.compareTo(bNum);
        });
      }

      setState(() {
        groupedSpots = grouped;
        spots = spotsResult.items ?? [];
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
      title: "${widget.parkingZone.name} - Parking Spots",
      showBackButton: true,
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
                          'Error loading parking spots',
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
                          onPressed: _loadSpots,
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        if (spots.isEmpty) _buildEmptyState(),
                        if (spots.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildParkingLot(),
                        ],
                      ],
                    ),
        ),
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

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: _brownPrimary.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.legend_toggle_rounded,
                color: _brownPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Spot Types (hover to display all spots of this type)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _brownPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: spotTypes.map((spotType) => _buildLegendItem(spotType)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ParkingSpotType spotType) {
    Color spotColor = _getSpotTypeColor(spotType.id, spotType.name);
    bool isHovered = hoveredSpotTypeId == spotType.id;
    
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredSpotTypeId = spotType.id;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredSpotTypeId = null;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 10,
            decoration: BoxDecoration(
              color: spotColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isHovered ? Colors.white : spotColor.withOpacity(0.3),
                width: isHovered ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered 
                      ? spotColor.withOpacity(0.5)
                      : Colors.black.withOpacity(0.2),
                  blurRadius: isHovered ? 6 : 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            spotType.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isHovered ? spotColor : const Color(0xFF1E293B),
            ),
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
              // Parking lot entrance/exit
              Container(
                width: double.infinity,
                height: 75,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_rounded,
                      color: _brownPrimary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'PARKING LOT ENTRANCE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _brownPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Zone: ${widget.parkingZone.name}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _brownPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.directions_car_rounded,
                      color: _brownPrimary,
                      size: 32,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Parking spots grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildParkingRows(),
              ),
              const SizedBox(height: 20),
            ],
          ),
          
          // Legend positioned at top right
          Positioned(
            top: 20,
            right: 20,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingRows() {
    // Sort rows alphabetically (A, B, C, etc.)
    var sortedRows = groupedSpots.keys.toList()..sort();
    
    List<Widget> widgets = [];
    for (int i = 0; i < sortedRows.length; i++) {
      widgets.add(_buildParkingRow(sortedRows[i], groupedSpots[sortedRows[i]]!));
      
      // Add road separator between every two rows (after B, D, F, etc.)
      if (i < sortedRows.length - 1 && (i + 1) % 2 == 0) {
        // Calculate road width based on the spots in the previous row
        int spotCount = groupedSpots[sortedRows[i]]!.length;
        widgets.add(_buildRoadSeparator(spotCount));
      }
    }
    
    return Column(children: widgets);
  }

  Widget _buildRoadSeparator(int spotCount) {
    // Calculate road width: spot width (50) + spacing (8) for each spot
    // Road should match the width of the spots area only
    double roadWidth = (spotCount * 50) + ((spotCount - 1) * 8);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty space to match row label width
          SizedBox(width: 50),
          const SizedBox(width: 16),
          // Road separator - use same Expanded structure as parking spots
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 50,
                    width: roadWidth,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A5568), // Dark gray road color
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2D3748),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Road surface texture
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
                        // Road center line (dashed)
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
                        // Road edge lines
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
          // Row letter label (like parking lot aisle markers)
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
          
          // Parking spots in this row
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
    Color spotColor = _getSpotTypeColor(spot.parkingSpotTypeId, spot.parkingSpotTypeName);
    String spotNumber = spot.parkingNumber.length > 1 ? spot.parkingNumber.substring(1) : spot.parkingNumber;
    bool isHovered = hoveredSpotId == spot.id;
    bool isTypeHovered = hoveredSpotTypeId != null && spot.parkingSpotTypeId == hoveredSpotTypeId;
    
    return Tooltip(
      message: '${spot.parkingNumber}\nType: ${spot.parkingSpotTypeName}\n${spot.isActive ? "Available" : "Unavailable"}\nClick to edit',
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
          onTap: () => _editSpot(spot),
          child: SizedBox(
            width: 50,
            height: 80,
            child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Parking spot lines (like real parking spaces)
              // Top line
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
              // Bottom line
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
              // Left line
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
              // Right line
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: const Color(0xFFCBD5E1),
                ),
              ),
              // Diagonal corner markers (like parking space corners)
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
              // Color indicator (top left corner) - rectangular and larger
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
              // Highlight border when this spot type is hovered in legend or this specific spot is hovered
              if (isTypeHovered || isHovered)
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
              // Spot number
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      spotNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        shadows: [
                          Shadow(
                            color: Colors.black12,
                            blurRadius: 1,
                            offset: Offset(0, 1),
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
              // Edit indicator
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
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
                  child: const Icon(
                    Icons.edit,
                    size: 11,
                    color: Color(0xFF64748B),
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

  Color _getSpotTypeColor(int? spotTypeId, String? spotTypeName) {
    if (spotTypeId == null) {
      return const Color(0xFF6B7280); // Default gray
    }
    
    // Check spot type name for special cases
    String name = (spotTypeName ?? '').toLowerCase();
    
    // Green for regular
    if (name.contains('regular') || name.contains('standard') || name.contains('normal')) {
      return const Color(0xFF10B981); // Green
    }
    
    // Red for compact
    if (name.contains('compact')) {
      return const Color(0xFFEF4444); // Red
    }
    
    // Orange for electric
    if (name.contains('electric')) {
      return const Color(0xFFF59E0B); // Orange
    }
    
    // Blue for disabled
    if (name.contains('disabled') || name.contains('handicap')) {
      return const Color(0xFF3B82F6); // Blue
    }
    
    // Purple for large
    if (name.contains('large')) {
      return const Color(0xFF8B5CF6); // Purple
    }
    
    // Default: Use a hash of the ID to consistently assign colors
    // Green - regular, Red - compact, Orange - electric, Blue - disabled, Purple - large
    int hash = spotTypeId % 5;
    switch (hash) {
      case 0:
        return const Color(0xFF10B981); // Green (regular)
      case 1:
        return const Color(0xFFEF4444); // Red (compact)
      case 2:
        return const Color(0xFFF59E0B); // Orange (electric)
      case 3:
        return const Color(0xFF3B82F6); // Blue (disabled)
      default:
        return const Color(0xFF8B5CF6); // Purple (large)
    }
  }

  Future<void> _editSpot(ParkingSpot spot) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingSpotEditScreen(spot: spot),
        settings: const RouteSettings(name: 'ParkingSpotEditScreen'),
      ),
    );

    // If the spot was updated, reload the spots
    if (result == true) {
      await _loadSpots();
    }
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
