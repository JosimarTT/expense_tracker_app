import 'package:flutter/services.dart';

class AmountInputFormatter extends TextInputFormatter {
  AmountInputFormatter(int scale)
    : assert(scale >= 0 && scale <= 4),
      _pattern = RegExp(
        scale == 0 ? r'^[0-9]*$' : '^[0-9]*(\\.[0-9]{0,$scale})?\$',
      );

  final RegExp _pattern;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => _pattern.hasMatch(newValue.text) ? newValue : oldValue;
}
