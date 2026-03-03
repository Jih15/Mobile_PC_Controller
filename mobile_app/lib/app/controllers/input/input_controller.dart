// lib/app/controllers/input/input_controller.dart
//
// INI JANTUNG SISTEM:
// - Baca semua sumber input (gyro, analog stick, slider, button)
// - Tergantung mode, mapping ke axis yang tepat
// - Kirim GamepadEvent ke Rust setiap 16ms (~60Hz)

import 'dart:async';
import 'package:get/get.dart';

import 'package:mobile_app/app/controllers/input/gyro_input.dart';
import 'package:mobile_app/app/controllers/input/analog_input.dart';
import 'package:mobile_app/app/controllers/input/trigger_input.dart';
import 'package:mobile_app/app/controllers/input/gamepad_input.dart';
import 'package:mobile_app/app/data/models/controller_mode.dart';
import 'package:mobile_app/app/data/models/input_event.dart';
import 'package:mobile_app/app/services/websocket_service.dart';

class InputController extends GetxController {
  final gyro    = Get.find<GyroInput>();
  final analog  = Get.find<AnalogInput>();
  final trigger = Get.find<TriggerInput>();
  final gamepad = Get.find<GamepadInput>();

  // Mode aktif — observable supaya UI bisa reaktif
  final mode = Rx<ModeConfig>(ModeConfig.standard);

  Timer? _sendLoop;
  static const _tick = Duration(milliseconds: 16); // ~60Hz

  @override
  void onInit() {
    super.onInit();
    _sendLoop = Timer.periodic(_tick, (_) => _send());
  }

  // ── Public API ────────────────────────────────────────────────────────────

  void setMode(ModeConfig newMode) {
    mode.value = newMode;
    // Reset gyro saat mode berubah supaya tidak ada spike
    gyro.reset();
  }

  void toggleGyro(bool enabled) {
    mode.value = mode.value.copyWith(gyroEnabled: enabled);
    if (!enabled) gyro.reset();
  }

  // ── Mapping + Send ────────────────────────────────────────────────────────

  void _send() {
    final cfg = mode.value;

    // Nilai default dari analog stick
    double lx = analog.leftX.value;
    double ly = analog.leftY.value;
    double rx = analog.rightX.value;
    double ry = analog.rightY.value;

    // Trigger default dari TriggerInput (slider atau digital RB/LB)
    double lt = trigger.lt;
    double rt = trigger.rt;

    // Apply gyro berdasarkan axis yang di-config
    if (cfg.gyroEnabled) {
      final tilt = gyro.tilt.value;

      for (final axis in cfg.gyroAxes) {
        switch (axis) {
          case GyroAxis.leftX:
            lx = tilt; // override left stick X (racing: steering)
            break;
          case GyroAxis.rightX:
            rx = (rx + tilt).clamp(-1.0, 1.0); // FPS: tambah ke kamera
            break;
          case GyroAxis.rightY:
            ry = (ry + gyro.tiltY.value).clamp(-1.0, 1.0); // FPS: vertical aim
            break;
        }
      }
    }

    final event = GamepadEvent(
      lx: lx,
      ly: ly,
      rx: rx,
      ry: ry,
      lt: lt,
      rt: rt,
      buttons: Map<String, bool>.from(gamepad.buttons),
    );

    WebSocketService.to.send(event.toJson());
  }

  @override
  void onClose() {
    _sendLoop?.cancel();
    super.onClose();
  }
}