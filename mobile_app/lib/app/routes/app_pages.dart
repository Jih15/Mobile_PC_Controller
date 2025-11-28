// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import '../modules/controller/bindings/controller_binding.dart';
import '../modules/controller/views/controller_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.CONTROLLER;

  static final routes = [
    GetPage(
      name: _Paths.CONTROLLER,
      page: () => const ControllerView(),
      binding: ControllerBinding(),
    ),
  ];
}
