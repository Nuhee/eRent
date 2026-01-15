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
import 'package:erent_desktop/utils/base_switch.dart';
import 'package:erent_desktop/screens/users_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

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
      "cityId": widget.user.cityId,
      "genderId": widget.user.genderId,
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

      final result = await cityProvider.get(filter: {
        'isActive': true,
        'retrieveAll': true,
      });
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
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
              ),
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

    return FormBuilderDropdown<int?>(
      name: "cityId",
      decoration: customTextFieldDecoration(
        "City",
        prefixIcon: Icons.location_city_outlined,
        hintText: "Select a city",
      ),
      items: _cities.map((city) {
        return DropdownMenuItem<int?>(
          value: city.id,
          child: Text(city.name),
        );
      }).toList(),
      initialValue: _selectedCity?.id,
      onChanged: (int? value) {
        setState(() {
          _selectedCity = _cities.firstWhere((c) => c.id == value);
        });
      },
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
      ]),
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
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
              ),
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

    return FormBuilderDropdown<int?>(
      name: "genderId",
      decoration: customTextFieldDecoration(
        "Gender",
        prefixIcon: Icons.person_outline,
        hintText: "Select a gender",
      ),
      items: _genders.map((gender) {
        return DropdownMenuItem<int?>(
          value: gender.id,
          child: Text(gender.name),
        );
      }).toList(),
      initialValue: _selectedGender?.id,
      onChanged: (int? value) {
        setState(() {
          _selectedGender = _genders.firstWhere((g) => g.id == value);
        });
      },
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(),
      ]),
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
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isSaving
              ? null
                : () async {
                  formKey.currentState?.saveAndValidate();
                  if (formKey.currentState?.validate() ?? false) {
                    setState(() => _isSaving = true);
                    var request = Map.from(formKey.currentState?.value ?? {});
                    request['picture'] = _initialValue['picture'];

                    try {
                      await userProvider.update(widget.user.id, request);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Text('User updated successfully'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            duration: const Duration(seconds: 2),
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
                      }
                    } catch (e) {
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red, size: 24),
                                SizedBox(width: 12),
                                Text(
                                  'Error',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                              style: const TextStyle(fontSize: 15),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[600],
                                ),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5B9BD5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
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
            backgroundColor: _isSaving
                ? Colors.grey[300]
                : const Color(0xFF5B9BD5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
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
      ],
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Image Insert
          SizedBox(
            width: 280,
            child: BaseImageInsert(
              imageBase64: _initialValue['picture'] as String?,
              onImageChanged: (String? base64) {
                setState(() {
                  _initialValue['picture'] = base64;
                });
              },
              title: 'PROFILE PICTURE',
              icon: Icons.person_rounded,
              selectButtonLabel: 'Select',
              clearButtonLabel: 'Clear',
              placeholderText: 'No profile picture',
              placeholderSubtext: "Click 'Select' to add",
              compact: true,
            ),
          ),
          const SizedBox(width: 16),
          // Middle and Right Columns - Form
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  // Form Card
                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5B9BD5),
                  Color(0xFF7AB8CC),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B9BD5).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.edit_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update user information for ${widget.user.firstName} ${widget.user.lastName}',
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
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FormBuilder(
        key: formKey,
        initialValue: _initialValue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B9BD5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF5B9BD5),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                            errorText: 'Please enter a valid phone number',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      _buildCityDropdown(),
                      const SizedBox(height: 20),
                      _buildGenderDropdown(),
                      const SizedBox(height: 20),
                      customSwitchField(
                        name: "isActive",
                        label: "Active Status",
                        initialValue: widget.user.isActive,
                        icon: Icons.toggle_on_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Save and Cancel Buttons
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }
}
