import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SuaraKita/controllers/card_controller.dart';
import 'package:SuaraKita/controllers/category_controller.dart';
import 'package:SuaraKita/models/database.dart' as db;
import 'package:SuaraKita/services/audio_services.dart';

class AddVocabularyDialog extends StatefulWidget {
  const AddVocabularyDialog({super.key});

  @override
  State<AddVocabularyDialog> createState() => _AddVocabularyDialogState();
}

class _AddVocabularyDialogState extends State<AddVocabularyDialog> {
  final CardController cardController = Get.find<CardController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final AudioService audioService = Get.find<AudioService>();
  
  final TextEditingController indoController = TextEditingController();
  final TextEditingController engController = TextEditingController();
  final selectedCategory = Rxn<db.Category>();
  
  File? imageFile;
  String? recordedSoundPathId;
  String? recordedSoundPathEn;
  bool isRecordingId = false;
  bool isRecordingEn = false;

  @override
  void initState() {
    super.initState();
    audioService.init();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> _toggleRecording(String lang) async {
    final isRecording = lang == 'id' ? isRecordingId : isRecordingEn;
    if (isRecording) {
      await audioService.stopRecording();
      setState(() {
        if (lang == 'id') {
          isRecordingId = false;
        } else {
          isRecordingEn = false;
        }
      });
    } else {
      if (indoController.text.isEmpty) {
        Get.snackbar('Error', 'Please enter the Indonesian word first.');
        return;
      }
      final path = await audioService.startRecording(fileName: indoController.text, lang: lang);
      if (path != null) {
        setState(() {
          if (lang == 'id') {
            isRecordingId = true;
            recordedSoundPathId = path;
          } else {
            isRecordingEn = true;
            recordedSoundPathEn = path;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFD4EEF5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  'edit_add_vocabulary_dialog_title'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, size: 28),
                  color: const Color(0xFF2C3E50),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2C3E50),
                    width: 2,
                  ),
                ),
                child: imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Color(0xFF2C3E50),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'edit_add_image_text'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<db.Category>>(
              stream: categoryController.watchCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final categories = snapshot.data!;
                return Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: DropdownButton<db.Category>(
                      value: selectedCategory.value,
                      hint: Text('edit_select_category_hint'.tr),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(Get.locale?.languageCode == 'en' ? c.enName ?? c.name : c.name),
                              ))
                          .toList(),
                      onChanged: (val) => selectedCategory.value = val,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: indoController,
              decoration: InputDecoration(
                hintText: 'edit_enter_indonesian_word_hint'.tr,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: engController,
              decoration: InputDecoration(
                hintText: 'edit_enter_english_word_hint'.tr,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('edit_record_id_label'.tr, style: TextStyle(fontSize: 16)),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isRecordingId
                                  ? Colors.red
                                  : const Color(0xFFFF8A5B),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => _toggleRecording('id'),
                              icon: Icon(
                                isRecordingId ? Icons.stop : Icons.mic,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              isRecordingId ? 'edit_recording_text'.tr : 'edit_rec_text'.tr,
                              style: TextStyle(
                                color: isRecordingId
                                    ? Colors.red
                                    : const Color(0xFFFF8A5B),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('edit_record_en_label'.tr, style: TextStyle(fontSize: 16)),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isRecordingEn
                                  ? Colors.red
                                  : const Color(0xFFFF8A5B),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => _toggleRecording('en'),
                              icon: Icon(
                                isRecordingEn ? Icons.stop : Icons.mic,
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              isRecordingEn ? 'edit_recording_text'.tr : 'edit_rec_text'.tr,
                              style: TextStyle(
                                color: isRecordingEn
                                    ? Colors.red
                                    : const Color(0xFFFF8A5B),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory.value == null) {
                  Get.snackbar('error_snackbar_title'.tr, 'error_select_category_snackbar'.tr);
                  return;
                }
                if (indoController.text.isEmpty) {
                  Get.snackbar('error_snackbar_title'.tr, 'error_enter_indonesian_word_snackbar'.tr);
                  return;
                }
                if (engController.text.isEmpty) {
                  Get.snackbar('error_snackbar_title'.tr, 'error_enter_english_word_snackbar'.tr);
                  return;
                }

                cardController.addCard(
                  name: indoController.text,
                  enName: engController.text,
                  categoryId: selectedCategory.value!.id,
                  imagePath: imageFile?.path,
                  soundPath: recordedSoundPathId,
                  enSoundPath: recordedSoundPathEn,
                );
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E4A59),
                padding: const EdgeInsets.symmetric(
                  horizontal: 64,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'edit_add_button'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
