import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:uniqkids_suarakita/routes/app_pages.dart';
import 'package:uniqkids_suarakita/translations/app_translation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SuaraKita ACC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      translations: AppTranslations(),
      locale: Locale('en', 'US'),
      fallbackLocale: Locale('en', 'US'),
     initialRoute: AppPages.INITIAL,
     getPages: AppPages.routes,
    );
  }
}