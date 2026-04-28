// lib/common/widgets/app_search_field.dart

import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    this.controller,
    required this.hint,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.search, color: cs.outline),
        suffixIcon: onClear == null
            ? null
            : IconButton(
                icon: Icon(Icons.close, color: cs.outline),
                onPressed: onClear,
              ),
      ),
    );
  }
}