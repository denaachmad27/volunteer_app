import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String? hint;
  final IconData? prefixIcon;
  final bool isRequired;

  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.hint,
    this.prefixIcon,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF475569),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint ?? 'Pilih $label',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: const Color(0xFFff5001),
                    size: 20,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFff5001), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          dropdownColor: Colors.white,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF475569),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFFff5001),
            size: 24,
          ),
          isExpanded: true,
        ),
      ],
    );
  }
}