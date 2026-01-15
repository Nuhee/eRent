import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/parking_spot_type.dart';
import 'package:erent_desktop/providers/parking_spot_type_provider.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:erent_desktop/screens/parking_spot_type_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Brown color scheme matching the app
const Color _brownPrimary = Color(0xFF8B6F47);
const Color _brownDark = Color(0xFF6B5434);

class ParkingSpotTypeEditScreen extends StatefulWidget {
  final ParkingSpotType? parkingSpotType;

  const ParkingSpotTypeEditScreen({super.key, this.parkingSpotType});

  @override
  State<ParkingSpotTypeEditScreen> createState() => _ParkingSpotTypeEditScreenState();
}

class _ParkingSpotTypeEditScreenState extends State<ParkingSpotTypeEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late ParkingSpotTypeProvider parkingSpotTypeProvider;
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    parkingSpotTypeProvider = Provider.of<ParkingSpotTypeProvider>(context, listen: false);
    _initialValue = {
      "name": widget.parkingSpotType?.name ?? '',
      "description": widget.parkingSpotType?.description ?? '',
      "priceMultiplier": (widget.parkingSpotType?.priceMultiplier ?? 1.0).toString(),
      "isActive": widget.parkingSpotType?.isActive ?? true,
    };
    initFormData();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.parkingSpotType != null ? "Edit Parking Spot Type" : "Add Parking Spot Type",
      showBackButton: true,
      child: _buildForm(),
    );
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
                      var request = Map.from(formKey.currentState?.value ?? {});
                      // Convert priceMultiplier from String to double
                      if (request['priceMultiplier'] is String) {
                        request['priceMultiplier'] = double.parse(request['priceMultiplier']);
                      }

                      try {
                        if (widget.parkingSpotType == null) {
                          await parkingSpotTypeProvider.insert(request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Parking spot type created successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          await parkingSpotTypeProvider.update(widget.parkingSpotType!.id, request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Parking spot type updated successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ParkingSpotTypeListScreen(),
                            settings: const RouteSettings(name: 'ParkingSpotTypeListScreen'),
                          ),
                        );
                      } catch (e) {
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
                                child: Icon(
                                  widget.parkingSpotType != null
                                      ? Icons.edit_location_alt_rounded
                                      : Icons.add_location_alt_rounded,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.parkingSpotType != null
                                          ? "EDIT PARKING SPOT TYPE"
                                          : "ADD NEW PARKING SPOT TYPE",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.parkingSpotType != null
                                          ? "Update Parking Spot Type Information"
                                          : "Create a New Parking Spot Type",
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
                                      'PARKING SPOT TYPE INFORMATION',
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
                                // Name field
                                FormBuilderTextField(
                                  name: "name",
                                  decoration: customTextFieldDecoration(
                                    "Name",
                                    prefixIcon: Icons.local_parking_outlined,
                                    hintText: "Enter parking spot type name",
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.maxLength(50),
                                  ]),
                                ),
                                const SizedBox(height: 16),
                                // Description field
                                FormBuilderTextField(
                                  name: "description",
                                  decoration: customTextFieldDecoration(
                                    "Description",
                                    prefixIcon: Icons.description_outlined,
                                    hintText: "Enter description (optional)",
                                  ),
                                  maxLines: 3,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.maxLength(200),
                                  ]),
                                ),
                                const SizedBox(height: 16),
                                // Price Multiplier field
                                FormBuilderTextField(
                                  name: "priceMultiplier",
                                  decoration: customTextFieldDecoration(
                                    "Price Multiplier",
                                    prefixIcon: Icons.attach_money_outlined,
                                    hintText: "Enter price multiplier (e.g., 1.0)",
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.numeric(),
                                    (value) {
                                      if (value != null && value.isNotEmpty) {
                                        final num = double.tryParse(value);
                                        if (num == null || num <= 0) {
                                          return 'Price multiplier must be greater than 0';
                                        }
                                      }
                                      return null;
                                    },
                                  ]),
                                ),
                                const SizedBox(height: 16),
                                // IsActive Switch
                                FormBuilderSwitch(
                                  name: 'isActive',
                                  title: const Text('Active Parking Spot Type'),
                                  initialValue:
                                      _initialValue['isActive'] as bool? ?? true,
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
}

