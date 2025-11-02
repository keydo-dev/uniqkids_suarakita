import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uniqkids_suarakita/bindings/app_bidings.dart';
import 'package:uniqkids_suarakita/models/database.dart';
import 'package:uniqkids_suarakita/routes/app_pages.dart';
import 'package:uniqkids_suarakita/translations/app_translation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  // Inisialisasi DB dan default data
  final db = AppDatabase();
  await db.initializeData(); // pastikan JSON masuk DB

  // Inisialisasi controller & bindings
  final appBindings = AppBindings(db);
  appBindings.dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SuaraKita AAC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
