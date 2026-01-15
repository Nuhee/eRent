import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/reservation_type.dart';
import 'package:erent_desktop/providers/reservation_type_provider.dart';
import 'package:erent_desktop/screens/reservation_type_list_screen.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Brown color scheme matching the app
const Color _brownPrimary = Color(0xFF8B6F47);
const Color _brownDark = Color(0xFF6B5434);

class ReservationTypeEditScreen extends StatefulWidget {
  final ReservationType reservationType;

  const ReservationTypeEditScreen({super.key, required this.reservationType});

  @override
  State<ReservationTypeEditScreen> createState() => _ReservationTypeEditScreenState();
}

class _ReservationTypeEditScreenState extends State<ReservationTypeEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late ReservationTypeProvider reservationTypeProvider;
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    reservationTypeProvider = Provider.of<ReservationTypeProvider>(context, listen: false);
    _initialValue = {
      "price": widget.reservationType.price.toString(),
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
      title: "Edit Reservation Type",
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
                      // Keep the name unchanged, only update price
                      request['name'] = widget.reservationType.name;
                      // Convert price from String to double
                      if (request['price'] is String) {
                        request['price'] = double.tryParse(request['price'] as String) ?? widget.reservationType.price;
                      }

                      try {
                        await reservationTypeProvider.update(widget.reservationType.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reservation type updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ReservationTypeListScreen(),
                            settings: const RouteSettings(
                              name: 'ReservationTypeListScreen',
                            ),
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
          constraints: const BoxConstraints(maxWidth: 1200),
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
                                  Icons.edit_location_alt_rounded,
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
                                      "EDIT RESERVATION TYPE",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Update Price",
                                      style: TextStyle(
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
                        children: [
                          const SizedBox(height: 20),
                          // Name field (read-only)
                          FormBuilderTextField(
                            name: "name",
                            initialValue: widget.reservationType.name,
                            enabled: false,
                            decoration: customTextFieldDecoration(
                              "Reservation Type Name",
                              prefixIcon: Icons.event_available,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Price field (editable)
                          FormBuilderTextField(
                            name: "price",
                            decoration: customTextFieldDecoration(
                              "Price",
                              prefixIcon: Icons.attach_money,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.numeric(),
                              (value) {
                                if (value != null) {
                                  final price = double.tryParse(value);
                                  if (price == null || price <= 0) {
                                    return 'Price must be greater than 0';
                                  }
                                }
                                return null;
                              },
                            ]),
                          ),
                          const SizedBox(height: 32),
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

