import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

// ---------------------------
// Custom Switch Field Helper
// ---------------------------
Widget customSwitchField({
  required String name,
  required String label,
  required bool initialValue,
  IconData? icon,
  String? description,
  Color? activeColor,
  Color? inactiveThumbColor,
  Color? inactiveTrackColor,
  Function(bool?)? onChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.grey.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: (activeColor ?? const Color(0xFF5B9BD5)).withOpacity(0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2937),
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 48,
          height: 28,
          child: FormBuilderField<bool>(
            name: name,
            initialValue: initialValue,
            builder: (FormFieldState<bool> field) {
              return Switch(
                value: field.value ?? initialValue,
                onChanged: (value) {
                  field.didChange(value);
                  if (onChanged != null) {
                    onChanged(value);
                  }
                },
                activeColor: activeColor ?? const Color(0xFF5B9BD5),
                inactiveThumbColor: inactiveThumbColor ?? Colors.grey[400],
                inactiveTrackColor: inactiveTrackColor ?? Colors.grey[300],
              );
            },
          ),
        ),
      ],
    ),
  );
}
