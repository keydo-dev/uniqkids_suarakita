import 'dart:ui';
import 'package:get/get.dart';

class LanguagesController extends GetxController {
  var currentLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    final deviceLocale = Get.deviceLocale?.languageCode ?? 'en';
    currentLanguage.value = deviceLocale == 'id' ? 'id' : 'en';
    updateLocale();
  }

  void toggleLanguage() {
    currentLanguage.value = currentLanguage.value == 'en' ? 'id' : 'en';
    updateLocale();
  }

  void updateLocale() {
    final locale = currentLanguage.value == 'id' 
        ? const Locale('id', 'ID')
        : const Locale('en', 'US');
    Get.updateLocale(locale);
  }

  String get flagEmoji => currentLanguage.value == 'en' ? '🇬🇧' : '🇮🇩';
}