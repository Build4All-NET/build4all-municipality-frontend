import 'package:flutter/material.dart';

class ViolationSubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ViolationSubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}