import 'package:flutter/material.dart';

InputDecoration appInputDecoration(
  BuildContext context,
  String label, {
  IconData? icon,
  Widget? suffix,
}) {
  final scheme = Theme.of(context).colorScheme;
  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    border: border(scheme.outlineVariant),
    enabledBorder: border(scheme.outlineVariant),
    focusedBorder: border(scheme.primary, 1.6),
  );
}