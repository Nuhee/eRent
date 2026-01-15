import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/car.dart';
import 'package:erent_desktop/model/brand.dart';
import 'package:erent_desktop/model/color.dart' as model;
import 'package:erent_desktop/model/user.dart';
import 'package:erent_desktop/providers/car_provider.dart';
import 'package:erent_desktop/providers/brand_provider.dart';
import 'package:erent_desktop/providers/color_provider.dart';
import 'package:erent_desktop/providers/user_provider.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:erent_desktop/utils/base_image_insert.dart';
import 'package:erent_desktop/screens/car_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Brown color scheme matching the app
const Color _brownPrimary = Color(0xFF8B6F47);
const Color _brownDark = Color(0xFF6B5434);

class CarEditScreen extends StatefulWidget {
  final Car car;

  const CarEditScreen({super.key, required this.car});

  @override
  State<CarEditScreen> createState() => _CarEditScreenState();
}

class _CarEditScreenState extends State<CarEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CarProvider carProvider;
  late BrandProvider brandProvider;
  late ColorProvider colorProvider;
  late UserProvider userProvider;
  bool isLoading = true;
  bool _isLoadingBrands = true;
  bool _isLoadingColors = true;
  bool _isLoadingUsers = true;
  bool _isSaving = false;
  List<Brand> _brands = [];
  List<model.CarColor> _colors = [];
  List<User> _users = [];
  Brand? _selectedBrand;
  model.CarColor? _selectedColor;
  User? _selectedUser;

  @override
  void initState() {
    super.initState();
    carProvider = Provider.of<CarProvider>(context, listen: false);
    brandProvider = Provider.of<BrandProvider>(context, listen: false);
    colorProvider = Provider.of<ColorProvider>(context, listen: false);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _initialValue = {
      "model": widget.car.model,
      "licensePlate": widget.car.licensePlate,
      "yearOfManufacture": widget.car.yearOfManufacture.toString(),
      "isActive": widget.car.isActive,
      "picture": widget.car.picture,
    };
    initFormData();
    _loadBrands();
    _loadColors();
    _loadUsers();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadBrands() async {
    try {
      setState(() {
        _isLoadingBrands = true;
      });

      final result = await brandProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _brands = result.items!;
          _isLoadingBrands = false;
        });
        _setDefaultBrandSelection();
      } else {
        setState(() {
          _brands = [];
          _isLoadingBrands = false;
        });
      }
    } catch (e) {
      setState(() {
        _brands = [];
        _isLoadingBrands = false;
      });
    }
  }

  void _setDefaultBrandSelection() {
    if (_brands.isNotEmpty) {
      try {
        _selectedBrand = _brands.firstWhere(
          (brand) => brand.id == widget.car.brandId,
          orElse: () => _brands.first,
        );
      } catch (e) {
        _selectedBrand = _brands.first;
      }
      setState(() {});
    }
  }

  Future<void> _loadColors() async {
    try {
      setState(() {
        _isLoadingColors = true;
      });

      final result = await colorProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _colors = result.items!;
          _isLoadingColors = false;
        });
        _setDefaultColorSelection();
      } else {
        setState(() {
          _colors = [];
          _isLoadingColors = false;
        });
      }
    } catch (e) {
      setState(() {
        _colors = [];
        _isLoadingColors = false;
      });
    }
  }

  void _setDefaultColorSelection() {
    if (_colors.isNotEmpty) {
      try {
        _selectedColor = _colors.firstWhere(
          (color) => color.id == widget.car.colorId,
          orElse: () => _colors.first,
        );
      } catch (e) {
        _selectedColor = _colors.first;
      }
      setState(() {});
    }
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoadingUsers = true;
      });

      final result = await userProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _users = result.items!;
          _isLoadingUsers = false;
        });
        _setDefaultUserSelection();
      } else {
        setState(() {
          _users = [];
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      setState(() {
        _users = [];
        _isLoadingUsers = false;
      });
    }
  }

  void _setDefaultUserSelection() {
    if (_users.isNotEmpty) {
      try {
        _selectedUser = _users.firstWhere(
          (user) => user.id == widget.car.userId,
          orElse: () => _users.first,
        );
      } catch (e) {
        _selectedUser = _users.first;
      }
      setState(() {});
    }
  }

  Widget _buildBrandDropdown() {
    if (_isLoadingBrands) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading brands...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_brands.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No brands available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<Brand>(
      value: _selectedBrand,
      decoration: customTextFieldDecoration(
        "Brand",
        prefixIcon: Icons.branding_watermark,
      ),
      items: _brands.map((brand) {
        return DropdownMenuItem<Brand>(value: brand, child: Text(brand.name));
      }).toList(),
      onChanged: (Brand? value) {
        setState(() {
          _selectedBrand = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a brand";
        }
        return null;
      },
    );
  }

  Widget _buildColorDropdown() {
    if (_isLoadingColors) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading colors...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_colors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No colors available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<model.CarColor>(
      value: _selectedColor,
      decoration: customTextFieldDecoration("Color", prefixIcon: Icons.palette),
      items: _colors.map((color) {
        return DropdownMenuItem<model.CarColor>(
          value: color,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _parseColor(color.hexCode),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(width: 12),
              Text(color.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (model.CarColor? value) {
        setState(() {
          _selectedColor = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a color";
        }
        return null;
      },
    );
  }

  Widget _buildUserDropdown() {
    if (_isLoadingUsers) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading users...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No users available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<User>(
      value: _selectedUser,
      decoration: customTextFieldDecoration("Owner", prefixIcon: Icons.person),
      items: _users.map((user) {
        return DropdownMenuItem<User>(
          value: user,
          child: Text('${user.firstName} ${user.lastName}'),
        );
      }).toList(),
      onChanged: (User? value) {
        setState(() {
          _selectedUser = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select an owner";
        }
        return null;
      },
    );
  }

  Color _parseColor(String hexCode) {
    try {
      return Color(int.parse(hexCode.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Edit Car",
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
                      if (_selectedBrand == null || _selectedColor == null || _selectedUser == null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Validation Error'),
                            content: const Text(
                              'Please select brand, color, and owner',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      setState(() => _isSaving = true);
                      var request = Map.from(formKey.currentState?.value ?? {});
                      request['brandId'] = _selectedBrand!.id;
                      request['colorId'] = _selectedColor!.id;
                      request['userId'] = _selectedUser!.id;
                      request['picture'] = _initialValue['picture'];
                      // Convert yearOfManufacture from String to int
                      if (request['yearOfManufacture'] is String) {
                        request['yearOfManufacture'] = int.tryParse(request['yearOfManufacture'] as String) ?? widget.car.yearOfManufacture;
                      }

                      try {
                        await carProvider.update(widget.car.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Car updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const CarListScreen(),
                            settings: const RouteSettings(
                              name: 'CarListScreen',
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
                                      "EDIT CAR",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Update Car Information",
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

                          // Car picture section
                          BaseImageInsert(
                            imageBase64: _initialValue['picture'] as String?,
                            onImageChanged: (String? base64) {
                              setState(() {
                                _initialValue['picture'] = base64;
                              });
                            },
                            title: 'CAR PICTURE',
                            icon: Icons.directions_car_rounded,
                            selectButtonLabel: 'Select Image',
                            clearButtonLabel: 'Clear Image',
                            placeholderText: 'No car picture',
                            placeholderSubtext: "Click 'Select Image' to add a car picture",
                          ),
                          const SizedBox(height: 32),
                          // Form fields in two columns
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Use responsive layout: stack vertically on smaller screens
                              if (constraints.maxWidth < 800) {
                                return Column(
                                  children: [
                                    FormBuilderTextField(
                                      name: "model",
                                      decoration: customTextFieldDecoration(
                                        "Model",
                                        prefixIcon: Icons.directions_car_outlined,
                                      ),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                        FormBuilderValidators.maxLength(100),
                                      ]),
                                    ),
                                    const SizedBox(height: 16),
                                    FormBuilderTextField(
                                      name: "licensePlate",
                                      decoration: customTextFieldDecoration(
                                        "License Plate",
                                        prefixIcon: Icons.confirmation_number,
                                      ),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                        FormBuilderValidators.maxLength(20),
                                      ]),
                                    ),
                                    const SizedBox(height: 16),
                                    FormBuilderTextField(
                                      name: "yearOfManufacture",
                                      decoration: customTextFieldDecoration(
                                        "Year of Manufacture",
                                        prefixIcon: Icons.calendar_today,
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(),
                                        FormBuilderValidators.integer(),
                                        FormBuilderValidators.min(1900),
                                        FormBuilderValidators.max(2100),
                                      ]),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildBrandDropdown(),
                                    const SizedBox(height: 16),
                                    _buildColorDropdown(),
                                    const SizedBox(height: 16),
                                    _buildUserDropdown(),
                                    const SizedBox(height: 16),
                                    FormBuilderSwitch(
                                      name: 'isActive',
                                      title: const Text('Active Car'),
                                      initialValue:
                                          _initialValue['isActive'] as bool? ??
                                          true,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              // Two columns on larger screens
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left column
                                  Expanded(
                                    child: Column(
                                      children: [
                                        FormBuilderTextField(
                                          name: "model",
                                          decoration: customTextFieldDecoration(
                                            "Model",
                                            prefixIcon: Icons.directions_car_outlined,
                                          ),
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.maxLength(100),
                                          ]),
                                        ),
                                        const SizedBox(height: 16),
                                        FormBuilderTextField(
                                          name: "licensePlate",
                                          decoration: customTextFieldDecoration(
                                            "License Plate",
                                            prefixIcon: Icons.confirmation_number,
                                          ),
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.maxLength(20),
                                          ]),
                                        ),
                                        const SizedBox(height: 16),
                                        FormBuilderTextField(
                                          name: "yearOfManufacture",
                                          decoration: customTextFieldDecoration(
                                            "Year of Manufacture",
                                            prefixIcon: Icons.calendar_today,
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.integer(),
                                            FormBuilderValidators.min(1900),
                                            FormBuilderValidators.max(2100),
                                          ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Right column
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildBrandDropdown(),
                                        const SizedBox(height: 16),
                                        _buildColorDropdown(),
                                        const SizedBox(height: 16),
                                        _buildUserDropdown(),
                                        const SizedBox(height: 16),
                                        FormBuilderSwitch(
                                          name: 'isActive',
                                          title: const Text('Active Car'),
                                          initialValue:
                                              _initialValue['isActive'] as bool? ??
                                              true,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
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

