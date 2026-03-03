// lib/app/modules/components/vertical_slider.dart
//
// Perubahan dari versi lama:
// - onValueChanged(double) — kirim nilai 0..1 langsung ke TriggerInput
//   (bukan lagi onPressed(bool) dengan threshold)
// - Animasi reset ke 0 saat dilepas tetap ada

import 'package:flutter/material.dart';
import 'custom_slider_track_shape.dart';

class VerticalSlider extends StatelessWidget {
  const VerticalSlider({
    super.key,
    this.onValueChanged,
    this.width = 280,
    this.height = 84,
  });

  /// Dipanggil setiap perubahan nilai (0.0 .. 1.0)
  final ValueChanged<double>? onValueChanged;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: -1,
      child: SizedBox(
        width: width,
        height: height,
        child: _SliderBody(
          trackHeight: height,
          onValueChanged: onValueChanged,
        ),
      ),
    );
  }
}

class _SliderBody extends StatefulWidget {
  const _SliderBody({this.trackHeight = 60, this.onValueChanged});
  final double trackHeight;
  final ValueChanged<double>? onValueChanged;

  @override
  State<_SliderBody> createState() => _SliderBodyState();
}

class _SliderBodyState extends State<_SliderBody>
    with SingleTickerProviderStateMixin {

  double _value = 0.0;
  late AnimationController _anim;
  late Animation<double> _resetAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _animateToZero() {
    _resetAnim = Tween<double>(begin: _value, end: 0.0)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

    _anim.forward(from: 0);
    _resetAnim.addListener(() {
      setState(() => _value = _resetAnim.value);
      widget.onValueChanged?.call(_resetAnim.value);
    });
  }

  @override
  void dispose() {
    _anim.dispose();
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
        value: _value,
        onChanged: (v) {
          setState(() => _value = v);
          widget.onValueChanged?.call(v);
        },
        onChangeEnd: (_) => _animateToZero(),
        inactiveColor: Colors.transparent,
      ),
    );
  }
}