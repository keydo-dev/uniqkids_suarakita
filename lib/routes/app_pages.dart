


import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:uniqkids_suarakita/bindings/app_bidings.dart';
import 'package:uniqkids_suarakita/views/edit_screen.dart';
import 'package:uniqkids_suarakita/views/main_menu_screen.dart';
import 'package:uniqkids_suarakita/views/play_screen.dart';
import 'package:uniqkids_suarakita/views/splash_screen.dart';

class AppPages {
  static const INITIAL = '/splash';

  static final routes = [
    GetPage(name: '/splash', 
    page: () => SplashScreen(),
    binding: AppBidings()
    ),
    GetPage(name: '/main', 
    page: () => MainMenuScreen(),
    binding: AppBidings()
    ),
    GetPage(name: '/play', 
    page: () => PlayScreen(),
    binding: AppBidings()
    ),
    GetPage(name: '/edit', 
    page: () => EditScreen(),
    binding: AppBidings()
    ),
  ];
}

class Routes {
  static const SPLASH = '/splash';
  static const MAIN = '/main';
  static const PLAY = '/play';
  static const EDIT = '/edit';
}