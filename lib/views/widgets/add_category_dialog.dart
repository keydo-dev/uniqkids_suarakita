import 'package:SuaraKita/const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/controllers/category_controller.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final CategoryController categoryController = Get.find<CategoryController>();
  final LanguagesController langController = Get.find<LanguagesController>();
  final nameController = TextEditingController();
  final enNameController = TextEditingController();
  final selectedColorIndex = 0.obs;
  final isLoading = true.obs;
  final availableColors = <Color>[].obs;

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    try {
      isLoading.value = true;
      
      // Pastikan categories sudah loaded
      if (categoryController.categories.isEmpty) {
        await categoryController.loadCategories();
      }
      
      // Get colors dari controller
      final colors = categoryController.getAvailableColors();
      
      print('=== LOADED COLORS ===');
      print('Colors count: ${colors.length}');
      colors.forEach((c) => print('Color: ${c.value.toRadixString(16)}'));
      print('===================');
      
      availableColors.assignAll(colors);
    } catch (e) {
      print('Error loading colors: $e');
      // Fallback ke default color
      availableColors.assignAll([const Color(0xFF6DB5C6)]);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper untuk determine text color (white/black) based on background brightness
  Color _getTextColor(Color backgroundColor) {
    final brightness = backgroundColor.computeLuminance();
    return brightness > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  void dispose() {
    nameController.dispose();
    enNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFD4EEF5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 450,
        constraints: const BoxConstraints(maxHeight: 650),
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          if (isLoading.value) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final isEnglish = langController.currentLanguage.value == 'en';

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      'edit_add_category_dialog_title'.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textprimaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, size: 28),
                      color: btnPrimaryColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Folder Preview
                Obx(() {
                  final colors = availableColors;
                  if (colors.isEmpty) {
                    return const SizedBox(height: 200);
                  }
                  
                  final safeIndex = selectedColorIndex.value.clamp(0, colors.length - 1);
                  final selectedColor = colors[safeIndex];
                  return SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        // Main folder body
                        Positioned(
                          top: 32,
                          left: 40,
                          right: 40,
                          bottom: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Folder tab
                        Positioned(
                          top: 0,
                          left: 40,
                          child: Container(
                            width: 90,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selectedColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 24),
                
                // Color Picker - Horizontal Scroll dengan Scrollbar
                Obx(() {
                  final colors = availableColors;
                  if (colors.isEmpty) {
                    return Text(
                      isEnglish ? 'No colors available' : 'Tidak ada warna tersedia'
                    );
                  }
                  
                  final safeIndex = selectedColorIndex.value.clamp(0, colors.length - 1);
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Scrollbar(
                      thumbVisibility: true,  // Always show scrollbar
                      thickness: 4,
                      radius: const Radius.circular(2),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                            colors.length,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                              child: GestureDetector(
                                onTap: () => selectedColorIndex.value = i,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: safeIndex == i ? 52 : 44,
                                  height: safeIndex == i ? 52 : 44,
                                  decoration: BoxDecoration(
                                    color: colors[i],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: safeIndex == i 
                                          ? Colors.white 
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: safeIndex == i
                                        ? [
                                            BoxShadow(
                                              color: colors[i].withOpacity(0.5),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: safeIndex == i
                                      ? Icon(
                                          Icons.check,
                                          color: _getTextColor(colors[i]),
                                          size: 24,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 24),
                
                // Indonesian Name Input
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: isEnglish 
                        ? 'Category Name (Indonesian)'
                        : 'Nama Kategori (Indonesia)',
                    hintText: isEnglish
                        ? 'Enter category name in Indonesian'
                        : 'Masukkan nama kategori dalam Bahasa Indonesia',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF3E4A59),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // English Name Input
                TextField(
                  controller: enNameController,
                  decoration: InputDecoration(
                    labelText: isEnglish
                        ? 'Category Name (English)'
                        : 'Nama Kategori (Inggris)',
                    hintText: isEnglish
                        ? 'Enter category name in English'
                        : 'Masukkan nama kategori dalam Bahasa Inggris',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF3E4A59),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A5B),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'edit_cancel_button'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty && availableColors.isNotEmpty) {
                          final colors = availableColors;
                          final safeIndex = selectedColorIndex.value.clamp(0, colors.length - 1);
                          
                          print('Adding category:');
                          print('  Name (ID): ${nameController.text}');
                          print('  Name (EN): ${enNameController.text}');
                          print('  Color: ${colors[safeIndex].value.toRadixString(16)}');
                          
                          categoryController.addCategory(
                            nameController.text,
                            colors[safeIndex].value,
                            enName: enNameController.text.isNotEmpty 
                                ? enNameController.text 
                                : null,
                          );
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3E4A59),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'edit_add_button'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}