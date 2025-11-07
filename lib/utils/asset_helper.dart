
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AssetHelper {
  static Future<String> getImage(String? imagePath) async {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('assets/')) {
        try {
          await rootBundle.load(imagePath);
          return imagePath;
        } catch (_) {
          return 'assets/images/img_asset/default.png';
        }
      } else {
        if (await File(imagePath).exists()) {
          return imagePath;
        }
      }
    }
    return 'assets/images/img_asset/default.png';
  }

  static Future<String> getSound(String? soundPath) async {
    if (soundPath != null && soundPath.isNotEmpty) {
      if (soundPath.startsWith('assets/')) {
        try {
          await rootBundle.load(soundPath);
          return soundPath;
        } catch (_) {
          final langCode = Get.locale?.languageCode ?? 'en';
          return 'assets/sound/$langCode/default.mp3';
        }
      } else {
        if (await File(soundPath).exists()) {
          return soundPath;
        }
      }
    }
    final langCode = Get.locale?.languageCode ?? 'en';
    return 'assets/sound/$langCode/default.mp3';
  }
}
