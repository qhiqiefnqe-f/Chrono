import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  factory CustomText.title({
    required String text,
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text: text,
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: color,
      textAlign: textAlign,
    );
  }

  factory CustomText.subtitle({
    required String text,
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text: text,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: color,
      textAlign: textAlign,
    );
  }

  factory CustomText.body({
    required String text,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CustomText(
      text: text,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: GoogleFonts.poppins().fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Colors.black,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
