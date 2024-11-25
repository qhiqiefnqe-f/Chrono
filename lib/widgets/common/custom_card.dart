import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.borderRadius = 22,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 15),
        padding: padding ?? const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
        ),
        child: child,
      ),
    );
  }
}
