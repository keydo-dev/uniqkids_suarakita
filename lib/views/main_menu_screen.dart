import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniqkids_suarakita/const.dart';
import 'package:uniqkids_suarakita/controllers/languages_controller.dart';

class MainMenuScreen extends StatelessWidget {
  final LanguagesController languageController = Get.find<LanguagesController>();

  MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
                image: AssetImage("assets/images/pattern-img.png"),
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter
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
                      child: Image.asset(
                        'assets/images/img-icon.png',
                      ),
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
                    const Spacer(flex: 3),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: _buildLanguageToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Obx(() => GestureDetector(
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
    ));
  }

  Widget _buildMenuButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}