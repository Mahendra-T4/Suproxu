 import 'package:intl/intl.dart';

double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value;
    }
  }


  String _formatNumber(dynamic number) {
    if (number == null) return 'N/A';
    return NumberFormat('#,##,##0.00').format(number);
  }

