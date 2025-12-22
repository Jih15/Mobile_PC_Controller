import 'package:get/get.dart';

class RBLBInput extends GetxController {
  final rbPressed = false.obs;
  final lbPressed = false.obs;

  double get throttle => rbPressed.value ? 1.0 : 0.0;
  double get brake => lbPressed.value ? 1.0 : 0.0;

  void setRB(bool v) => rbPressed.value = v;
  void setLB(bool v) => lbPressed.value = v;
}
