// lib/app/modules/components/controller_button.dart

import 'package:flutter/material.dart';

class ControllerButton extends StatefulWidget {
  const ControllerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.size = 40,
  });

  final String label;
  final ValueChanged<bool> onPressed; // true = press, false = release
  final Color? color;
  final double size;

  @override
  State<ControllerButton> createState() => _ControllerButtonState();
}

class _ControllerButtonState extends State<ControllerButton> {
  bool _pressed = false;

  void _down() {
    setState(() => _pressed = true);
    widget.onPressed(true);
  }

  void _up() {
    setState(() => _pressed = false);
    widget.onPressed(false);
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.color ?? const Color(0xff3a3d4a);

    return GestureDetector(
      onTapDown:   (_) => _down(),
      onTapUp:     (_) => _up(),
      onTapCancel: ()  => _up(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width:  widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _pressed ? base : base.withValues(alpha: 0.5),
          border: Border.all(
            color: _pressed ? Colors.white54 : Colors.white24,
            width: 1.5,
          ),
          boxShadow: _pressed
              ? [BoxShadow(color: base.withValues(alpha: 0.6), blurRadius: 8)]
              : [],
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: widget.size * 0.3,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}