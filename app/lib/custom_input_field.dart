import 'package:flutter/material.dart';

/// Champ de texte stylisé réutilisable.
class CustomInputField extends StatefulWidget {
  const CustomInputField({
    super.key,
    required this.hintText,
    required this.controller,
    this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final String hintText;
  final TextEditingController controller;
  final IconData? icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType ??
          (widget.isPassword
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress),
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: const Color(0xFF001F5B))
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF001F5B), width: 1.5),
        ),
      ),
    );
  }
}