import 'package:flutter/material.dart';

class CustomButtonEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isBlack;

  const CustomButtonEffect({
    super.key,
    required this.child,
    required this.onTap,
    this.isBlack = true,
  });

  @override
  State<CustomButtonEffect> createState() => _CustomButtonEffectState();
}

class _CustomButtonEffectState extends State<CustomButtonEffect> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isPressed ? 0.7 : 1.0,
        child: AnimatedScale(
          scale: _isPressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: widget.child,
        ),
      ),
    );
  }
}
