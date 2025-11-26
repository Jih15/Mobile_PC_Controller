import 'package:flutter/material.dart';
import 'package:mobile_app/app/modules/components/custom_slider_track_shape.dart';

class VerticalSlider extends StatelessWidget {
  const VerticalSlider({super.key});

  final double sliderWidth = 280;
  final double sliderHeight = 84;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: -1,
      child: SizedBox(
        width: sliderWidth,
        height: sliderHeight,
        child: VerticalSliderPainter(trackHeight: sliderHeight),
      ),
    );
  }
}

// Painter
class VerticalSliderPainter extends StatefulWidget {
  final double trackHeight;

  const VerticalSliderPainter({super.key, this.trackHeight = 60});

  @override
  State<VerticalSliderPainter> createState() => _VerticalSliderPainterState();
}

class _VerticalSliderPainterState extends State<VerticalSliderPainter>
    with SingleTickerProviderStateMixin {

  double sliderValue = 0;

  late AnimationController controller;
  late Animation<double> resetAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250), // smooth
    );
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
        value: sliderValue,
        onChanged: (newValue) {
          setState(() {
            sliderValue = newValue;
          });
        },
        onChangeEnd: (val) {
          animateBackToZero(); // ⬅ otomatis balik
        },
        inactiveColor: Colors.transparent,
      ),
    );
  }
}
