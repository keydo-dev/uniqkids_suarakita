import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/card_controller.dart';
import '../controllers/category_controller.dart';
import '../models/database.dart' as db;

class PlayScreen extends StatelessWidget {
  final CardController cardController = Get.find<CardController>();
  final CategoryController categoryController = Get.find<CategoryController>();

  PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('play_title'.tr),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            clipBehavior: Clip.none,
            height: 160,
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          Obx(() => ElevatedButton(
                                onPressed: cardController.selectedCards.isEmpty
                                    ? null
                                    : cardController.playSelectedCards,
                                child: Text('play_button'.tr),
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
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('play_mode_abc'.tr),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('play_mode_image'.tr),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => cardController.selectedCards.isEmpty
                        ? Center(
                            child: Text(
                              'play_empty'.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ReorderableListView(
                            scrollDirection: Axis.horizontal,
                            onReorder: (oldIndex, newIndex) {
                              cardController.reorderSelectedCards(
                                  oldIndex, newIndex);
                            },
                            children: cardController.selectedCards
                                .asMap()
                                .entries
                                .map((entry) => _buildSelectedCard(
                                    entry.value, entry.key))
                                .toList(),
                          ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(thickness: 2),

          Expanded(
            child: StreamBuilder<List<db.CardWithCategory>>(
              stream: cardController.watchCardsWithCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cards = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'play_available'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () => GridView.builder(
                          padding: const EdgeInsets.all(8),
                          physics: AlwaysScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                cardController.isTextMode.value ? 1 : 2,
                            childAspectRatio:
                                cardController.isTextMode.value ? 8 : 1,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final card = cards[index];
                            return _buildAvailableCard(card);
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

  Widget _buildSelectedCard(db.Card card, int index) {
    return Container(
      key: ValueKey(card.id),
      width: 100,
      height: 120,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              if (!cardController.isTextMode.value && card.imagePath != null)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 30),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(8),
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
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableCard(db.CardWithCategory cardData) {
    final card = cardData.card;
    final category = cardData.category;

    return GestureDetector(
      onTap: () => cardController.addToSelected(card),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: cardController.isTextMode.value
            ? ListTile(
                title: Text(card.name),
                subtitle: Text(category?.name ?? ''),
                trailing: const Icon(Icons.add_circle_outline),
              )
            : Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: card.imagePath != null
                          ? const Center(child: Icon(Icons.image, size: 40))
                          : const Center(child: Icon(Icons.music_note, size: 40)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
