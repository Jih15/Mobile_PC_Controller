import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:gap/gap.dart';
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
        child: Stack(
          children: [
            Column(
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

                // const Spacer(),
                Gap(32),

                // Kontrol utama
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const VerticalSlider(),
                          const Spacer(),

                          // Box kiri
                          Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey,
                                child: Center(
                                  child: Text('data'),
                                ),
                              ),
                              Gap(24),
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Center(
                                  child: Joystick(
                                    base: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xff252831),
                                        shape: BoxShape.circle
                                      ),
                                    ),
                                    listener: (details) {

                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Spacer(),

                          Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey,
                              ),
                              Gap(24),
                              Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey,
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Settings button
                          GestureDetector(
                            onTap: controller.toggleSettings,
                            child: const SizedBox(
                              width: 60,
                              height: 60,
                              child: Icon(Icons.settings, size: 32),
                            ),
                          ),

                          const Spacer(),

                          // Box kanan
                          Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey,
                              ),
                              Gap(24),
                              Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey,
                              ),
                            ],
                          ),

                          Spacer(),

                          Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey,
                              ),
                              Gap(24),
                              Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey,
                              ),
                            ],
                          ),

                          const Spacer(),
                          const VerticalSlider(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Obx(() {
              if (!controller.showSettings.value) return const SizedBox();

              return Stack(
                children: [
                  FadeTransition(
                    opacity: controller.opacityAnim,
                    child: GestureDetector(
                      onTap: controller.toggleSettings,
                      child: Container(
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  Center(
                    child: ScaleTransition(
                      scale: controller.scaleAnim,
                      child: FadeTransition(
                        opacity: controller.opacityAnim,
                        child: Container(
                          width: 330,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xff252831),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 25,
                                color: Colors.black26,
                                spreadRadius: -1,
                                offset: Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // HEADER
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Settings",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: controller.toggleSettings,
                                    child: const Icon(Icons.close),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Obx(() => Column(
                                children: [
                                  Text(
                                    "Sensitivity: ${controller.sensitivity.value.toStringAsFixed(2)}",
                                  ),
                                  Slider(
                                    min: 0.2,
                                    max: 3.0,
                                    value: controller.sensitivity.value,
                                    onChanged: controller.setSensitivity,
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
