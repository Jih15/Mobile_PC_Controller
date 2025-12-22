import 'package:flutter/material.dart';
import 'package:mobile_app/app/modules/components/custom_slider_track_shape.dart';

class VerticalSlider extends StatelessWidget {
  final ValueChanged<bool>? onPressed;

  const VerticalSlider({super.key,this.onPressed});

  final double sliderWidth = 280;
  final double sliderHeight = 84;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: -1,
      child: SizedBox(
        width: sliderWidth,
        height: sliderHeight,
        child: VerticalSliderPainter(
          trackHeight: sliderHeight,
          onPressed: onPressed,
        ),
      ),
    );
  }
}

// Painter
class VerticalSliderPainter extends StatefulWidget {
  final double trackHeight;
  final ValueChanged<bool>? onPressed;

  const VerticalSliderPainter({
    super.key,
    this.trackHeight = 60,
    this.onPressed
  });

  @override
  State<VerticalSliderPainter> createState() => _VerticalSliderPainterState();
}

class _VerticalSliderPainterState extends State<VerticalSliderPainter> with SingleTickerProviderStateMixin {

  double sliderValue = 0;
  bool currentPressed = false;

  late AnimationController controller;
  late Animation<double> resetAnimation;

  static const double threshold = 0.2;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _updatePressedState(double val) {
    final pressed = val > threshold;

    if (pressed != currentPressed) {
      currentPressed = pressed;
      widget.onPressed?.call(pressed);
    }
  }

  void animateBackToZero() {
    resetAnimation = Tween<double>(begin: sliderValue, end: 0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    controller.forward(from: 0);

    resetAnimation.addListener(() {
      setState(() {
        sliderValue = resetAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: widget.trackHeight,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: SliderComponentShape.noThumb,
        trackShape: CustomSliderTrackShape(),
      ),
      child: Slider(
        min: 0,
        max: 1,
        value: sliderValue,
        onChanged: (val) {
          setState(() => sliderValue = val);
          _updatePressedState(val);
        },
        onChangeEnd: (val) {
          animateBackToZero();
        },
        inactiveColor: Colors.transparent,
      ),
    );
  }
}
