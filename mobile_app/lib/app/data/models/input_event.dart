class InputEvent {
  final String type;
  final String action;
  final dynamic value;

  InputEvent({
    required this.type,
    required this.action,
    this.value
  });

  Map<String, dynamic> toJson() => {
    "type": type,
    "action": action,
    "value": value
  };
}