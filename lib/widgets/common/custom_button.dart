import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;
  final double height;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final Border? border;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isActive = true,
    this.height = 50,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isActive ? Colors.black : Colors.white),
          borderRadius: BorderRadius.circular(24),
          border: border ?? Border.all(color: Colors.black, width: 1),
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: textColor ??
                            (isActive ? Colors.white : Colors.black),
                        size: 20,
                      ),
                      if (text.isNotEmpty) const SizedBox(width: 4),
                    ],
                    if (text.isNotEmpty)
                      Flexible(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: textColor ??
                                (isActive ? Colors.white : Colors.black),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
