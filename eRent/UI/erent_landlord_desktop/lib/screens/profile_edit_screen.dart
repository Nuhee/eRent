import 'package:flutter/material.dart';
import 'package:erent_landlord_desktop/layouts/master_screen.dart';
import 'package:erent_landlord_desktop/model/user.dart';
import 'package:erent_landlord_desktop/model/city.dart';
import 'package:erent_landlord_desktop/model/gender.dart';
import 'package:erent_landlord_desktop/providers/user_provider.dart';
import 'package:erent_landlord_desktop/providers/city_provider.dart';
import 'package:erent_landlord_desktop/providers/gender_provider.dart';
import 'package:erent_landlord_desktop/utils/base_textfield.dart';
import 'package:erent_landlord_desktop/utils/base_image_insert.dart';
import 'package:erent_landlord_desktop/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
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

  User? get currentUser => UserProvider.currentUser;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    cityProvider = Provider.of<CityProvider>(context, listen: false);
    genderProvider = Provider.of<GenderProvider>(context, listen: false);
    _initializeFormData();
    _loadCities();
    _loadGenders();
  }

  void _initializeFormData() {
    if (currentUser != null) {
      _initialValue = {
        "firstName": currentUser!.firstName,
        "lastName": currentUser!.lastName,
        "email": currentUser!.email,
        "username": currentUser!.username,
        "phoneNumber": currentUser!.phoneNumber ?? '',
        "picture": currentUser!.picture,
        "cityId": currentUser!.cityId,
        "genderId": currentUser!.genderId,
      };
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCities() async {
    try {
      setState(() => _isLoadingCities = true);

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
    if (_cities.isNotEmpty && currentUser != null) {
      try {
        _selectedCity = _cities.firstWhere(
          (city) => city.id == currentUser!.cityId,
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
      setState(() => _isLoadingGenders = true);

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
    if (_genders.isNotEmpty && currentUser != null) {
      try {
        _selectedGender = _genders.firstWhere(
          (gender) => gender.id == currentUser!.genderId,
          orElse: () => _genders.first,
        );
      } catch (e) {
        _selectedGender = _genders.first;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Edit Profile',
      showBackButton: true,
      child: currentUser == null
          ? const Center(child: Text('No user data available'))
          : _buildEditView(),
    );
  }

  Widget _buildEditView() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
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
          // Right Column - Form
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditHeader(),
                  const SizedBox(height: 24),
                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
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
                colors: [Color(0xFFFFB84D), Color(0xFFFFA366)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB84D).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.edit_rounded, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Update your personal information',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
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
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
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
            // Section Header - Personal Information
            _buildSectionHeader('Personal Information', Icons.person_rounded),
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
                            errorText: 'Only letters and spaces allowed',
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
                            errorText: 'Only letters and spaces allowed',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        name: "email",
                        decoration: customTextFieldDecoration(
                          "Email",
                          prefixIcon: Icons.email_outlined,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        name: "phoneNumber",
                        decoration: customTextFieldDecoration(
                          "Phone Number (Optional)",
                          prefixIcon: Icons.phone_outlined,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.match(
                            RegExp(r'^[\d\s\-\+\(\)]*$'),
                            errorText: 'Please enter a valid phone number',
                          ),
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
                        name: "username",
                        enabled: false, // Username cannot be changed
                        decoration: customTextFieldDecoration(
                          "Username (cannot be changed)",
                          prefixIcon: Icons.alternate_email,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCityDropdown(),
                      const SizedBox(height: 20),
                      _buildGenderDropdown(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Password Section
            _buildSectionHeader('Change Password', Icons.lock_outline),
            const SizedBox(height: 16),
            Text(
              'Leave both fields empty to keep your current password',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FormBuilderTextField(
                    name: "password",
                    obscureText: true,
                    decoration: customTextFieldDecoration(
                      "New Password",
                      prefixIcon: Icons.lock_outline,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: FormBuilderTextField(
                    name: "confirmPassword",
                    obscureText: true,
                    decoration: customTextFieldDecoration(
                      "Confirm New Password",
                      prefixIcon: Icons.lock_outline,
                    ),
                    validator: (value) {
                      final password =
                          formKey.currentState?.fields['password']?.value;
                      if (password != null &&
                          password.toString().isNotEmpty &&
                          value != password) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB84D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFFB84D),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
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
        child:
            const Text("No cities available", style: TextStyle(color: Colors.red)),
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
        if (value != null) {
          setState(() {
            _selectedCity = _cities.firstWhere((c) => c.id == value);
          });
        }
      },
      validator: FormBuilderValidators.required(),
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
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
        child:
            const Text("No genders available", style: TextStyle(color: Colors.red)),
      );
    }

    return FormBuilderDropdown<int?>(
      name: "genderId",
      decoration: customTextFieldDecoration(
        "Gender",
        prefixIcon: Icons.wc_outlined,
        hintText: "Select gender",
      ),
      items: _genders.map((gender) {
        return DropdownMenuItem<int?>(
          value: gender.id,
          child: Text(gender.name),
        );
      }).toList(),
      initialValue: _selectedGender?.id,
      onChanged: (int? value) {
        if (value != null) {
          setState(() {
            _selectedGender = _genders.firstWhere((g) => g.id == value);
          });
        }
      },
      validator: FormBuilderValidators.required(),
    );
  }

  Widget _buildActionButtons() {
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
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isSaving ? Colors.grey[300] : const Color(0xFFFFB84D),
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
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    formKey.currentState?.saveAndValidate();
    if (formKey.currentState?.validate() ?? false) {
      // Additional password match validation
      final password = formKey.currentState?.fields['password']?.value;
      final confirmPassword =
          formKey.currentState?.fields['confirmPassword']?.value;

      if (password != null &&
          password.toString().isNotEmpty &&
          password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Passwords do not match'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      setState(() => _isSaving = true);

      var request =
          Map<String, dynamic>.from(formKey.currentState?.value ?? {});
      request['picture'] = _initialValue['picture'];
      request['isActive'] = true; // Keep active

      // Get the current user's roles
      final currentRoles = currentUser?.roles.map((r) => r.id).toList() ?? [];
      request['roleIds'] = currentRoles;

      // Remove password if empty - don't change password
      if (request['password'] == null ||
          request['password'].toString().isEmpty) {
        request.remove('password');
      }

      // Remove confirmPassword from request (not needed for API)
      request.remove('confirmPassword');

      try {
        final updatedUser = await userProvider.update(currentUser!.id, request);

        // Update the current user in the provider
        UserProvider.currentUser = updatedUser;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Profile updated successfully'),
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

          // Navigate back to profile screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ProfileScreen(),
              settings: const RouteSettings(name: 'ProfileScreen'),
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
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB84D),
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
  }
}
