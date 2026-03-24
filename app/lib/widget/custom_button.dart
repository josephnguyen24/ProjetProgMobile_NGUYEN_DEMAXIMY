import 'package:flutter/material.dart';

/// Bouton stylisé réutilisable dans toute l'application.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 197,
      height: 45,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFBAF02),
          foregroundColor: const Color(0xFF001F5B),
          disabledBackgroundColor: const Color(0xFF001F5B).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF080040),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF080040),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.36,
                ),
              ),
      ),
    );
  }
}
