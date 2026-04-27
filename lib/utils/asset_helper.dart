import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AssetHelper {
  static const String defaultImage = 'assets/images/img_asset/default.png';

  // Cache file existence checks so we don't hit the filesystem on every
  // build. Cards that reference the same file path are extremely common.
  static final Map<String, bool> _fileExistsCache = {};

  /// Synchronous image widget. No async, no FutureBuilder, no
  /// `rootBundle.load` to verify existence — `Image.asset` handles missing
  /// assets via `errorBuilder`. Flutter's image cache takes care of the rest.
  ///
  /// This is hot-path code: it's called once per card on every grid rebuild.
  static Widget cardImage(
    String? imagePath, {
    BoxFit fit = BoxFit.contain,
  }) {
    if (imagePath == null || imagePath.isEmpty) {
      return Image.asset(defaultImage, fit: fit);
    }

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (_, _, _) => Image.asset(defaultImage, fit: fit),
      );
    }

    final exists = _fileExistsCache.putIfAbsent(
      imagePath,
      () => File(imagePath).existsSync(),
    );
    if (!exists) return Image.asset(defaultImage, fit: fit);

    return Image.file(
      File(imagePath),
      fit: fit,
      errorBuilder: (_, _, _) => Image.asset(defaultImage, fit: fit),
    );
  }

  /// Invalidate a cached file-existence entry (e.g. after the user records
  /// a new image to that path).
  static void invalidate(String path) => _fileExistsCache.remove(path);

  /// Resolve a sound path. Sounds are looked up rarely (only at playback
  /// time), so the async existence check is acceptable here.
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
