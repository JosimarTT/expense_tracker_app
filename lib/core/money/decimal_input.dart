int parseScaledDecimal(String input, int scale) {
  if (scale < 0 || scale > 4) {
    throw ArgumentError.value(scale, 'scale', 'Must be 0-4.');
  }
  final value = input.trim();
  final match = RegExp(r'^([0-9]+)(?:\.([0-9]+))?$').firstMatch(value);
  if (match == null || (match.group(2)?.length ?? 0) > scale) {
    throw FormatException('Use a positive number with at most $scale decimal places (dot separator).');
  }
  final whole = BigInt.parse(match.group(1)!);
  final fraction = (match.group(2) ?? '').padRight(scale, '0');
  final result = whole * BigInt.from(10).pow(scale) +
      (fraction.isEmpty ? BigInt.zero : BigInt.parse(fraction));
  if (result > BigInt.parse('9223372036854775807')) {
    throw const FormatException('The amount is too large.');
  }
  return result.toInt();
}
