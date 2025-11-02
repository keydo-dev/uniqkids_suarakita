import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/category_controller.dart';
import '../controllers/card_controller.dart';
import '../services/audio_services.dart';
import '../models/database.dart' as db;

class EditScreen extends StatelessWidget {
  final CategoryController categoryController = Get.find<CategoryController>();
  final CardController cardController = Get.find<CardController>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E4A59),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Kotak Kata',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddCategoryDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Tambah kategori',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
                  label: const Text(
                    'Tambah kosa kata',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
                        childAspectRatio: 0.85,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final color = Color(category.color ?? 0xFF6DB5C6);
                        return GestureDetector(
                          onTap: () => _showCategoryCards(category),
                          child: CategoryCard(
                            category: category,
                            color: color,
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
    );
  }
}

// Screen untuk menampilkan cards dalam kategori
class CategoryCardsScreen extends StatelessWidget {
  final db.Category category;
  final CardController cardController = Get.find<CardController>();

  CategoryCardsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(category.color ?? 0xFF3E4A59),
        title: Text(
          category.name,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: FutureBuilder<List<db.Card>>(
        future: cardController.getCardsByCategory(category.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final cards = snapshot.data!;
          
          if (cards.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada kartu di kategori ini',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return CardItem(card: card);
            },
          );
        },
      ),
    );
  }
}

// Widget untuk menampilkan card item
class CardItem extends StatelessWidget {
  final db.Card card;
  final AudioService audioService = AudioService();

  CardItem({super.key, required this.card});

  Widget _buildImage(String? path) {
    if (path == null) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image_not_supported, size: 40),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover);
    }

    if (File(path).existsSync()) {
      return Image.file(File(path), fit: BoxFit.cover);
    }

    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: _buildImage(card.imagePath),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    card.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (card.enName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      card.enName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20),
                    onPressed: () {
                      if (card.soundPath != null &&
                          File(card.soundPath!).existsSync()) {
                        audioService.playFile(card.soundPath!);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
                const Text(
                  'Tambah kategori',
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
                hintText: 'Nama kategori',
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
                  child: const Text(
                    'Batal',
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
                  child: const Text(
                    'Tambah',
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

class AddVocabularyDialog extends StatefulWidget {
  const AddVocabularyDialog({super.key});

  @override
  State<AddVocabularyDialog> createState() => _AddVocabularyDialogState();
}

class _AddVocabularyDialogState extends State<AddVocabularyDialog> {
  final CardController cardController = Get.find<CardController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final AudioService audioService = AudioService();
  
  final TextEditingController indoController = TextEditingController();
  final TextEditingController engController = TextEditingController();
  final selectedCategory = Rxn<db.Category>();
  
  File? imageFile;
  String? recordedSoundPath;
  bool isRecording = false;

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

  Future<void> _toggleRecording() async {
    if (isRecording) {
      await audioService.stopRecording();
      setState(() => isRecording = false);
    } else {
      final path = await audioService.startRecording();
      if (path != null) {
        setState(() {
          isRecording = true;
          recordedSoundPath = path;
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
                const Text(
                  'Tambah kosa kata',
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
                        children: const [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Color(0xFF2C3E50),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Masukkan\nGambar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
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
                      hint: const Text('Pilih kategori'),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
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
                hintText: 'Masukkan Kata Indonesia',
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
                hintText: 'Masukkan Kata English',
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
                      color: isRecording
                          ? Colors.red
                          : const Color(0xFFFF8A5B),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _toggleRecording,
                      icon: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      isRecording ? 'Recording...' : 'Rec',
                      style: TextStyle(
                        color: isRecording
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory.value != null &&
                    indoController.text.isNotEmpty &&
                    engController.text.isNotEmpty) {
                  cardController.addCard(
                    name: indoController.text,
                    enName: engController.text,
                    categoryId: selectedCategory.value!.id,
                    imagePath: imageFile?.path,
                    soundPath: recordedSoundPath,
                  );
                }
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
              child: const Text(
                'Tambah',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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

class CategoryCard extends StatelessWidget {
  final db.Category category;
  final Color color;

  const CategoryCard({
    super.key,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main folder body
        Positioned(
          top: 24,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
        // Folder tab
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 90,
            height: 32,
            decoration: BoxDecoration(
              color: color,
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
    );
  }
}