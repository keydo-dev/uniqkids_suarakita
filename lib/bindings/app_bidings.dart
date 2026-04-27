import 'package:SuaraKita/controllers/shortcut_controller.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/controllers/card_controller.dart';
import 'package:SuaraKita/controllers/category_controller.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import 'package:SuaraKita/controllers/voice_controller.dart';
import 'package:SuaraKita/models/database.dart';
import 'package:SuaraKita/services/audio_services.dart';
import 'package:SuaraKita/services/tts_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put<AudioService>(AudioService(), permanent: true);
    Get.put<TtsService>(TtsService(), permanent: true);

    // Database
    Get.put<AppDatabase>(AppDatabase(), permanent: true);

    // Controllers
    Get.put<LanguagesController>(LanguagesController(), permanent: true);
    Get.put<VoiceController>(VoiceController(Get.find()), permanent: true);
    Get.put<CategoryController>(CategoryController(Get.find()), permanent: true);
    Get.put<CardController>(CardController(Get.find()), permanent: true);

    Get.put<ShortcutController>(ShortcutController(Get.find()), permanent: true);
  }
}
