// lib/app/modules/controller/views/layouts/standard_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:mobile_app/app/controllers/input/analog_input.dart';
import 'package:mobile_app/app/controllers/input/trigger_input.dart';
import 'package:mobile_app/app/controllers/input/gamepad_input.dart';
import 'package:mobile_app/app/modules/components/controller_button.dart';

class StandardLayout extends StatelessWidget {
  const StandardLayout({super.key});

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
              // LB / LT digital
              Row(children: [
                _DigitalTrigger(
                  label: 'LT',
                  onChanged: (v) => trigger.setLB(v),
                ),
                const Gap(8),
                _DigitalTrigger(
                  label: 'LB',
                  onChanged: (v) => trigger.setLB(v),
                ),
              ]),
              const Gap(16),

              // Left joystick
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

              const Gap(16),
              // D-pad placeholder
              _DpadPlaceholder(gamepad: gamepad),
            ],
          ),

          const Spacer(),

          // ── CENTER — START / BACK ────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ControllerButton(
                label: 'BACK',
                onPressed: (v) => gamepad.set('BACK', v),
              ),
              const Gap(12),
              ControllerButton(
                label: 'START',
                onPressed: (v) => gamepad.set('START', v),
              ),
            ],
          ),

          const Spacer(),

          // ── RIGHT SIDE ───────────────────────────────────────────────────
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // RB / RT digital
              Row(children: [
                _DigitalTrigger(
                  label: 'RB',
                  onChanged: (v) => trigger.setRB(v),
                ),
                const Gap(8),
                _DigitalTrigger(
                  label: 'RT',
                  onChanged: (v) => trigger.setRB(v),
                ),
              ]),
              const Gap(16),

              // Right joystick
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

              const Gap(16),
              // ABXY
              _AbxyPlaceholder(gamepad: gamepad),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _DigitalTrigger extends StatefulWidget {
  const _DigitalTrigger({required this.label, required this.onChanged});
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  State<_DigitalTrigger> createState() => _DigitalTriggerState();
}

class _DigitalTriggerState extends State<_DigitalTrigger> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { setState(() => _pressed = true);  widget.onChanged(true); },
      onTapUp:   (_) { setState(() => _pressed = false); widget.onChanged(false); },
      onTapCancel: () { setState(() => _pressed = false); widget.onChanged(false); },
      child: Container(
        width: 52,
        height: 32,
        decoration: BoxDecoration(
          color: _pressed ? Colors.white : const Color(0xff252831),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: _pressed ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _DpadPlaceholder extends StatelessWidget {
  const _DpadPlaceholder({required this.gamepad});
  final GamepadInput gamepad;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0,    left: 35, child: _DpadBtn('UP',    gamepad)),
          Positioned(bottom: 0, left: 35, child: _DpadBtn('DOWN',  gamepad)),
          Positioned(left: 0,   top: 35,  child: _DpadBtn('LEFT',  gamepad)),
          Positioned(right: 0,  top: 35,  child: _DpadBtn('RIGHT', gamepad)),
        ],
      ),
    );
  }
}

class _DpadBtn extends StatefulWidget {
  const _DpadBtn(this.key_, this.gamepad);
  final String key_;
  final GamepadInput gamepad;
  @override
  State<_DpadBtn> createState() => _DpadBtnState();
}

class _DpadBtnState extends State<_DpadBtn> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { setState(() => _p = true);  widget.gamepad.set(widget.key_, true); },
      onTapUp:   (_) { setState(() => _p = false); widget.gamepad.set(widget.key_, false); },
      onTapCancel: () { setState(() => _p = false); widget.gamepad.set(widget.key_, false); },
      child: Container(
        width: 30,
        height: 30,
        color: _p ? Colors.white38 : Colors.white12,
        child: const SizedBox.shrink(),
      ),
    );
  }
}

class _AbxyPlaceholder extends StatelessWidget {
  const _AbxyPlaceholder({required this.gamepad});
  final GamepadInput gamepad;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0,    left: 35, child: ControllerButton(label: 'Y', color: Colors.yellow,  onPressed: (v) => gamepad.set('Y', v))),
          Positioned(bottom: 0, left: 35, child: ControllerButton(label: 'A', color: Colors.green,   onPressed: (v) => gamepad.set('A', v))),
          Positioned(left: 0,   top: 35,  child: ControllerButton(label: 'X', color: Colors.blue,    onPressed: (v) => gamepad.set('X', v))),
          Positioned(right: 0,  top: 35,  child: ControllerButton(label: 'B', color: Colors.red,     onPressed: (v) => gamepad.set('B', v))),
        ],
      ),
    );
  }
}