import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/modules/components/custom_progress_line.dart';
import 'package:mobile_app/app/modules/components/vertical_slider.dart';
import '../controllers/gyro_view_controller.dart';

class ControllerView extends StatefulWidget {
  const ControllerView({super.key});

  @override
  State<ControllerView> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<ControllerView> {
  final controller = Get.find<GyroViewController>();

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
                // === PROGRESS LINE (GYRO STEERING) ===
                Obx(() {
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOutCubic,
                    tween: Tween(
                      begin: 0,
                      end: controller.gyro.tilt.value,
                    ),
                    builder: (context, value, _) {
                      return GyroProgressLine(value: value);
                    },
                  );
                }),

                const Gap(32),

                // ===== MAIN CONTROLLER UI =====
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const VerticalSlider(),
                          const Spacer(),

                          // LEFT PANELS (dummy)
                          Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey,
                                child: const Center(child: Text("data nih")),
                              ),
                              const Gap(24),
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Joystick(
                                  base: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xff252831),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  listener: (details) {},
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          Column(
                            children: [
                              Container(width: 120, height: 120, color: Colors.grey),
                              const Gap(24),
                              Container(width: 120, height: 120, color: Colors.grey),
                            ],
                          ),

                          const Spacer(),

                          // SETTINGS BUTTON
                          GestureDetector(
                            onTap: controller.toggleSettings,
                            child: const SizedBox(
                              width: 60,
                              height: 60,
                              child: Icon(Icons.settings, size: 32),
                            ),
                          ),

                          const Spacer(),

                          Column(
                            children: [
                              Container(width: 120, height: 120, color: Colors.grey),
                              const Gap(24),
                              Container(width: 120, height: 120, color: Colors.grey),
                            ],
                          ),

                          const Spacer(),

                          Column(
                            children: [
                              Container(width: 120, height: 120, color: Colors.grey),
                              const Gap(24),
                              Container(width: 120, height: 120, color: Colors.grey),
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

            // ===== SETTINGS POPUP =====
            Obx(() {
              if (!controller.showSettings.value) return const SizedBox();

              return Stack(
                children: [
                  FadeTransition(
                    opacity: controller.opacityAnim,
                    child: GestureDetector(
                      onTap: controller.toggleSettings,
                      child: Container(color: Colors.black54),
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
                            color: const Color(0xff252831),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 25,
                                color: Colors.black26,
                                spreadRadius: -1,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // HEADER
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Settings",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  GestureDetector(
                                      onTap: controller.toggleSettings,
                                      child: const Icon(Icons.close)),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // SENSITIVITY SLIDER
                              Obx(() => Column(
                                    children: [
                                      Text(
                                        "Sensitivity: ${controller.gyro.sensitivity.value.toStringAsFixed(2)}",
                                      ),
                                      Slider(
                                        min: 0.2,
                                        max: 3.0,
                                        value: controller.gyro.sensitivity.value,
                                        onChanged: controller.gyro.setSensitivity,
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
