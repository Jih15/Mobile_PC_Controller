import 'package:flutter/widget_previews.dart';
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
    final analog = Get.find<AnalogInput>();
    final trigger = Get.find<TriggerInput>();
    final gamepad = Get.find<GamepadInput>();

    return LayoutBuilder(
      builder: (context, constraints) {
        // scale faktor: 1.0 di lebar 1024, min 0.6 di layar kecil
        final scale = (constraints.maxWidth / 1024).clamp(0.6, 1.2);

        final joystickSize = 144.0 * scale;
        final abxySize = 48.0 * scale;
        final abxyGap = 32.0 * scale;
        final lbRbSize = 72.0 * scale;
        final backStartSize = 56.0 * scale;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 12 * scale,
          ),
          child: Row(
            children: [
              // ── LT Slider (Brake) ───────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Gap(16 * scale),
                  Text(
                    'LT',
                    style: TextStyle(
                      fontSize: 11 * scale,
                      color: Colors.white54,
                    ),
                  ),
                  Gap(8 * scale),
                  VerticalSlider(onValueChanged: trigger.setSliderLt),
                ],
              ),
              Gap(16 * scale),
              ControllerButton(
                label: 'LB',
                onPressed: (v) => gamepad.set('LB', v),
                size: lbRbSize,
              ),

              const Spacer(),

              // ── CENTER — Joystick ───────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: joystickSize,
                    height: joystickSize,
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

              // ── BACK / START ────────────────────────────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ControllerButton(
                    label: 'BACK',
                    onPressed: (v) => gamepad.set('BACK', v),
                    size: backStartSize,
                  ),
                  Gap(16 * scale),
                  ControllerButton(
                    label: 'START',
                    onPressed: (v) => gamepad.set('START', v),
                    size: backStartSize,
                  ),
                ],
              ),

              const Spacer(),

              // ── ABXY ────────────────────────────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ControllerButton(
                    label: 'Y',
                    color: Colors.yellow,
                    onPressed: (v) => gamepad.set('Y', v),
                    size: abxySize,
                  ),
                  Gap(4 * scale),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ControllerButton(
                        label: 'X',
                        color: Colors.blue,
                        onPressed: (v) => gamepad.set('X', v),
                        size: abxySize,
                      ),
                      Gap(abxyGap),
                      ControllerButton(
                        label: 'B',
                        color: Colors.red,
                        onPressed: (v) => gamepad.set('B', v),
                        size: abxySize,
                      ),
                    ],
                  ),
                  Gap(4 * scale),
                  ControllerButton(
                    label: 'A',
                    color: Colors.green,
                    onPressed: (v) => gamepad.set('A', v),
                    size: abxySize,
                  ),
                ],
              ),

              const Spacer(),

              // ── RT Slider (Gas) ─────────────────────────────────────────
              ControllerButton(
                label: 'RB',
                onPressed: (v) => gamepad.set('RB', v),
                size: lbRbSize,
              ),
              Gap(16 * scale),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Gap(16 * scale),
                  Text(
                    'RT',
                    style: TextStyle(
                      fontSize: 11 * scale,
                      color: Colors.white54,
                    ),
                  ),
                  Gap(8 * scale),
                  VerticalSlider(onValueChanged: trigger.setSliderRt),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Preview ───────────────────────────────────────────────────────────────────

void _setupDependencies() {
  if (!Get.isRegistered<AnalogInput>()) Get.put(AnalogInput());
  if (!Get.isRegistered<TriggerInput>()) Get.put(TriggerInput());
  if (!Get.isRegistered<GamepadInput>()) Get.put(GamepadInput());
}

@Preview(name: 'Phone Landscape', size: Size(800, 400))
@Preview(name: 'Tablet Landscape', size: Size(1024, 600))
Widget racingLayoutPreview() {
  _setupDependencies();
  return GetMaterialApp(
    home: Scaffold(backgroundColor: Color(0xff1a1c22), body: RacingLayout()),
  );
}
