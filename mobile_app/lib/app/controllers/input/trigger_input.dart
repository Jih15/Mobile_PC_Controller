// lib/app/controllers/input/trigger_input.dart
//
// Abstraksi trigger: bisa dari slider (racing) atau digital button (standard)
// InputController cukup baca .lt dan .rt — tidak perlu tahu sumbernya

import 'package:get/get.dart';

enum TriggerMode { digital, slider }

class TriggerInput extends GetxController {
  final triggerMode = TriggerMode.digital.obs;

  // Digital (RB = full RT, LB = full LT)
  final _rbPressed = false.obs;
  final _lbPressed = false.obs;

  // Slider (0.0 .. 1.0)
  final _sliderRt = 0.0.obs;
  final _sliderLt = 0.0.obs;

  // ── Setter ────────────────────────────────────────────────────────────────

  void setRB(bool v) => _rbPressed.value = v;
  void setLB(bool v) => _lbPressed.value = v;

  void setSliderRt(double v) => _sliderRt.value = v.clamp(0.0, 1.0);
  void setSliderLt(double v) => _sliderLt.value = v.clamp(0.0, 1.0);

  void setMode(TriggerMode m) => triggerMode.value = m;

  // ── Getter yang dipakai InputController ──────────────────────────────────

  double get rt => triggerMode.value == TriggerMode.slider
      ? _sliderRt.value
      : (_rbPressed.value ? 1.0 : 0.0);

  double get lt => triggerMode.value == TriggerMode.slider
      ? _sliderLt.value
      : (_lbPressed.value ? 1.0 : 0.0);
}