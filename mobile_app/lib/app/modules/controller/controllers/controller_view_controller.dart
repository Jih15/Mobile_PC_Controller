// lib/app/modules/controller/controllers/controller_view_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mobile_app/app/controllers/input/input_controller.dart';
import 'package:mobile_app/app/controllers/input/trigger_input.dart';
import 'package:mobile_app/app/controllers/connection_controller.dart';
import 'package:mobile_app/app/data/models/controller_mode.dart';

class ControllerViewController extends GetxController
    with GetSingleTickerProviderStateMixin {

  final input      = Get.find<InputController>();
  final trigger    = Get.find<TriggerInput>();
  final connection = Get.find<ConnectionController>();

  final showSettings = false.obs;

  // Nullable — aman diakses sebelum onInit selesai
  AnimationController? _settingsAnim;
  Animation<double>?   _scaleAnim;
  Animation<double>?   _opacityAnim;

  // Getter dengan fallback supaya FadeTransition/ScaleTransition
  // tidak crash kalau widget build sebelum onInit selesai
  Animation<double> get scaleAnim =>
      _scaleAnim ?? const AlwaysStoppedAnimation(1.0);

  Animation<double> get opacityAnim =>
      _opacityAnim ?? const AlwaysStoppedAnimation(0.0);

  Rx<ModeConfig> get mode => input.mode;

  @override
  void onInit() {
    super.onInit();

    _settingsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnim = CurvedAnimation(
      parent: _settingsAnim!,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInQuad,
    );

    _opacityAnim = CurvedAnimation(
      parent: _settingsAnim!,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  // ── Settings popup ────────────────────────────────────────────────────────

  void toggleSettings() =>
      showSettings.value ? _hideSettings() : _showSettings();

  void _showSettings() {
    showSettings.value = true;
    _settingsAnim?.forward(from: 0);
  }

  Future<void> _hideSettings() async {
    await _settingsAnim?.reverse();
    showSettings.value = false;
  }

  // ── Mode switching ────────────────────────────────────────────────────────

  void setMode(ControllerMode m) {
    switch (m) {
      case ControllerMode.standard:
        input.setMode(ModeConfig.standard);
        trigger.setMode(TriggerMode.digital);
        break;
      case ControllerMode.racing:
        input.setMode(ModeConfig.racing);
        trigger.setMode(TriggerMode.slider);
        break;
      case ControllerMode.fps:
        input.setMode(ModeConfig.fps);
        trigger.setMode(TriggerMode.digital);
        break;
    }
  }

  void toggleGyro(bool enabled) => input.toggleGyro(enabled);

  void setSensitivity(double v) => input.gyro.setSensitivity(v);

  @override
  void onClose() {
    _settingsAnim?.dispose();
    super.onClose();
  }
}