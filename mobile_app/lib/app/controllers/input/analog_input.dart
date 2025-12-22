import 'package:get/get.dart';

class AnalogInput extends GetxController {
  final leftX = 0.0.obs;
  final leftY = 0.0.obs;
  final rightX = 0.0.obs;
  final rightY = 0.0.obs;

  void setLeft(double x, double y) {
    leftX.value = x.clamp(-1.0, 1.0);
    leftY.value = y.clamp(-1.0, 1.0);
  }

  void setRight(double x, double y) {
    rightX.value = x.clamp(-1.0, 1.0);
    rightY.value = y.clamp(-1.0, 1.0);
  }
}
