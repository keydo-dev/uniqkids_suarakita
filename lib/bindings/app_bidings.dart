import 'package:get/get.dart';
import 'package:uniqkids_suarakita/controllers/card_controller.dart';
import 'package:uniqkids_suarakita/controllers/category_controller.dart';
import 'package:uniqkids_suarakita/controllers/languages_controller.dart';
import 'package:uniqkids_suarakita/models/database.dart';
import 'package:uniqkids_suarakita/services/audio_services.dart';

class AppBidings extends Bindings {
  @override
  void dependencies() {
  Get.put<AudioService>(AudioService(), permanent: true);

  Get.put<AppDatabase>(AppDatabase(), permanent: true);
  Get.put<LanguagesController>(LanguagesController(), permanent: true);
  Get.put<CategoryController>(CategoryController(Get.find<AppDatabase>()), permanent: true);
  Get.put<CardController>(CardController(Get.find<AppDatabase>()), permanent: true);
  }
}