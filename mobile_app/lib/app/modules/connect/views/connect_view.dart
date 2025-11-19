import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/connect_controller.dart';

class ConnectView extends GetView<ConnectController> {
  const ConnectView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ConnectView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ConnectView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
