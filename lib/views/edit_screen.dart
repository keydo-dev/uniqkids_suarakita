import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../controllers/card_controller.dart';
import '../models/database.dart' as db;
import 'package:SuaraKita/views/category_cards_screen.dart';
import 'package:SuaraKita/views/widgets/add_category_dialog.dart';
import 'package:SuaraKita/views/widgets/add_vocabulary_dialog.dart';
import 'package:SuaraKita/views/widgets/category_card.dart';

class EditScreen extends StatelessWidget {
  final CategoryController categoryController = Get.find<CategoryController>();
  final CardController cardController = Get.find<CardController>();
  final isDeleteMode = false.obs;
  final selectedCategories = <db.Category>[].obs;

  EditScreen({super.key});

  void _showAddCategoryDialog() {
    Get.dialog(AddCategoryDialog());
  }

  void _showAddVocabularyDialog() {
    Get.dialog(AddVocabularyDialog());
  }

  void _showCategoryCards(db.Category category) {
    Get.to(() => CategoryCardsScreen(category: category));
  }

  void _toggleDeleteMode() {
    isDeleteMode.value = !isDeleteMode.value;
    if (!isDeleteMode.value) {
      selectedCategories.clear();
    }
  }

  void _toggleCategorySelection(db.Category category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }

  void _showDeleteConfirmation() {
    if (selectedCategories.isEmpty) {
      Get.snackbar(
        'error_snackbar_title'.tr,
        'Pilih minimal satu kategori untuk dihapus',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${selectedCategories.length} kategori beserta semua kartu di dalamnya?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              for (var category in selectedCategories) {
                // Hapus semua kartu dalam kategori
                final cards = await cardController.getCardsByCategory(category.id);
                for (var card in cards) {
                  await cardController.deleteCard(card.id);
                }
                // Hapus kategori
                await categoryController.deleteCategory(category.id);
              }
              selectedCategories.clear();
              isDeleteMode.value = false;
              Get.snackbar(
                'Berhasil',
                'Kategori berhasil dihapus',
                backgroundColor: Colors.green[100],
                colorText: Colors.green[900],
                snackPosition: SnackPosition.TOP
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4A59),
        elevation: 0,
        leading: isDeleteMode.value
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _toggleDeleteMode,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
        title: Text(
          isDeleteMode.value 
              ? '${selectedCategories.length} dipilih'
              : 'edit_card_box_title'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!isDeleteMode.value)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _toggleDeleteMode,
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Column(
        children: [
          if (!isDeleteMode.value)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'edit_add_category_button'.tr,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E4A59),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddVocabularyDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'edit_add_vocabulary_button'.tr,
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E4A59),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<List<db.Category>>(
                  stream: categoryController.watchCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final categories = snapshot.data!;
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.7,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final color = Color(category.color ?? 0xFF6DB5C6);
                        final isSelected = selectedCategories.contains(category);
                        
                        return GestureDetector(
                          onTap: () {
                            if (isDeleteMode.value) {
                              _toggleCategorySelection(category);
                            } else {
                              _showCategoryCards(category);
                            }
                          },
                          child: Stack(
                            children: [
                              CategoryCard(
                                category: category,
                                color: color,
                              ),
                              if (isDeleteMode.value)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.blue : Colors.grey,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Icon(Icons.check_circle, color: Colors.blue, size: 24)
                                        : Icon(Icons.circle_outlined, color: Colors.grey, size: 24),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

