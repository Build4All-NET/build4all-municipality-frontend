import 'package:flutter/material.dart';

class ViolationCategoryDropdown extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;
  final String hint;

  const ViolationCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      items: ["A", "B", "C"]
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}