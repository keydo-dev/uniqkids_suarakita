import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/const.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import '../controllers/card_controller.dart';
import '../controllers/category_controller.dart';
import '../services/audio_services.dart';
import '../models/database.dart' as db;
import 'package:SuaraKita/views/widgets/available_card.dart';
import '../utils/asset_helper.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final CardController cardController = Get.find<CardController>();
  final CategoryController categoryController = Get.find<CategoryController>();
  final LanguagesController langController = Get.find<LanguagesController>();
  final AudioService audioService = Get.find<AudioService>();

  @override
  void initState() {
    super.initState();
    audioService.init();
  }

  @override
  void dispose() {
    audioService.stopPlayer();
    super.dispose();
  }

  Widget _buildSelectedCard(db.Card card, int key) {
    return ReorderableDragStartListener(
      index: key,
      key: ValueKey(key),
      child: Obx(
        () => Container(
          width: 100,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!cardController.isTextMode.value)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FutureBuilder<String>(
                                future: AssetHelper.getImage(card.imagePath),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (snapshot.hasError ||
                                      !snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    );
                                  }
                                  final imagePath = snapshot.data!;
                                  return imagePath.startsWith('assets/')
                                      ? Image.asset(
                                          imagePath,
                                          fit: BoxFit.contain,
                                        )
                                      : Image.file(
                                          File(imagePath),
                                          fit: BoxFit.contain,
                                        );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              4.0,
                              0,
                              4.0,
                              10.0,
                            ),
                            child: Text(
                              langController.currentLanguage.value == 'en'
                                  ? card.enName ?? card.name
                                  : card.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (cardController.isTextMode.value)
                    Expanded(
                      child: Center(
                        child: Text(
                          langController.currentLanguage.value == 'en'
                              ? card.enName ?? card.name
                              : card.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              // STRIP WARNA KATEGORI
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StreamBuilder<db.Category?>(
                  stream: categoryController.watchCategoryById(card.categoryId),
                  builder: (context, snapshot) {
                    final category = snapshot.data;
                              Color color = Colors.grey;
                              if (category != null) {
                                if (category.color != null) {
                                  color = Color(category.color!);
                                } else {
                                  final parent = categoryController.getParentCategory(category!);
                                  if (parent?.color != null) {
                                    color = Color(parent!.color!);
                                  }
                                }
                              }                    return Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => cardController.removeCard(card),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableCard(
    db.CardWithCategory cardWithCategory,
  ) {
    return AvailableCard(
      cardWithCategory: cardWithCategory,
      cardController: cardController,
      categoryController: categoryController,
      langController: langController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: btnPrimaryColor,
        title: Text(
          'play_title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            audioService.stopPlayer();
            cardController.clearSelection();
            Get.back();
          },
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Obx(
                            () => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: btnPrimaryColor,
                              ),
                              onPressed: cardController.selectedCards.isEmpty
                                  ? null
                                  : cardController.playSelectedCards,
                              child: Text(
                                'play_button'.tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(
                            () => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: cardController.selectedCards.isEmpty
                                  ? null
                                  : () {
                                      audioService.stopPlayer();
                                      cardController.clearSelection();
                                    },
                              child: Text(
                                'clear_button'.tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(
                            () => ToggleButtons(
                              isSelected: [
                                cardController.isTextMode.value,
                                !cardController.isTextMode.value,
                              ],
                              onPressed: (index) {
                                cardController.toggleViewMode();
                              },
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text('ABC'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: const Icon(Icons.image),
                                ),
                              ],
                            ),
                          ),
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
                              style: const TextStyle(
                                fontSize: 14,
                                color: textprimaryColor,
                              ),
                            ),
                          )
                        : ReorderableListView(
                            scrollDirection: Axis.horizontal,
                            onReorder: (oldIndex, newIndex) {
                              cardController.reorderSelectedCards(
                                oldIndex,
                                newIndex,
                              );
                            },
                            children: cardController.selectedCards
                                .asMap()
                                .entries
                                .map(
                                  (entry) => _buildSelectedCard(
                                    entry.value,
                                    entry.key,
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(thickness: 1, color: btnPrimaryColor),

          // SECTION: Available Cards
          Expanded(
            child: StreamBuilder<List<db.Category>>(
              stream: categoryController.watchCategories(),
              builder: (context, categorySnapshot) {
                if (!categorySnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = categorySnapshot.data!;
                if (categories.isEmpty) {
                  return const Center(child: Text('No categories available.'));
                }

                final screenWidth = MediaQuery.of(context).size.width;
                const spacing = 8.0;
                const padding = 8.0;
                final itemWidth =
                    (screenWidth - (10 * spacing) - (2 * padding)) / 11;

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return StreamBuilder<List<db.Card>>(
                      stream: cardController.watchCardsByCategoryId(
                        category.id,
                      ),
                      builder: (context, cardSnapshot) {
                        if (!cardSnapshot.hasData ||
                            cardSnapshot.data!.isEmpty) {
                          return SizedBox.shrink(); // Hide category if no cards
                        }

                        final cards = cardSnapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                langController.currentLanguage.value == 'en'
                                    ? category.enName ?? category.name
                                    : category.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(padding),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 11,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: spacing,
                                    mainAxisSpacing: spacing,
                                  ),
                              itemCount: cards.length,
                              itemBuilder: (context, cardIndex) {
                                final card = cards[cardIndex];
                                return _buildAvailableCard(
                                  db.CardWithCategory(card, category),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
