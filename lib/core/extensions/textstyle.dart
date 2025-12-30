import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suproxu/core/constants/color.dart';

extension TextStyleX on Text {
  Text textStyleH1() {
    return Text(
      data ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 15,
        color: kGoldenBraunColor,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH11() {
    return Text(
      data ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 18,
        color: kWhiteColor,
        letterSpacing: 2,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH1Custom(Color? color) {
    return Text(
      data ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 15,
        color: color ?? kGoldenBraunColor,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH1C(Color color) {
    return Text(
      data ?? '',
      style: TextStyle(
        color: color,
        fontSize: 16.sp,
        // fontFamily: 'JetBrainsMono',
        fontWeight: FontWeight.bold,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH1CPL() {
    return Text(
      data ?? '',
      style: TextStyle(
        color: data!.contains('-') ? Colors.red : Colors.green,
        fontSize: 16,
        // fontFamily: 'JetBrainsMono',
        fontWeight: FontWeight.bold,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH4() {
    return Text(
      data ?? '',
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16.5,
        color: zBlack,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH1W() {
    return Text(
      data ?? '',
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16,
        color: Colors.white,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH2() {
    return Text(
      data ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: kGoldenBraunColor,
        fontSize: 12.sp,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH2C(Color color) {
    return Text(
      data ?? '',
      style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 12),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH2G() {
    return Text(
      data ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: kGoldenBraunColor,
        fontSize: 12.sp,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH2W() {
    return Text(
      data ?? '',
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: kWhiteColor,
        fontSize: 12,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH2R() {
    return Text(
      data ?? '',
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Colors.redAccent,
        fontSize: 12,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH2S() {
    return Text(
      data ?? '',
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: zBlack,
        fontSize: 12,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH3() {
    return Text(
      data ?? '',
      style: TextStyle(
        color: kGoldenBraunColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH3R() {
    return Text(
      data ?? '',
      style: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.w600,
        fontSize: 11.5,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH5() {
    return Text(
      data ?? '',
      style: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleH() {
    return Text(
      data ?? '',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        // fontFamily: 'JetBrainsMono',
        color: kGoldenBraunColor,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleHB() {
    return Text(
      data ?? '',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 19,
        color: Colors.black,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }

  Text textStyleHT() {
    return Text(
      data ?? '',
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        // fontFamily: 'JetBrainsMono',
        fontSize: 21,
        color: Colors.white,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }
}

// Usage:
// Text('Your text').textStyle()
