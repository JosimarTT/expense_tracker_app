import 'package:intl/intl.dart';

String formatMoney(
  int minor,
  String currencyCode,
  int scale, {
  String? locale,
}) {
  if (scale < 0 || scale > 4) {
    throw ArgumentError.value(scale, 'scale', 'Must be 0-4.');
  }
  // intl has no es_PE number data; its Latin American data matches Peru.
  final requestedLocale = Intl.canonicalizedLocale(
    locale ?? Intl.getCurrentLocale(),
  );
  final numberLocale = requestedLocale == 'es_PE' ? 'es_419' : requestedLocale;
  var factor = 1;
  for (var index = 0; index < scale; index++) {
    factor *= 10;
  }
  final decimal = NumberFormat.decimalPattern(numberLocale);
  final whole = decimal.format(minor.abs() ~/ factor);
  final fraction = scale == 0
      ? ''
      : '${decimal.symbols.DECIMAL_SEP}'
            '${NumberFormat('0' * scale, numberLocale).format(minor.abs() % factor)}';
  final currency = NumberFormat.simpleCurrency(
    locale: numberLocale,
    name: currencyCode,
    decimalDigits: scale,
  );
  final placeholder = NumberFormat.decimalPatternDigits(
    locale: numberLocale,
    decimalDigits: scale,
  ).format(1);
  // Apply locale currency affixes without passing the full amount through double.
  return currency
      .format(minor < 0 ? -1 : 1)
      .replaceFirst(placeholder, '$whole$fraction');
}
