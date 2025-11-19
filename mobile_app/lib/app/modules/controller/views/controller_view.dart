import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/controller_controller.dart';

class ControllerView extends GetView<ControllerController> {
  const ControllerView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ControllerView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ControllerView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
