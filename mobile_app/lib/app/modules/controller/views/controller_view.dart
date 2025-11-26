import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mobile_app/app/modules/components/custom_progress_line.dart';
import 'package:mobile_app/app/modules/components/vertical_slider.dart';

import '../controllers/gyro_controller.dart';

class ControllerView extends GetView<GyroController> {

  const ControllerView({super.key});

  double _normalize(double raw, double sensitivity) {
    double adjusted = raw * sensitivity;
    return (adjusted / 10).clamp(-1.0, 1.0);
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        left: false,
        right: false,
        child: Column(
          children: [
            // Progress line
            Obx(() {
              double targetValue = _normalize(
                controller.accelY.value,
                controller.sensitivity.value,
              );
              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0, end: targetValue),
                builder: (context, value, child) {
                  return GyroProgressLine(value: value);
                },
              );
            }),
        
            // Kontrol Sensitivity
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sensitivity: ${controller.sensitivity.value.toStringAsFixed(2)}'),
                  Slider(
                    min: 0.2,
                    max: 3.0,
                    value: controller.sensitivity.value,
                    onChanged: controller.setSensitivity,
                  ),
                  Row(
                    children: [
                      VerticalSlider(),
                      Spacer(),
                      VerticalSlider()
                    ],
                  )
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}