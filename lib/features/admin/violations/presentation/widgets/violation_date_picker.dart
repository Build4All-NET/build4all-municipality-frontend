import 'package:flutter/material.dart';

class ViolationDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDatePicked;
  final String selectText;

  const ViolationDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDatePicked,
    required this.selectText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          onDatePicked(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedDate == null
                  ? selectText
                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}