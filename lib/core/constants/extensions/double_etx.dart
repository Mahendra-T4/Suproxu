String formatDoubleNumber(dynamic number) {
  if (number == null) return '0.00';
  if (number is int) return number.toStringAsFixed(2);
  if (number is double) return number.toStringAsFixed(2);
  try {
    return double.parse(number.toString()).toStringAsFixed(2);
  } catch (e) {
    return '0.00';
  }
}
