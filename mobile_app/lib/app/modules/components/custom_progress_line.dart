// import 'package:flutter/material.dart';

// class GyroProgressLine extends StatelessWidget {
//   final double value; 

//   const GyroProgressLine({super.key, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: _GyroProgressPainter(value),
//       size: const Size(double.infinity, 10),
//     );
//   }
// }

// class _GyroProgressPainter extends CustomPainter {
//   final double value;

//   _GyroProgressPainter(this.value);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final centerY = size.height / 2;
//     final centerX = size.width / 2;

//     final paintBase = Paint()
//       ..color = Colors.grey.withValues(alpha: 0.4)
//       ..strokeWidth = 16;

//     final paintProgress = Paint()
//       ..color = value >= 0 ? Colors.blue : Colors.red
//       ..strokeWidth = 16
//       ..strokeCap = StrokeCap.round;

//     // Garis dasar
//     canvas.drawLine(
//       Offset(0, centerY),
//       Offset(size.width, centerY),
//       paintBase,
//     );

//     // Hitung panjang progress
//     double progressLength = (size.width / 2) * value.abs();

//     if (value > 0) {
//       canvas.drawLine(
//         Offset(centerX, centerY),
//         Offset(centerX + progressLength, centerY),
//         paintProgress,
//       );
//     } else if (value < 0) {
//       canvas.drawLine(
//         Offset(centerX, centerY),
//         Offset(centerX - progressLength, centerY),
//         paintProgress,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _GyroProgressPainter oldDelegate) {
//     return oldDelegate.value != value;
//   }
// }


// import 'dart:math';
import 'package:flutter/material.dart';

class GyroProgressLine extends StatefulWidget {
  final double value; // raw tilt from controller

  const GyroProgressLine({super.key, required this.value});

  @override
  State<GyroProgressLine> createState() => _GyroProgressLineState();
}

class _GyroProgressLineState extends State<GyroProgressLine>
    with SingleTickerProviderStateMixin {
  late AnimationController colorAnim;
  late Animation<Color?> colorTween;

  double smoothedValue = 0.0;
  final double smoothingFactor = 0.15; 

  @override
  void initState() {
    super.initState();

    colorAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    colorTween = ColorTween(begin: Colors.blue, end: Colors.blue)
        .animate(CurvedAnimation(
      parent: colorAnim,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(GyroProgressLine oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Low-pass smoothing
    smoothedValue =
        (smoothedValue * (1 - smoothingFactor)) + (widget.value * smoothingFactor);

    // Update animated color
    if (smoothedValue >= 0) {
      colorTween = ColorTween(
        begin: colorTween.value,
        // end: Colors.blue.withOpacity(0.8 + (smoothedValue.abs() * 0.2)),
        end: Colors.blue.withValues(alpha: 0.8 + (smoothedValue.abs()* 0.2))
      ).animate(colorAnim);
    } else {
      colorTween = ColorTween(
        begin: colorTween.value,
        // end: Colors.red.withOpacity(0.8 + (smoothedValue.abs() * 0.2)),
        end: Colors.red.withValues(alpha: 0.8 + (smoothedValue.abs() * 0.2)),
      ).animate(colorAnim);
    }

    colorAnim.forward(from: 0);
    setState(() {});
  }

  @override
  void dispose() {
    colorAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: colorAnim,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, 18),
              painter: _GyroPainter(
                value: smoothedValue.clamp(-1.0, 1.0),
                color: colorTween.value ?? Colors.blue,
              ),
            );
          },
        );
      },
    );
  }
}

class _GyroPainter extends CustomPainter {
  final double value;
  final Color color;

  _GyroPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final centerX = size.width / 2;

    final basePaint = Paint()
      // ..color = Colors.grey.withOpacity(0.25)
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;

    // Draw base
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      basePaint,
    );

    double progress = (size.width / 2) * value.abs();

    // Glow effect (extreme steer)
    if (value.abs() > 0.8) {
      final glowPaint = Paint()
        // ..color = color.withOpacity(0.4)
        ..color = color.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
        ..strokeWidth = size.height + 10
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(
          centerX + (value > 0 ? progress : -progress),
          centerY,
        ),
        glowPaint,
      );
    }

    // Progress line
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX + (value > 0 ? progress : -progress), centerY),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GyroPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
