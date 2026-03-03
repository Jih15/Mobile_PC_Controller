// lib/app/modules/controller/views/layouts/fps_layout.dart
//
// Layout FPS:
// - Left joystick  → movement (lx, ly)
// - Right joystick → tambahan kamera (rx, ry) — digabung dengan gyro di InputController
// - Gyro           → rx + ry aim assist (ditangani InputController)
// - LT/LB digital (aim / crouch)
// - RT/RB digital (shoot / sprint)
// - ABXY (jump, reload, dll)

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:mobile_app/app/controllers/input/analog_input.dart';
import 'package:mobile_app/app/controllers/input/trigger_input.dart';
import 'package:mobile_app/app/controllers/input/gamepad_input.dart';
import 'package:mobile_app/app/modules/components/controller_button.dart';

class FpsLayout extends StatelessWidget {
  const FpsLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final analog  = Get.find<AnalogInput>();
    final trigger = Get.find<TriggerInput>();
    final gamepad = Get.find<GamepadInput>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // ── LEFT SIDE ────────────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                ControllerButton(label: 'LT', onPressed: (v) => trigger.setLB(v)),
                const Gap(8),
                ControllerButton(label: 'LB', onPressed: (v) => trigger.setLB(v)),
              ]),
              const Gap(16),
              SizedBox(
                width: 130,
                height: 130,
                child: Joystick(
                  base: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff252831),
                      shape: BoxShape.circle,
                    ),
                  ),
                  listener: (d) => analog.setLeft(d.x, -d.y),
                ),
              ),
              const Gap(12),
              Row(children: [
                ControllerButton(label: 'BACK',  onPressed: (v) => gamepad.set('BACK', v)),
                const Gap(8),
                ControllerButton(label: 'START', onPressed: (v) => gamepad.set('START', v)),
              ]),
            ],
          ),

          const Spacer(),

          // ── RIGHT SIDE ───────────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                ControllerButton(label: 'RT', onPressed: (v) => trigger.setRB(v)),
                const Gap(8),
                ControllerButton(label: 'RB', onPressed: (v) => trigger.setRB(v)),
              ]),
              const Gap(16),
              SizedBox(
                width: 130,
                height: 130,
                child: Joystick(
                  base: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff252831),
                      shape: BoxShape.circle,
                    ),
                  ),
                  listener: (d) => analog.setRight(d.x, -d.y),
                ),
              ),
              const Gap(12),
              // ABXY
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(top: 0, left: 35,    child: ControllerButton(label: 'Y', color: Colors.yellow, onPressed: (v) => gamepad.set('Y', v))),
                    Positioned(bottom: 0, left: 35, child: ControllerButton(label: 'A', color: Colors.green,  onPressed: (v) => gamepad.set('A', v))),
                    Positioned(left: 0, top: 35,    child: ControllerButton(label: 'X', color: Colors.blue,   onPressed: (v) => gamepad.set('X', v))),
                    Positioned(right: 0, top: 35,   child: ControllerButton(label: 'B', color: Colors.red,    onPressed: (v) => gamepad.set('B', v))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}