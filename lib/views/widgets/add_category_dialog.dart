import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/controllers/category_controller.dart';

class AddCategoryDialog extends StatelessWidget {
  AddCategoryDialog({super.key});
  final CategoryController categoryController = Get.find<CategoryController>();
  final controller = TextEditingController();
  final selectedColorIndex = 6.obs;

  final colors = const [
    Color(0xFFFF8A5B),
    Color(0xFFFF6B6B),
    Color(0xFFFFC107),
    Color(0xFF64C5F2),
    Color(0xFF5B8DEF),
    Color(0xFF4ECB71),
    Color(0xFF6DB5C6),
  ];

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
                  'edit_add_category_dialog_title'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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
            Obx(() => Stack(
              children: [
                Positioned(
                  top: 24,
                  left: 40,
                  right: 40,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors[selectedColorIndex.value],
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
                Positioned(
                  top: 0,
                  left: 40,
                  child: Container(
                    width: 90,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors[selectedColorIndex.value],
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
                SizedBox(height: 140),
              ],
            )),
            const SizedBox(height: 24),
            Obx(() => Wrap(
              spacing: 8,
              children: List.generate(
                colors.length,
                (i) => GestureDetector(
                  onTap: () => selectedColorIndex.value = i,
                  child: CircleAvatar(
                    backgroundColor: colors[i],
                    radius: selectedColorIndex.value == i ? 20 : 16,
                    child: selectedColorIndex.value == i
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            )),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'edit_category_name_hint'.tr,
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
                  ),
                  child: Text(
                    'edit_cancel_button'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      categoryController.addCategory(
                        controller.text,
                        colors[selectedColorIndex.value].value,
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
                  ),
                  child: Text(
                    'edit_add_button'.tr,
                    style: TextStyle(
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
      ),
    );
  }
}
