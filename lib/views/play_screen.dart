import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniqkids_suarakita/const.dart';
import '../controllers/card_controller.dart';
import '../controllers/category_controller.dart';
import '../services/audio_services.dart';
import '../models/database.dart' as db;

class PlayScreen extends StatelessWidget {
  final CardController cardController = Get.find<CardController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final AudioService audioService = AudioService();

  PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    audioService.init();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: btnPrimaryColor,
        title: Text(
          'play_title'.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // SECTION: Selected Cards
          Container(
            height: 160,
            color: primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header + tombol
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'play_selected'.tr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Obx(() => ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: btnPrimaryColor,
                                ),
                                onPressed: cardController.selectedCards.isEmpty
                                    ? null
                                    : cardController.playSelectedCards,
                                child: Text('play_button'.tr,
                                    style: const TextStyle(color: Colors.white)),
                              )),
                          const SizedBox(width: 8),
                          Obx(() => ToggleButtons(
                                isSelected: [
                                  cardController.isTextMode.value,
                                  !cardController.isTextMode.value,
                                ],
                                onPressed: (index) {
                                  cardController.toggleViewMode();
                                },
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('ABC'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: const Icon(Icons.image),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),

                // Selected cards list
                Expanded(
                  child: Obx(
                    () => cardController.selectedCards.isEmpty
                        ? Center(
                            child: Text(
                              'play_empty'.tr,
                              style: const TextStyle(fontSize: 14, color: textprimaryColor),
                            ),
                          )
                        : ReorderableListView(
                            scrollDirection: Axis.horizontal,
                            onReorder: (oldIndex, newIndex) {
                              cardController.reorderSelectedCards(oldIndex, newIndex);
                            },
                            children: cardController.selectedCards
                                .asMap()
                                .entries
                                .map((entry) => _buildSelectedCard(entry.value, entry.key))
                                .toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(thickness: 2, color: btnPrimaryColor),

          // SECTION: Available Cards
          Expanded(
            child: StreamBuilder<List<db.CardWithCategory>>(
              stream: cardController.watchCardsWithCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cards = snapshot.data!;
                if (cards.isEmpty) {
                  return const Center(child: Text('Belum ada kartu.'));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'play_available'.tr,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () => GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                cardController.isTextMode.value ? 1 : 2,
                            childAspectRatio:
                                cardController.isTextMode.value ? 8 : 1,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final cardData = cards[index];
                            return _buildAvailableCard(cardData);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget kartu yang sedang dipilih
  Widget _buildSelectedCard(db.Card card, int index) {
    return Container(
      key: ValueKey(card.id),
      width: 110,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 4),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              if (!cardController.isTextMode.value && card.imagePath != null)
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    child: _buildImage(card.imagePath!),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  card.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => cardController.removeFromSelected(card),
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget kartu yang tersedia
  Widget _buildAvailableCard(db.CardWithCategory cardData) {
    final card = cardData.card;
    final category = cardData.category;

    return GestureDetector(
      onTap: () => cardController.addToSelected(card),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: cardController.isTextMode.value
            ? ListTile(
                title: Text(card.name),
                subtitle: Text(category?.name ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {
                    if (card.soundPath != null &&
                        File(card.soundPath!).existsSync()) {
                      audioService.playFile(card.soundPath!);
                    }
                  },
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(10)),
                      child: _buildImage(card.imagePath),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Column(
                      children: [
                        Text(
                          card.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          category?.name ?? '',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 18),
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
                ],
              ),
      ),
    );
  }

  Widget _buildImage(String? path) {
  Widget imageWidget;

  if (path == null) {
    imageWidget = const Icon(Icons.image_not_supported, size: 30);
  } else if (path.startsWith('assets/')) {
    imageWidget = Image.asset(path, fit: BoxFit.cover);
  } else if (File(path).existsSync()) {
    imageWidget = Image.file(File(path), fit: BoxFit.cover);
  } else {
    imageWidget = const Icon(Icons.broken_image, size: 30);
  }

  return Padding(
    padding: const EdgeInsets.all(10), // atur sesuai kebutuhan
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: Colors.transparent,
        child: imageWidget,
      ),
    ),
  );
}
}
