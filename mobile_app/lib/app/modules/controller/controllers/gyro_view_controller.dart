import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/controllers/gyro_controller.dart';

class GyroViewController extends GetxController with GetSingleTickerProviderStateMixin{
  final gyro = Get.find<GyroController>();

  RxBool showSettings = false.obs;

  late AnimationController settingsAnim;
  late Animation<double> scaleAnim;
  late Animation<double> opacityAnim;

  @override
  void onInit() {
    super.onInit();

    settingsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    scaleAnim = CurvedAnimation(
      parent: settingsAnim,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInQuad
    );

    opacityAnim = CurvedAnimation(
      parent: settingsAnim, 
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn
    );
  }

  void toggleSettings(){
    if (showSettings.value){
      hideSettings();
    } else {
      showSettingsPopup();
    }
  }

  void showSettingsPopup(){
    showSettings.value = true;
    settingsAnim.forward(from: 0);
  }

  void hideSettings() async{
    await settingsAnim.reverse();
    showSettings.value = false;
  }
}