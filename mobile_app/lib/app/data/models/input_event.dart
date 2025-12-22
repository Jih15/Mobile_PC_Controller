enum InputType {
  button,
  gyro,
  joystick,
  throttle,
  brake,
  combined,
}

class InputEvent {
  final InputType type;

  // ===== BUTTON =====
  final String? key;
  final bool? pressed;

  // ===== GYRO / TRIGGER =====
  final double? value;

  // ===== JOYSTICK =====
  final String? stick; // "left" | "right"
  final double? x;
  final double? y;

  // ===== COMBINED =====
  final double? steering; // gyro
  final double? throttle;
  final double? brake;
  final Map<String, bool>? buttons;
  final Map<String, Map<String, double>>? sticks;

  const InputEvent._({
    required this.type,
    this.key,
    this.pressed,
    this.value,
    this.stick,
    this.x,
    this.y,
    this.steering,
    this.throttle,
    this.brake,
    this.buttons,
    this.sticks,
  });

  // ================== FACTORIES ==================

  factory InputEvent.button(String key, bool pressed) =>
      InputEvent._(
        type: InputType.button,
        key: key,
        pressed: pressed,
      );

  factory InputEvent.gyro(double value) =>
      InputEvent._(
        type: InputType.gyro,
        value: value,
      );

  factory InputEvent.throttle(double value) =>
      InputEvent._(
        type: InputType.throttle,
        value: value,
      );

  factory InputEvent.brake(double value) =>
      InputEvent._(
        type: InputType.brake,
        value: value,
      );

  factory InputEvent.joystick(
      String stick,
      double x,
      double y,
      ) =>
      InputEvent._(
        type: InputType.joystick,
        stick: stick,
        x: x,
        y: y,
      );

  /// ⭐ FINAL SNAPSHOT (INI YANG DIPAKAI SAAT RUNTIME)
  factory InputEvent.combined({
    required double steering,
    required double throttle,
    required double brake,
    required Map<String, bool> buttons,
    required Map<String, Map<String, double>> sticks,
  }) =>
      InputEvent._(
        type: InputType.combined,
        steering: steering,
        throttle: throttle,
        brake: brake,
        buttons: buttons,
        sticks: sticks,
      );

  // ================== SERIALIZER ==================

  Map<String, dynamic> toJson() {
    switch (type) {
      case InputType.button:
        return {
          "type": "Button",
          "key": key,
          "pressed": pressed,
        };

      case InputType.gyro:
        return {
          "type": "Gyro",
          "value": value,
        };

      case InputType.throttle:
        return {
          "type": "Throttle",
          "value": value,
        };

      case InputType.brake:
        return {
          "type": "Brake",
          "value": value,
        };

      case InputType.joystick:
        return {
          "type": "Joystick",
          "stick": stick,
          "x": x,
          "y": y,
        };

      case InputType.combined:
        return {
          "type": "Combined",
          "steering": steering,
          "throttle": throttle,
          "brake": brake,
          "buttons": buttons,
          "sticks": sticks,
        };
    }
  }
}
