import 'package:flutter/material.dart';
import 'package:baladiyati/l10n/app_localizations.dart';

// Backend enum values — must be sent exactly as listed here.
const List<String> kViolationTypes = [
  'TRAFFIC',
  'ENVIRONMENTAL',
  'URBANISM',
  'COMMERCIAL',
  'OTHER',
];

class ViolationCategoryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final String? Function(String?)? validator;
  final bool enabled;

  const ViolationCategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.category_outlined),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outline.withOpacity(0.22)),
        ),
      ),
      items: kViolationTypes
          .map(
            (type) => DropdownMenuItem(
              value: type,
              child: Text(switch (type) {
                'TRAFFIC' => l10n.violationTraffic,
                'ENVIRONMENTAL' => l10n.violationEnvironmental,
                'URBANISM' => l10n.violationUrbanism,
                'COMMERCIAL' => l10n.violationCommercial,
                'OTHER' => l10n.violationOther,
                _ => type,
              }),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}
