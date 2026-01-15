import 'package:flutter/material.dart';
  import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/user.dart';
import 'package:erent_desktop/model/city.dart';
import 'package:erent_desktop/model/gender.dart';
import 'package:erent_desktop/providers/user_provider.dart';
import 'package:erent_desktop/providers/city_provider.dart';
import 'package:erent_desktop/providers/gender_provider.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:erent_desktop/utils/base_image_insert.dart';
import 'package:erent_desktop/screens/users_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Brown color scheme matching the app
const Color _brownPrimary = Color(0xFF8B6F47);
const Color _brownDark = Color(0xFF6B5434);

class UsersEditScreen extends StatefulWidget {
  final User user;

  const UsersEditScreen({super.key, required this.user});

  @override
  State<UsersEditScreen> createState() => _UsersEditScreenState();
}

class _UsersEditScreenState extends State<UsersEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late UserProvider userProvider;
  late CityProvider cityProvider;
  late GenderProvider genderProvider;
  bool isLoading = true;
  bool _isLoadingCities = true;
  bool _isLoadingGenders = true;
  bool _isSaving = false;
  List<City> _cities = [];
  List<Gender> _genders = [];
  City? _selectedCity;
  Gender? _selectedGender;

  final double leftColumnWidth = 300;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    cityProvider = Provider.of<CityProvider>(context, listen: false);
    genderProvider = Provider.of<GenderProvider>(context, listen: false);
    _initialValue = {
      "firstName": widget.user.firstName,
      "lastName": widget.user.lastName,
      "email": widget.user.email,
      "username": widget.user.username,
      "phoneNumber": widget.user.phoneNumber ?? '',
      "isActive": widget.user.isActive,
      "picture": widget.user.picture,
    };
    initFormData();
    _loadCities();
    _loadGenders();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCities() async {
    try {
      setState(() {
        _isLoadingCities = true;
      });

      final result = await cityProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _cities = result.items!;
          _isLoadingCities = false;
        });
        _setDefaultCitySelection();
      } else {
        setState(() {
          _cities = [];
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      setState(() {
        _cities = [];
        _isLoadingCities = false;
      });
    }
  }

  void _setDefaultCitySelection() {
    if (_cities.isNotEmpty) {
      try {
        _selectedCity = _cities.firstWhere(
          (city) => city.id == widget.user.cityId,
          orElse: () => _cities.first,
        );
      } catch (e) {
        _selectedCity = _cities.first;
      }
      setState(() {});
    }
  }

  Future<void> _loadGenders() async {
    try {
      setState(() {
        _isLoadingGenders = true;
      });

      final result = await genderProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _genders = result.items!;
          _isLoadingGenders = false;
        });
        _setDefaultGenderSelection();
      } else {
        setState(() {
          _genders = [];
          _isLoadingGenders = false;
        });
      }
    } catch (e) {
      setState(() {
        _genders = [];
        _isLoadingGenders = false;
      });
    }
  }

  void _setDefaultGenderSelection() {
    if (_genders.isNotEmpty) {
      try {
        _selectedGender = _genders.firstWhere(
          (gender) => gender.id == widget.user.genderId,
          orElse: () => _genders.first,
        );
      } catch (e) {
        _selectedGender = _genders.first;
      }
      setState(() {});
    }
  }


  Widget _buildCityDropdown() {
    if (_isLoadingCities) {
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
            Text("Loading cities...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_cities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No cities available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<City>(
      value: _selectedCity,
      decoration: customTextFieldDecoration(
        "City",
        prefixIcon: Icons.location_city,
      ),
      items: _cities.map((city) {
        return DropdownMenuItem<City>(value: city, child: Text(city.name));
      }).toList(),
      onChanged: (City? value) {
        setState(() {
          _selectedCity = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a city";
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    if (_isLoadingGenders) {
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
            Text("Loading genders...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_genders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No genders available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: customTextFieldDecoration("Gender", prefixIcon: Icons.person),
      items: _genders.map((gender) {
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(gender.name),
        );
      }).toList(),
      onChanged: (Gender? value) {
        setState(() {
          _selectedGender = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a gender";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Edit User",
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
                    if (_selectedCity == null || _selectedGender == null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Validation Error'),
                          content: const Text(
                            'Please select both city and gender',
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
                    request['cityId'] = _selectedCity!.id;
                    request['genderId'] = _selectedGender!.id;
                    request['picture'] = _initialValue['picture'];

                    try {
                      await userProvider.update(widget.user.id, request);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User updated successfully'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const UsersListScreen(),
                          settings: const RouteSettings(
                            name: 'UsersListScreen',
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
                                      "EDIT USER",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Update User Information",
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
                        children: [
                          const SizedBox(height: 20),

                          // Profile picture section
                          BaseImageInsert(
                            imageBase64: _initialValue['picture'] as String?,
                            onImageChanged: (String? base64) {
                              setState(() {
                                _initialValue['picture'] = base64;
                              });
                            },
                            title: 'PROFILE PICTURE',
                            icon: Icons.person_rounded,
                            selectButtonLabel: 'Select Image',
                            clearButtonLabel: 'Clear Image',
                            placeholderText: 'No profile picture',
                            placeholderSubtext: "Click 'Select Image' to add a profile picture",
                          ),
                          const SizedBox(height: 32),
                          // Form fields in two columns
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column
                              Expanded(
                                child: Column(
                                  children: [
                                    FormBuilderTextField(
                                    name: "firstName",
                                    decoration: customTextFieldDecoration(
                                      "First Name",
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.match(
                                        RegExp(r'^[\p{L} ]+$', unicode: true),
                                        errorText:
                                            'Only letters (including international), and spaces allowed',
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    name: "lastName",
                                    decoration: customTextFieldDecoration(
                                      "Last Name",
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.match(
                                        RegExp(r'^[\p{L} ]+$', unicode: true),
                                        errorText:
                                            'Only letters (including international), and spaces allowed',
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    name: "username",
                                    decoration: customTextFieldDecoration(
                                      "Username",
                                      prefixIcon: Icons.alternate_email,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.minLength(3),
                                      FormBuilderValidators.maxLength(50),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    name: "email",
                                    decoration: customTextFieldDecoration(
                                      "Email",
                                      prefixIcon: Icons.email,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.email(),
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
                                    FormBuilderTextField(
                                    name: "phoneNumber",
                                    decoration: customTextFieldDecoration(
                                      "Phone Number (Optional)",
                                      prefixIcon: Icons.phone,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.match(
                                        RegExp(r'^[\d\s\-\+\(\)]+$'),
                                        errorText:
                                            'Please enter a valid phone number',
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCityDropdown(),
                                  const SizedBox(height: 16),
                                  _buildGenderDropdown(),
                                  const SizedBox(height: 16),
                                  FormBuilderSwitch(
                                    name: 'isActive',
                                    title: const Text('Active Account'),
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
