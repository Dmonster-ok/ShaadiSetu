import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String? value) validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final Widget? suffixIcon;
  final void Function(String value)? onChanged;
  final String? hintText;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.suffixIcon,
    this.onChanged,
    this.hintText,
    this.floatingLabelBehavior,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        inputFormatters: [
          ...inputFormatters,
          LengthLimitingTextInputFormatter(maxLength),
        ],
        textCapitalization: textCapitalization,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: suffixIcon,
          hintText: hintText,
          floatingLabelBehavior: floatingLabelBehavior, 
        ),
      ),
    );
  }
}