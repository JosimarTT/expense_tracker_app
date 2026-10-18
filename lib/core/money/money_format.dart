import 'package:intl/intl.dart';

String formatMoney(int minor, String currencyCode, int scale) {
  var factor = 1;
  for (var index = 0; index < scale; index++) {
    factor *= 10;
  }
  final whole = NumberFormat.decimalPattern().format(minor.abs() ~/ factor);
  final fraction = scale == 0
      ? ''
      : '${NumberFormat.decimalPattern().symbols.DECIMAL_SEP}'
          '${(minor.abs() % factor).toString().padLeft(scale, '0')}';
  return '${minor < 0 ? '-' : ''}$currencyCode $whole$fraction';
}
