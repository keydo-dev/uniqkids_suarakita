import 'package:get/get.dart';
import 'package:uniqkids_suarakita/controllers/card_controller.dart';
import 'package:uniqkids_suarakita/controllers/category_controller.dart';
import 'package:uniqkids_suarakita/controllers/languages_controller.dart';
import 'package:uniqkids_suarakita/models/database.dart';
import 'package:uniqkids_suarakita/services/audio_services.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Audio service permanen
    Get.put<AudioService>(AudioService(), permanent: true);

    // Database
    Get.put<AppDatabase>(AppDatabase(), permanent: true);

    // Controllers
    Get.put<LanguagesController>(LanguagesController(), permanent: true);
    Get.put<CategoryController>(CategoryController(Get.find()), permanent: true);
    Get.put<CardController>(CardController(Get.find()), permanent: true);
  }
}
