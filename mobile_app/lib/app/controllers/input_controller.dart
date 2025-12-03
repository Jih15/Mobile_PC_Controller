import 'package:get/get.dart';
import 'package:mobile_app/app/data/models/input_event.dart';
import 'package:mobile_app/app/services/websocket_service.dart';

class InputController extends GetxController {
  RxDouble triggerPressure = 0.0.obs;


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    WebSocketService.to.send(InputEvent.throttle(triggerPressure.value).toJson());
  }
  // Vertical Slider as Trigger Pressure
  void setTriggerPressure(double value) {
    triggerPressure.value = value;
  }

}
