import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/controllers/card_controller.dart';
import 'package:SuaraKita/controllers/category_controller.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import 'package:SuaraKita/models/database.dart' as db;
import 'package:SuaraKita/views/widgets/catalogue_card.dart';

class CategoryCardsScreen extends StatefulWidget {
  final db.Category category;

  const CategoryCardsScreen({super.key, required this.category});

  @override
  State<CategoryCardsScreen> createState() => _CategoryCardsScreenState();
}

class _CategoryCardsScreenState extends State<CategoryCardsScreen> {
  final CardController cardController = Get.find<CardController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final LanguagesController langController = Get.find<LanguagesController>();

  bool _isDeleteMode = false;
  final Set<String> _selectedCardIds = {}; // Ubah dari Set<int> ke Set<String>

  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      if (!_isDeleteMode) {
        _selectedCardIds.clear();
      }
    });
  }

  void _toggleCardSelection(String cardId) { // Ubah parameter dari int ke String
    setState(() {
      if (_selectedCardIds.contains(cardId)) {
        _selectedCardIds.remove(cardId);
      } else {
        _selectedCardIds.add(cardId);
      }
    });
  }

  Future<void> _deleteSelectedCards() async {
    if (_selectedCardIds.isEmpty) {
      Get.snackbar(
        'Info',
        'Pilih minimal satu card untuk dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${_selectedCardIds.length} card?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (final cardId in _selectedCardIds) {
          await cardController.deleteCard(cardId); // Sekarang cardId sudah String
        }

        Get.snackbar(
          'Sukses',
          '${_selectedCardIds.length} card berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        setState(() {
          _selectedCardIds.clear();
          _isDeleteMode = false;
        });
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal menghapus card: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = Color(widget.category.color ?? 0xFF3E4A59);
    final textColor = _getTextColor(appBarColor);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Text(
          _isDeleteMode
              ? '${_selectedCardIds.length} dipilih'
              : Get.locale?.languageCode == 'id'
                  ? widget.category.name
                  : widget.category.enName ?? widget.category.name,
          style: TextStyle(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(
            _isDeleteMode ? Icons.close : Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () {
            if (_isDeleteMode) {
              _toggleDeleteMode();
            } else {
              Get.back();
            }
          },
        ),
        actions: [
          if (!_isDeleteMode)
            IconButton(
              icon: Icon(Icons.delete_outline, color: textColor),
              onPressed: _toggleDeleteMode,
              tooltip: 'Mode Hapus',
            )
          else ...[
            IconButton(
              icon: Icon(Icons.select_all, color: textColor),
              onPressed: () {
                // Toggle select all
              },
              tooltip: 'Pilih Semua',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: textColor),
              onPressed: _deleteSelectedCards,
              tooltip: 'Hapus',
            ),
          ],
        ],
      ),
      body: FutureBuilder<List<db.Card>>(
        future: cardController.getCardsByCategory(widget.category.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cards = snapshot.data!;

          if (cards.isEmpty) {
            return Center(
              child: Text(
                'edit_no_cards_in_category'.tr,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final isSelected = _selectedCardIds.contains(card.id);

              return GestureDetector(
                onTap: _isDeleteMode
                    ? () => _toggleCardSelection(card.id)
                    : null,
                child: Stack(
                  children: [
                    Opacity(
                      opacity: _isDeleteMode && !isSelected ? 0.5 : 1.0,
                      child: CatalogueCard(
                        cardWithCategory:
                            db.CardWithCategory(card, widget.category),
                        categoryController: categoryController,
                        langController: langController,
                      ),
                    ),
                    if (_isDeleteMode)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected ? Colors.red : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}