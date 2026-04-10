import 'package:flutter/material.dart';

class TextoFormatado extends StatelessWidget {
  final String texto;
  final TextAlign textAlign;
  final TextStyle style;
  final double? fontsize;
  final FontWeight? fontWeight;
  final Color? color;

  const TextoFormatado({
    super.key,
    required this.texto,
    this.textAlign = TextAlign.center,
    required this.style,
    this.fontsize,
    this.fontWeight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: textAlign,
      style: style.copyWith(
        fontSize: fontsize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}
