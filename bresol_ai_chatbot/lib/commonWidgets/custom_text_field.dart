import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool enabled; //
  final int maxLength;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.validator,
    this.isPassword = false,
    this.maxLength = 50,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  IconData _getPrefixIcon() {
    if (widget.isPassword) return Icons.lock_outline;
    if (widget.labelText.toLowerCase().contains("name")) return Icons.person_outline;
    if (widget.labelText.toLowerCase().contains("mobile") ||
        widget.labelText.toLowerCase().contains("phone")) {
      return Icons.phone_android;
    }
    if (widget.labelText.toLowerCase().contains("email")) return Icons.email_outlined;
    return Icons.text_fields; // default
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      inputFormatters: [
        LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      decoration: InputDecoration(
        prefixIcon: Icon(
          _getPrefixIcon(),
          color: const Color(0xFF6A5AE0),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: widget.controller.text.isEmpty
                ? Colors.black54
                : const Color(0xFF6A5AE0),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
        hintText: widget.labelText,
        filled: true,
        fillColor: Colors.white.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      validator: widget.validator,
      onChanged: (_) {
        if (widget.isPassword) setState(() {}); // refresh eye icon color
      },
    );
  }
}