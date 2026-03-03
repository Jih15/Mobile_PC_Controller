// lib/app/modules/controller/views/layouts/racing_layout.dart
//
// Layout racing:
// - Gyro → left stick X (steering) — ditangani InputController, bukan di sini
// - VerticalSlider kiri  → LT (brake)
// - VerticalSlider kanan → RT (gas)
// - Joystick kanan → right stick (opsional kamera)
// - ABXY + LB/RB tetap ada

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:mobile_app/app/controllers/input/analog_input.dart';
import 'package:mobile_app/app/controllers/input/trigger_input.dart';
import 'package:mobile_app/app/controllers/input/gamepad_input.dart';
import 'package:mobile_app/app/modules/components/vertical_slider.dart';
import 'package:mobile_app/app/modules/components/controller_button.dart';

class RacingLayout extends StatelessWidget {
  const RacingLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final analog  = Get.find<AnalogInput>();
    final trigger = Get.find<TriggerInput>();
    final gamepad = Get.find<GamepadInput>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // ── LT Slider (Brake) ─────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('BRAKE', style: TextStyle(fontSize: 11, color: Colors.white54)),
              const Gap(8),
              VerticalSlider(
                onValueChanged: trigger.setSliderLt,
              ),
            ],
          ),

          const Spacer(),

          // ── CENTER — LB / START / BACK / RB ──────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                ControllerButton(label: 'LB', onPressed: (v) => gamepad.set('LB', v)),
                const Gap(8),
                ControllerButton(label: 'RB', onPressed: (v) => gamepad.set('RB', v)),
              ]),
              const Gap(16),
              Row(children: [
                ControllerButton(label: 'BACK',  onPressed: (v) => gamepad.set('BACK', v)),
                const Gap(8),
                ControllerButton(label: 'START', onPressed: (v) => gamepad.set('START', v)),
              ]),
              const Gap(16),
              // Right joystick (opsional, misal kamera / look-behind)
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
                  listener: (d) => analog.setRight(d.x, -d.y),
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── ABXY ─────────────────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

          const Spacer(),

          // ── RT Slider (Gas) ───────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('GAS', style: TextStyle(fontSize: 11, color: Colors.white54)),
              const Gap(8),
              VerticalSlider(
                onValueChanged: trigger.setSliderRt,
              ),
            ],
          ),
        ],
      ),
    );
  }
}