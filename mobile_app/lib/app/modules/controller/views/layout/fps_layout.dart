import 'package:flutter/widget_previews.dart';
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(children: [
                Padding(
                  padding: EdgeInsets.only(top: 72),
                  child: ControllerButton(label: 'LT', onPressed: (v) => trigger.setLB(v), size: 72,),
                ),
                const Gap(24),
                ControllerButton(label: 'LB', onPressed: (v) => trigger.setLB(v), size: 72,),
              ]),
              // const Gap(16),
              Spacer(),
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
              const Gap(154),
            ],
          ),

          const Spacer(),
          Row(children: [
            ControllerButton(label: 'BACK',  onPressed: (v) => gamepad.set('BACK', v)),
            const Gap(8),
            ControllerButton(label: 'START', onPressed: (v) => gamepad.set('START', v)),
          ]),
          const Spacer(),
          // ── RIGHT SIDE ───────────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(children: [
                ControllerButton(label: 'RT', onPressed: (v) => trigger.setRB(v), size: 72,),
                const Gap(16),
                Padding(
                  padding: const EdgeInsets.only(top: 72),
                  child: ControllerButton(label: 'RB', onPressed: (v) => trigger.setRB(v), size: 72,),
                ),
              ]),
              // const Gap(120),
              Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ControllerButton(label: 'Y', color: Colors.yellow, onPressed: (v) => gamepad.set('Y', v), size: 48,),
                  const Gap(4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ControllerButton(label: 'X', color: Colors.blue,  onPressed: (v) => gamepad.set('X', v), size: 48),
                      const Gap(48),
                      ControllerButton(label: 'B', color: Colors.red,   onPressed: (v) => gamepad.set('B', v), size: 48),
                    ],
                  ),
                  const Gap(4),
                  ControllerButton(label: 'A', color: Colors.green, onPressed: (v) => gamepad.set('A', v), size: 48),
                ],
              ),
              const Gap(24),
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
              Gap(72),
            ],
          ),
        ],
      ),
    );
  }
}

// void _setupDepedencies(){
//   if (!Get.isRegistered<AnalogInput>()) Get.put(AnalogInput());
//   if (!Get.isRegistered<TriggerInput>()) Get.put(TriggerInput());
//   if (!Get.isRegistered<GamepadInput>()) Get.put(GamepadInput());
// }

// @Preview(name: 'FPS Layout', size: Size(1024, 600))
// Widget fpsLayout(){
//   _setupDepedencies();
//   return GetMaterialApp(
//     home: Scaffold(
//       backgroundColor: Color(0xff1a1c22),
//       body: FpsLayout(),
//     ),
//   );
// }