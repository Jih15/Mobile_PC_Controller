import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:mobile_app/app/data/models/controller_mode.dart';
import 'package:mobile_app/app/modules/components/custom_progress_line.dart';
import 'package:mobile_app/app/modules/controller/controllers/controller_view_controller.dart';
import 'package:mobile_app/app/modules/controller/views/layout/fps_layout.dart';
import 'package:mobile_app/app/modules/controller/views/layout/racing_layout.dart';
import 'package:mobile_app/app/modules/controller/views/layout/standart_layout.dart';

class ControllerView extends StatelessWidget {
  const ControllerView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ControllerViewController>();

    return Scaffold(
      body: SafeArea(
        left: false,
        right: false,
        child: Stack(
          children: [
            Column(
              children: [
                // StatusBar
                _StatusBar(ctrl: ctrl),

                Obx(() {
                  final gyroOn = ctrl.mode.value.gyroEnabled;
                  if (!gyroOn) return const SizedBox.shrink();
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 0, end: ctrl.input.gyro.tilt.value),
                    builder: (_, value, __) => GyroProgressLine(value: value),
                  );
                }),

                // Layout Per Mode
                Expanded(
                  child: Obx(() {
                    switch (ctrl.mode.value.mode) {
                      case ControllerMode.standard:
                        return const StandardLayout();
                      case ControllerMode.racing:
                        return const RacingLayout();
                      case ControllerMode.fps:
                        return const FpsLayout();
                    }
                  }),
                ),
              ],
            ),
            _SettingsOverlay(ctrl: ctrl),
          ],
        ),
      ),
    );
  }
}

// Status Bar - Conn - Mode - Settings

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.ctrl});
  final ControllerViewController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Conn
          Obx(() {
            final ok = ctrl.connection.isConnected.value;
            return Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: ok ? Colors.greenAccent : Colors.red,
                ),
                const Gap(6),
                Text(
                  ok ? 'Connected' : 'Disconnected',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }),
          const Spacer(),
          // Mode Selector
          Obx(
            () => _ModeSelector(
              current: ctrl.mode.value.mode,
              onSelected: ctrl.setMode,
            ),
          ),

          const Gap(12),

          GestureDetector(
            onTap: ctrl.toggleSettings,
            child: Icon(Icons.settings, size: 26),
          ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    super.key,
    required this.current,
    required this.onSelected,
  });

  final ControllerMode current;
  final ValueChanged<ControllerMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ControllerMode.values.map((m) {
        final active = m == current;
        final label = m.name[0].toUpperCase() + m.name.substring(1);
        return GestureDetector(
          onTap: () => onSelected(m),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white38),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? Colors.white : Colors.white70,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Settings Overlay

class _SettingsOverlay extends StatelessWidget {
  const _SettingsOverlay({required this.ctrl});
  final ControllerViewController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!ctrl.showSettings.value) return const SizedBox.shrink();

      return Stack(
        children: [
          // Backdrop
          FadeTransition(
            opacity: ctrl.opacityAnim,
            child: GestureDetector(
              onTap: ctrl.toggleSettings,
              child: Container(color: Colors.black54),
            ),
          ),

          // Panel
          Center(
            child: ScaleTransition(
              scale: ctrl.scaleAnim,
              child: FadeTransition(
                opacity: ctrl.opacityAnim,
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
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Settings',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          GestureDetector(
                              onTap: ctrl.toggleSettings,
                              child: const Icon(Icons.close)),
                        ],
                      ),

                      const Gap(20),

                      // Gyro toggle (hanya tampil di mode yang support gyro)
                      Obx(() {
                        final supportsGyro =
                            ctrl.mode.value.mode != ControllerMode.standard;
                        if (!supportsGyro) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Gyroscope'),
                                Switch(
                                  value: ctrl.mode.value.gyroEnabled,
                                  onChanged: ctrl.toggleGyro,
                                ),
                              ],
                            ),
                            if (ctrl.mode.value.gyroEnabled) ...[
                              const Gap(8),
                              Obx(() => Text(
                                    'Sensitivity: ${ctrl.input.gyro.sensitivity.value.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 13),
                                  )),
                              Obx(() => Slider(
                                    min: 0.2,
                                    max: 3.0,
                                    value: ctrl.input.gyro.sensitivity.value,
                                    onChanged: ctrl.setSensitivity,
                                  )),
                            ],
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
