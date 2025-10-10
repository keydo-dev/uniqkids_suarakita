import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniqkids_suarakita/controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final c = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Home Screen')));
  }
}
