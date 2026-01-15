import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/country.dart';
import 'package:erent_desktop/providers/country_provider.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:erent_desktop/utils/base_switch.dart';
import 'package:erent_desktop/screens/country_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CountryEditScreen extends StatefulWidget {
  final Country? country;

  const CountryEditScreen({super.key, this.country});

  @override
  State<CountryEditScreen> createState() => _CountryEditScreenState();
}

class _CountryEditScreenState extends State<CountryEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CountryProvider countryProvider;
  bool isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    countryProvider = Provider.of<CountryProvider>(context, listen: false);
    _initialValue = {
      "name": widget.country?.name ?? '',
      "code": widget.country?.code ?? '',
      "isActive": widget.country?.isActive ?? true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.country != null ? "Edit Country" : "Add Country",
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

                    try {
                      if (widget.country == null) {
                        await countryProvider.insert(request);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Country created successfully'),
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
                        }
                      } else {
                        await countryProvider.update(widget.country!.id, request);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Country updated successfully'),
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
                        }
                      }
                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const CountryListScreen(),
                            settings: const RouteSettings(name: 'CountryListScreen'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
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
            child: Icon(
              widget.country != null
                  ? Icons.edit_rounded
                  : Icons.add_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.country != null ? 'Edit Country' : 'Add New Country',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.country != null
                      ? 'Update country information'
                      : 'Create a new country in the system',
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
                    Icons.flag_rounded,
                    color: Color(0xFF5B9BD5),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Country Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Country Name field
            FormBuilderTextField(
              name: "name",
              decoration: customTextFieldDecoration(
                "Country Name",
                prefixIcon: Icons.flag_outlined,
                hintText: "Enter country name",
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
            // Country Code field (optional)
            FormBuilderTextField(
              name: "code",
              decoration: customTextFieldDecoration(
                "Country Code",
                prefixIcon: Icons.code_outlined,
                hintText: "Enter country code (e.g., BA, HR)",
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.maxLength(3),
              ]),
            ),
            const SizedBox(height: 20),
            // IsActive switch
            customSwitchField(
              name: "isActive",
              label: "Active Status",
              initialValue: widget.country?.isActive ?? true,
              icon: Icons.toggle_on_rounded,
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
