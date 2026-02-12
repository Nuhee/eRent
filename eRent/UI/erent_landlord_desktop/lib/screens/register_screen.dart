import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:erent_landlord_desktop/providers/user_provider.dart';
import 'package:erent_landlord_desktop/providers/city_provider.dart';
import 'package:erent_landlord_desktop/providers/gender_provider.dart';
import 'package:erent_landlord_desktop/model/city.dart';
import 'package:erent_landlord_desktop/model/gender.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isLoadingCities = true;
  bool _isLoadingGenders = true;

  City? _selectedCity;
  Gender? _selectedGender;
  List<City> _cities = [];
  List<Gender> _genders = [];

  // Picture upload
  File? _image;
  String? _pictureBase64;

  // Validation error messages
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _phoneError;
  String? _genderError;
  String? _cityError;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final cityProvider = Provider.of<CityProvider>(context, listen: false);
      final genderProvider = Provider.of<GenderProvider>(context, listen: false);

      final citiesResult = await cityProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );
      final gendersResult = await genderProvider.get(
        filter: {
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        setState(() {
          _cities = citiesResult.items ?? [];
          _genders = gendersResult.items ?? [];
          _isLoadingCities = false;
          _isLoadingGenders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCities = false;
          _isLoadingGenders = false;
        });
        _showErrorDialog("Failed to load registration data: $e");
      }
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _pictureBase64 = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }

  void _fillDemoData() {
    if (_cities.isEmpty || _genders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait for data to load..."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      firstNameController.text = "Jane";
      lastNameController.text = "Smith";
      emailController.text = "jane.smith@example.com";
      usernameController.text = "janesmith";
      passwordController.text = "test";
      confirmPasswordController.text = "test";
      phoneController.text = "+1234567890";
      
      if (_genders.isNotEmpty) {
        _selectedGender = _genders.first;
      }
      
      if (_cities.isNotEmpty) {
        _selectedCity = _cities.first;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text("Demo data filled successfully!"),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          // Main content - Split layout
          Row(
            children: [
              // Left side - Logo and branding
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(60),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: -100.0, end: 0.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(value, 0),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 900),
                          tween: Tween(begin: -100.0, end: 0.0),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(value, 0),
                              child: Opacity(
                                opacity: _fadeAnimation.value,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.business_rounded,
                                          size: 48,
                                          color: Color(0xFFFFB84D),
                                        ),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Join eRent",
                                              style: TextStyle(
                                                fontSize: 38,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              "Landlord Portal",
                                              style: TextStyle(
                                                fontSize: 52,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFB84D),
                                                letterSpacing: 1,
                                                shadows: [
                                                  Shadow(
                                                    color: Color(0xFFFFB84D),
                                                    offset: Offset(0, 0),
                                                    blurRadius: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      width: 100,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFFB84D),
                                            Color(0xFFFFA366),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Text(
                                      "Create your landlord account\nand start managing properties",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Right side - Registration form
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 30,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Form title
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 700),
                            tween: Tween(begin: 100.0, end: 0.0),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(value, 0),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back_rounded),
                                        color: Colors.grey[700],
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.person_add_rounded,
                                                  color: Color(0xFFFFB84D),
                                                  size: 32,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  "Create Account",
                                                  style: const TextStyle(
                                                    fontSize: 36,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF212121),
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Register as a landlord",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.auto_fix_high_rounded),
                                        color: const Color(0xFFFFB84D),
                                        onPressed: _fillDemoData,
                                        tooltip: "Fill Demo Data",
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),

                          // Profile Picture Section
                          _image != null
                              ? Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          _image!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _image = null;
                                              _pictureBase64 = null;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_add_rounded,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Add Photo",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 24),

                          // First Name
                          _buildTextField(
                            controller: firstNameController,
                            label: "First Name",
                            hint: "Enter first name",
                            icon: Icons.person_outline,
                            errorText: _firstNameError,
                          ),
                          const SizedBox(height: 20),

                          // Last Name
                          _buildTextField(
                            controller: lastNameController,
                            label: "Last Name",
                            hint: "Enter last name",
                            icon: Icons.person_outline,
                            errorText: _lastNameError,
                          ),
                          const SizedBox(height: 20),

                          // Email
                          _buildTextField(
                            controller: emailController,
                            label: "Email",
                            hint: "Enter your email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            errorText: _emailError,
                          ),
                          const SizedBox(height: 20),

                          // Username
                          _buildTextField(
                            controller: usernameController,
                            label: "Username",
                            hint: "Choose a username",
                            icon: Icons.account_circle_outlined,
                            errorText: _usernameError,
                          ),
                          const SizedBox(height: 20),

                          // Password
                          _buildPasswordField(
                            controller: passwordController,
                            label: "Password",
                            hint: "Enter password",
                            isVisible: _isPasswordVisible,
                            onToggleVisibility: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            errorText: _passwordError,
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password
                          _buildPasswordField(
                            controller: confirmPasswordController,
                            label: "Confirm Password",
                            hint: "Confirm your password",
                            isVisible: _isConfirmPasswordVisible,
                            onToggleVisibility: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                            errorText: _confirmPasswordError,
                          ),
                          const SizedBox(height: 20),

                          // Phone
                          _buildTextField(
                            controller: phoneController,
                            label: "Phone Number",
                            hint: "Enter phone number",
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            errorText: _phoneError,
                          ),
                          const SizedBox(height: 24),

                          // Gender dropdown
                          if (_isLoadingGenders)
                            const Center(child: CircularProgressIndicator())
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<Gender>(
                                  value: _selectedGender,
                                  decoration: _buildInputDecoration(
                                    label: "Gender",
                                    icon: Icons.wc_rounded,
                                    errorText: _genderError,
                                  ),
                                  items: _genders.map((gender) {
                                    return DropdownMenuItem<Gender>(
                                      value: gender,
                                      child: Text(gender.name),
                                    );
                                  }).toList(),
                                  onChanged: (Gender? value) {
                                    setState(() {
                                      _selectedGender = value;
                                      _genderError = null;
                                    });
                                  },
                                ),
                                if (_genderError != null) ...[
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      _genderError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          const SizedBox(height: 20),

                          // City dropdown
                          if (_isLoadingCities)
                            const Center(child: CircularProgressIndicator())
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<City>(
                                  value: _selectedCity,
                                  decoration: _buildInputDecoration(
                                    label: "City",
                                    icon: Icons.location_city_rounded,
                                    errorText: _cityError,
                                  ),
                                  items: _cities.map((city) {
                                    return DropdownMenuItem<City>(
                                      value: city,
                                      child: Text(city.name),
                                    );
                                  }).toList(),
                                  onChanged: (City? value) {
                                    setState(() {
                                      _selectedCity = value;
                                      _cityError = null;
                                    });
                                  },
                                ),
                                if (_cityError != null) ...[
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text(
                                      _cityError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          const SizedBox(height: 40),

                          // Register button
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(begin: 100.0, end: 0.0),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(value, 0),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFB84D),
                                          Color(0xFFFFA366),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFB84D).withOpacity(0.4),
                                          spreadRadius: 0,
                                          blurRadius: 15,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              "Create Account",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.8,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Sign in link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFB84D),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: Colors.grey[900],
            fontSize: 16,
          ),
          decoration: _buildInputDecoration(
            label: label,
            hint: hint,
            icon: icon,
            errorText: errorText,
          ),
          onChanged: (_) {
            // Clear error when user starts typing
            if (errorText != null) {
              setState(() {
                if (controller == firstNameController) _firstNameError = null;
                if (controller == lastNameController) _lastNameError = null;
                if (controller == emailController) _emailError = null;
                if (controller == usernameController) _usernameError = null;
                if (controller == phoneController) _phoneError = null;
              });
            }
          },
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: !isVisible,
          style: TextStyle(
            color: Colors.grey[900],
            fontSize: 16,
          ),
          decoration: _buildInputDecoration(
            label: label,
            hint: hint,
            icon: Icons.lock_outline,
            errorText: errorText,
          ).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey[600],
                size: 22,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          onChanged: (_) {
            // Clear error when user starts typing
            if (errorText != null) {
              setState(() {
                if (controller == passwordController) _passwordError = null;
                if (controller == confirmPasswordController) _confirmPasswordError = null;
              });
            }
          },
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    String? errorText,
  }) {
    final hasError = errorText != null;
    return InputDecoration(
      labelText: label,
      hintText: hint ?? "Enter $label",
      prefixIcon: Icon(
        icon,
        color: hasError ? Colors.red : const Color(0xFFFFB84D),
      ),
      filled: true,
      fillColor: hasError ? Colors.red[50] : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? Colors.red : const Color(0xFFFFB84D),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final registrationData = {
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": emailController.text.trim(),
        "username": usernameController.text.trim(),
        "password": passwordController.text,
        "phoneNumber": phoneController.text.trim(),
        "genderId": _selectedGender!.id,
        "cityId": _selectedCity!.id,
        "isActive": true,
        "roleIds": [3], // Landlord role
        "picture": _pictureBase64,
      };

      await userProvider.insert(registrationData);

      if (mounted) {
        _showSuccessDialog();
      }
    } on Exception catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      }
    } catch (e) {
      print(e);
      if (mounted) {
        _showErrorDialog("An unexpected error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      // Clear previous errors
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _usernameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _phoneError = null;
      _genderError = null;
      _cityError = null;

      // Validate first name
      if (firstNameController.text.trim().isEmpty) {
        _firstNameError = "First name is required.";
        isValid = false;
      }

      // Validate last name
      if (lastNameController.text.trim().isEmpty) {
        _lastNameError = "Last name is required.";
        isValid = false;
      }

      // Validate email
      if (emailController.text.trim().isEmpty) {
        _emailError = "Email is required.";
        isValid = false;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim())) {
        _emailError = "Please enter a valid email address.";
        isValid = false;
      }

      // Validate username
      if (usernameController.text.trim().isEmpty) {
        _usernameError = "Username is required.";
        isValid = false;
      }

      // Validate password
      if (passwordController.text.length < 4) {
        _passwordError = "Password must be at least 4 characters long.";
        isValid = false;
      }

      // Validate confirm password
      if (passwordController.text != confirmPasswordController.text) {
        _confirmPasswordError = "Passwords do not match.";
        isValid = false;
      }

      // Validate phone
      if (phoneController.text.trim().isEmpty) {
        _phoneError = "Phone number is required.";
        isValid = false;
      } else {
        final phoneRegex = RegExp(r'^[+]?[\d\s\-()]{9,}$');
        if (!phoneRegex.hasMatch(phoneController.text.trim())) {
          _phoneError = "Please enter a valid phone number (at least 9 digits).";
          isValid = false;
        }
      }

      // Validate gender
      if (_selectedGender == null) {
        _genderError = "Please select a gender.";
        isValid = false;
      }

      // Validate city
      if (_selectedCity == null) {
        _cityError = "Please select a city.";
        isValid = false;
      }
    });

    return isValid;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFFFB84D)),
            SizedBox(width: 8),
            Text("Registration Failed"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFB84D),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text("Registration Success!"),
          ],
        ),
        content: const Text(
          "Your landlord account has been created successfully! You can now sign in with your credentials.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFB84D),
            ),
            child: const Text("Sign In"),
          ),
        ],
      ),
    );
  }
}
