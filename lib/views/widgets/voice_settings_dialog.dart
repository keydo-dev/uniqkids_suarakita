import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/const.dart';
import 'package:SuaraKita/controllers/voice_controller.dart';

class VoiceSettingsDialog extends StatelessWidget {
  const VoiceSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceController = Get.find<VoiceController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'settings_title'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textprimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: voiceController.useTts.value,
                onChanged: voiceController.setUseTts,
                title: Text(
                  'settings_use_tts'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'settings_use_tts_hint'.tr,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'settings_voice_gender'.tr,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final gender = voiceController.voiceGender.value;
              return Row(
                children: [
                  Expanded(
                    child: _GenderChip(
                      label: 'voice_female'.tr,
                      icon: Icons.face_3,
                      selected: gender == 'female',
                      onTap: () => voiceController.setGender('female'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderChip(
                      label: 'voice_male'.tr,
                      icon: Icons.face,
                      selected: gender == 'male',
                      onTap: () => voiceController.setGender('male'),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text('settings_close'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? btnPrimaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? btnPrimaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: selected ? Colors.white : Colors.grey[700],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
