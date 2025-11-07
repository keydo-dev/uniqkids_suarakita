import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static Map<String, Map<String, String>> _loadedTranslations = {};

  static Future<void> init() async {
    // Load English translations
    String enString = await rootBundle.loadString('assets/translations/en.json');
    Map<String, dynamic> enJson = json.decode(enString);
    _loadedTranslations['en_US'] = enJson.map((key, value) => MapEntry(key, value.toString()));

    // Load Indonesian translations
    String idString = await rootBundle.loadString('assets/translations/id.json');
    Map<String, dynamic> idJson = json.decode(idString);
    _loadedTranslations['id_ID'] = idJson.map((key, value) => MapEntry(key, value.toString()));

    Get.addTranslations(_loadedTranslations);
  }

  @override
  Map<String, Map<String, String>> get keys => _loadedTranslations;
}
