enum ControllerMode {standard, racing, fps}

enum GyroAxis {leftX, rightX, rightY}

class ModeConfig {
  final ControllerMode mode;
  final bool gyroEnabled;
  final List<GyroAxis> gyroAxes;

  const ModeConfig({
    required this.mode,
    required this.gyroEnabled,
    required this.gyroAxes
  });

  static const standard = ModeConfig(
    mode: ControllerMode.standard, 
    gyroEnabled: false, 
    gyroAxes: []
  );

  static const racing = ModeConfig(
    mode: ControllerMode.racing, 
    gyroEnabled: true, 
    gyroAxes: [GyroAxis.leftX]
  );

  static const fps = ModeConfig(
    mode: ControllerMode.fps, 
    gyroEnabled: true, 
    gyroAxes: [GyroAxis.rightX, GyroAxis.rightY]
  );

  ModeConfig copyWith({
    ControllerMode? mode,
    bool? gyroEnabled,
    List<GyroAxis>? gyroAxes,
  }) {
    return ModeConfig(
      mode: mode ?? this.mode, 
      gyroEnabled: gyroEnabled ?? this.gyroEnabled, 
      gyroAxes: gyroAxes ?? this.gyroAxes,
    );
  }
}