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

  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(widget.category.color ?? 0xFF3E4A59),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        title: Text(
          Get.locale?.languageCode == 'id' ? widget.category.name : widget.category.enName ?? widget.category.name,
          style: TextStyle(
            color: _getTextColor(Color(widget.category.color ?? 0xFF3E4A59)),
          ),
        ),
        leading: IconButton(
                icon: Icon(Icons.arrow_back, color: _getTextColor(Color(widget.category.color ?? 0xFF3E4A59))),
                onPressed: () => Get.back(),
              ),
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
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 11,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              
              return CatalogueCard(
                cardWithCategory: db.CardWithCategory(card, widget.category),
                categoryController: categoryController,
                langController: langController,
              );
            },
          );
        },
      ),
    );
  }
}
