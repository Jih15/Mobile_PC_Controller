enum InputType { Button, Gyro, Joystick, Throttle, Brake }

class InputEvent {
  final InputType type;

  // button
  final String? key;
  final bool? pressed;

  // gyro / trigger
  final double? value;

  // joystick
  final String? stick; // "left" or "right"
  final double? x;
  final double? y;

  InputEvent._({
    required this.type,
    this.key,
    this.pressed,
    this.value,
    this.stick,
    this.x,
    this.y,
  });

  // factories
  factory InputEvent.button(String key, bool pressed) =>
      InputEvent._(type: InputType.Button, key: key, pressed: pressed);

  factory InputEvent.gyro(double value) =>
      InputEvent._(type: InputType.Gyro, value: value);

  factory InputEvent.throttle(double value) =>
      InputEvent._(type: InputType.Throttle, value: value);

  factory InputEvent.brake(double value) =>
      InputEvent._(type: InputType.Brake, value: value);

  factory InputEvent.joystick(String stick, double x, double y) =>
      InputEvent._(type: InputType.Joystick, stick: stick, x: x, y: y);

  Map<String, dynamic> toJson() {
    switch (type) {
      case InputType.Button:
        return {
          "type": "Button",
          "key": key,
          "pressed": pressed,
        };
      case InputType.Gyro:
        return {
          "type": "Gyro",
          "value": value,
        };
      case InputType.Throttle:
        return {
          "type": "Throttle",
          "value": value,
        };
      case InputType.Brake:
        return {
          "type": "Brake",
          "value": value,
        };
      case InputType.Joystick:
        return {
          "type": "Joystick",
          "stick": stick, // "left" or "right"
          "x": x,
          "y": y,
        };
    }
  }
}
