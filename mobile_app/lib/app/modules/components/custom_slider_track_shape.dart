import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CustomSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    ui.Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required ui.TextDirection textDirection,
    required ui.Offset thumbCenter,
    ui.Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    double additionalActiveTrackHeight = 0,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);

    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final trackHeight = sliderTheme.trackHeight!;

    final ColorTween activeTrackColorTween =
        ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);

    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Paint leftTrackPaint;
    final Paint rightTrackPaint;

    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    activePaint.shader = ui.Gradient.linear(
      ui.Offset(trackRect.left, 0),
      ui.Offset(thumbCenter.dx, 0),
      [
        //first gradient color
        const ui.Color.fromARGB(255, 18, 54, 121),
        //second gradient color
        const ui.Color.fromARGB(255, 41, 163, 172),
      ],
    );

    final Radius trackRadius = Radius.circular(trackRect.height / 2);

    //slider background color
    final Paint shadow = Paint()..color = const Color(0xff252831);
    context.canvas.clipRRect(
      RRect.fromLTRBR(
          trackRect.left, trackRect.top, trackRect.right, trackRect.bottom, trackRadius),
    );

    // Solid shadow color - Top elevation
    context.canvas.drawRRect(
        RRect.fromLTRBR(
            trackRect.left, trackRect.top, trackRect.right, trackRect.bottom, trackRadius),
        shadow);

    // Bottom elevation
    shadow
      ..color = const Color(0xff252831)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        ui.Shadow.convertRadiusToSigma(10),
      );

    context.canvas.drawRRect(
        RRect.fromLTRBR(
          trackRect.left - trackHeight,
          trackRect.top + trackHeight / 2,
          trackRect.right - 0,
          trackRect.bottom + trackHeight / 2,
          trackRadius,
        ),
        shadow);

    // Shadow
    shadow
      ..color = const Color(0xff252831)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        ui.Shadow.convertRadiusToSigma(15),
      );

    context.canvas.drawRRect(
        RRect.fromLTRBR(
          trackRect.left - trackHeight,
          trackRect.top + trackHeight / 8,
          trackRect.right - trackHeight / 8,
          trackRect.bottom,
          trackRadius,
        ),
        shadow);

    // Active/Inactive tracks
    context.canvas.drawRRect(
      RRect.fromLTRBR(
        trackRect.left,
        (textDirection == TextDirection.ltr)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        thumbCenter.dx,
        (textDirection == TextDirection.ltr)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        trackRadius,
      ),
      leftTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBR(
        thumbCenter.dx,
        (textDirection == TextDirection.rtl)
            ? trackRect.top - (additionalActiveTrackHeight / 2)
            : trackRect.top,
        trackRect.right,
        (textDirection == TextDirection.rtl)
            ? trackRect.bottom + (additionalActiveTrackHeight / 2)
            : trackRect.bottom,
        trackRadius,
      ),
      rightTrackPaint,
    );
  }
}