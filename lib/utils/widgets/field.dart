import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../resources/app_colors.dart';

class Field extends StatefulWidget {
  const Field({
    super.key,
    required this.text,
    required this.validateText,
    required this.obscureText,
    required this.readOnly,
    this.suffixIcon,
    this.prefixIcon,
    this.controller,
    this.onFieldSubmitted,
    this.onTap,
    this.onChanged,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.expands = false,
    this.validator,
    this.inputFormatters,
  });

  final Function(String)? onFieldSubmitted;
  final TextEditingController? controller;
  final String text;
  final String validateText;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLength;
  final int maxLines;
  final bool obscureText;
  final bool readOnly;
  final bool expands;

  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: TextFormField(
        onChanged: widget.onChanged,
        expands: widget.expands,
        maxLines: widget.expands ? null : widget.maxLines,
        minLines: null,
        obscureText: widget.obscureText,
        cursorHeight: 27,
        cursorColor: kMainColor,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        controller: widget.controller,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onFieldSubmitted: widget.onFieldSubmitted != null
            ? (val) => widget.onFieldSubmitted?.call(val)
            : null,
        inputFormatters: widget.inputFormatters,
        validator: widget.validator ??
            (text) {
              if (text == null || text.trim().isEmpty) {
                return widget.validateText;
              }
              return null;
            },
        style: const TextStyle(height: 1),
        decoration: InputDecoration(
          suffixIcon: widget.suffixIcon,
          prefixIcon: widget.prefixIcon,
          label: Text(widget.text),
        ),
      ),
    );
  }
}
