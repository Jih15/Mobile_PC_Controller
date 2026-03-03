class GamepadEvent {
  final double lx; 
  final double ly; 
  final double rx; 
  final double ry; 
  final double lt; 
  final double rt; 
  final Map<String, bool> buttons;

  const GamepadEvent({
    this.lx = 0.0,
    this.ly = 0.0,
    this.rx = 0.0,
    this.ry = 0.0,
    this.lt = 0.0,
    this.rt = 0.0,
    this.buttons = const {},
  });

  Map<String, dynamic> toJson()=> {
    "type":    "Gamepad",
    "lx":      lx,
    "ly":      ly,
    "rx":      rx,
    "ry":      ry,
    "lt":      lt,
    "rt":      rt,
    "buttons": buttons,
  };
}