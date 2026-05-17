import 'package:flutter/material.dart';
import 'package:suproxu/Assets/font_family.dart';

class GlobalText extends StatelessWidget {
  const GlobalText({
    super.key,
    this.fontWeight,
    this.fontSize,
    required this.text,
  });
  final FontWeight? fontWeight;
  final double? fontSize;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: FontFamily.globalFontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
