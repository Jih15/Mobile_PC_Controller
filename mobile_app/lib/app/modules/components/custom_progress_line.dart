import 'package:flutter/material.dart';

class GyroProgressLine extends StatelessWidget {
  final double value; 

  const GyroProgressLine({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GyroProgressPainter(value),
      size: const Size(double.infinity, 10),
    );
  }
}

class _GyroProgressPainter extends CustomPainter {
  final double value;

  _GyroProgressPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final centerX = size.width / 2;

    final paintBase = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 16;

    final paintProgress = Paint()
      ..color = value >= 0 ? Colors.blue : Colors.red
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    // Garis dasar
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paintBase,
    );

    // Hitung panjang progress
    double progressLength = (size.width / 2) * value.abs();

    if (value > 0) {
      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(centerX + progressLength, centerY),
        paintProgress,
      );
    } else if (value < 0) {
      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(centerX - progressLength, centerY),
        paintProgress,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GyroProgressPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
