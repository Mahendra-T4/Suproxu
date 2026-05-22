import 'package:flutter/material.dart';
import 'package:suproxu/core/constants/widget/toast.dart';

class HelperService {
  static Future<void> pricingChecker({
    required dynamic lowerCKT,
    required dynamic upperCKT,
    required dynamic price,
    required Function() onSuccess,
    required BuildContext context,
  }) async {
    if (price < lowerCKT || price > upperCKT) {
      waringToast(
        context,
        'Price is out of circuit limits. Please enter price between lower and upper limits. ',
      );
    } else {
      onSuccess.call();
      print('Price is within the circuit limits.');
    }
  }
}
