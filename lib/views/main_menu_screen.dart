import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/const.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import 'package:SuaraKita/views/widgets/voice_settings_dialog.dart';

import 'package:flutter/services.dart';

class MainMenuScreen extends StatelessWidget {
  final LanguagesController languageController =
      Get.find<LanguagesController>();

  MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/pattern-img.png"),
            fit: BoxFit.fitWidth,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  children: [
                    const Spacer(flex: 6),
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset('assets/images/img-icon.png'),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'title'.tr,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textprimaryColor,
                      ),
                    ),
                    const SizedBox(height: 38),
                    _buildMenuButton(
                      label: 'menu_play'.tr,
                      onTap: () => Get.toNamed('/play'),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                      label: 'menu_edit'.tr,
                      onTap: () => Get.toNamed('/edit'),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                      label: 'menu_exit'.tr,
                      onTap: () => SystemNavigator.pop(),
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),

                    Column(
                      children: [
                        Text(
                          "made with ♥ by",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Image.asset(
                          'assets/images/uniqkids-logo.png',
                          width: MediaQuery.of(context).size.width * 0.2,
                        ),
                      ],
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
              Positioned(top: 20, right: 20, child: _buildLanguageToggle()),
              Positioned(top: 20, left: 20, child: _buildSettingsButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton() {
    return GestureDetector(
      onTap: () => Get.dialog(const VoiceSettingsDialog()),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.settings, size: 22, color: textprimaryColor),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Obx(
      () => GestureDetector(
        onTap: languageController.toggleLanguage,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                languageController.flagEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 4),
              Text(
                languageController.currentLanguage.value.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textprimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? btnPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
