import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/controllers/card_controller.dart';
import 'package:SuaraKita/controllers/category_controller.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import 'package:SuaraKita/models/database.dart' as db;
import 'package:SuaraKita/utils/asset_helper.dart';

class AvailableCard extends StatelessWidget {
  final db.CardWithCategory cardWithCategory;
  final CardController cardController;
  final CategoryController categoryController;
  final LanguagesController langController;

  const AvailableCard({
    super.key,
    required this.cardWithCategory,
    required this.cardController,
    required this.categoryController,
    required this.langController,
  });

  @override
  Widget build(BuildContext context) {
    final card = cardWithCategory.card;
    final category = cardWithCategory.category;

    // Resolve the category color once at build time. The strip doesn't
    // depend on observable state — no need to keep it inside an Obx.
    Color color = Colors.grey;
    if (category != null) {
      if (category.color != null) {
        color = Color(category.color!);
      } else {
        final parent = categoryController.getParentCategory(category);
        if (parent?.color != null) {
          color = Color(parent!.color!);
        }
      }
    }

    final hasImage = card.imagePath != null && card.imagePath!.isNotEmpty;
    // Decoded once, reused on every selection toggle.
    final imageWidget = hasImage
        ? RepaintBoundary(child: AssetHelper.cardImage(card.imagePath))
        : null;

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => cardController.toggleCardSelection(card),
        child: Obx(() {
          final isTextMode = cardController.isTextMode.value;
          final lang = langController.currentLanguage.value;
          final label = lang == 'en' ? (card.enName ?? card.name) : card.name;
          final showImage = !isTextMode && imageWidget != null;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showImage)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: imageWidget,
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                if (showImage)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
