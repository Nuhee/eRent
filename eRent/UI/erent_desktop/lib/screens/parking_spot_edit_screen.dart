import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erent_desktop/model/parking_spot.dart';
import 'package:erent_desktop/model/parking_spot_type.dart';
import 'package:erent_desktop/providers/parking_spot_provider.dart';
import 'package:erent_desktop/providers/parking_spot_type_provider.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Brown color scheme matching the app
const Color _brownPrimary = Color(0xFF8B6F47);
const Color _brownDark = Color(0xFF6B5434);

class ParkingSpotEditScreen extends StatefulWidget {
  final ParkingSpot spot;

  const ParkingSpotEditScreen({super.key, required this.spot});

  @override
  State<ParkingSpotEditScreen> createState() => _ParkingSpotEditScreenState();
}

class _ParkingSpotEditScreenState extends State<ParkingSpotEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  late ParkingSpotProvider parkingSpotProvider;
  late ParkingSpotTypeProvider parkingSpotTypeProvider;
  
  List<ParkingSpotType> spotTypes = [];
  ParkingSpotType? selectedSpotType;
  bool isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic> _initialValue = {};

  @override
  void initState() {
    super.initState();
    parkingSpotProvider = Provider.of<ParkingSpotProvider>(context, listen: false);
    parkingSpotTypeProvider = Provider.of<ParkingSpotTypeProvider>(context, listen: false);
    _initialValue = {
      "isActive": widget.spot.isActive,
    };
    _loadSpotTypes();
  }

  Future<void> _loadSpotTypes() async {
    try {
      setState(() {
        isLoading = true;
      });

      final typesResult = await parkingSpotTypeProvider.get(filter: {"pageSize": 1000});
      setState(() {
        spotTypes = typesResult.items ?? [];
        // Set current spot type as selected
        selectedSpotType = spotTypes.firstWhere(
          (type) => type.id == widget.spot.parkingSpotTypeId,
          orElse: () => spotTypes.first,
        );
        _initialValue["parkingSpotTypeId"] = selectedSpotType?.id;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading spot types: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: const Color(0xFF2D2D2D),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            gradient: _isSaving
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _brownPrimary,
                      _brownDark,
                    ],
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isSaving
                ? null
                : [
                    BoxShadow(
                      color: _brownPrimary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    formKey.currentState?.saveAndValidate();
                    if (formKey.currentState?.validate() ?? false) {
                      setState(() => _isSaving = true);
                      var request = Map<String, dynamic>.from(formKey.currentState?.value ?? {});
                      request['parkingNumber'] = widget.spot.parkingNumber;
                      request['parkingZoneId'] = widget.spot.parkingZoneId;
                      request['parkingSpotTypeId'] = selectedSpotType?.id ?? widget.spot.parkingSpotTypeId;

                      try {
                        await parkingSpotProvider.update(widget.spot.id, request);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Parking spot updated successfully!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                          Navigator.of(context).pop(true);
                        }
                      } catch (e) {
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: Text(
                                e.toString().replaceFirst('Exception: ', ''),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSaving ? Colors.grey[300] : Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Edit Parking Spot ${widget.spot.parkingNumber}",
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Hero section with gradient background
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _brownPrimary,
                      _brownDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _brownPrimary.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -40,
                      right: -40,
                      child: IgnorePointer(
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: IgnorePointer(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.local_parking_rounded,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "EDIT PARKING SPOT",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Spot ${widget.spot.parkingNumber}",
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Floating form card
              Transform.translate(
                offset: const Offset(0, -60),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: FormBuilder(
                      key: formKey,
                      initialValue: _initialValue,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          // Current spot info card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey[50]!,
                                  Colors.white,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _brownPrimary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: _brownPrimary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Zone: ${widget.spot.parkingZoneName}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Current Type: ${widget.spot.parkingSpotTypeName}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Form field section
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.grey[50]!,
                                  Colors.white,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _brownPrimary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _brownPrimary.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.local_parking_outlined,
                                        color: _brownPrimary,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'PARKING SPOT SETTINGS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[600],
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Spot type selector
                                const Text(
                                  'Parking Spot Type',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                                  ),
                                  child: FormBuilderDropdown<ParkingSpotType>(
                                    name: "parkingSpotTypeId",
                                    initialValue: selectedSpotType,
                                    decoration: customTextFieldDecoration(
                                      "Select Spot Type",
                                      prefixIcon: Icons.local_parking,
                                    ),
                                    items: spotTypes.map((spotType) {
                                      return DropdownMenuItem<ParkingSpotType>(
                                        value: spotType,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                color: _getSpotTypeColor(spotType.id, spotType.name),
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.black26, width: 1),
                                              ),
                                              child: Icon(
                                                Icons.local_parking,
                                                size: 12,
                                                color: _getTextColorForSpot(_getSpotTypeColor(spotType.id, spotType.name)),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              spotType.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSpotType = value;
                                      });
                                    },
                                    validator: FormBuilderValidators.required(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // IsActive Switch
                                FormBuilderSwitch(
                                  name: 'isActive',
                                  title: const Text('Active Parking Spot'),
                                  initialValue: _initialValue['isActive'] as bool? ?? true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Save and Cancel Buttons
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSpotTypeColor(int? spotTypeId, [String? spotTypeName]) {
    if (spotTypeId == null) {
      return const Color(0xFF6B7280); // Default gray
    }
    
    // Check spot type name for special cases (matching parking_spot_list_screen.dart)
    if (spotTypeName != null) {
      String name = spotTypeName.toLowerCase();
      
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

  Color _getTextColorForSpot(Color spotColor) {
    double luminance = (0.299 * spotColor.red + 0.587 * spotColor.green + 0.114 * spotColor.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
