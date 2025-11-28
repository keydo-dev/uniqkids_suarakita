import 'package:get/get.dart';
import 'package:SuaraKita/controllers/card_controller.dart';
import 'package:SuaraKita/controllers/category_controller.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import 'package:SuaraKita/models/database.dart';
import 'package:SuaraKita/services/audio_services.dart';

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
