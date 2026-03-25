import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/controllers/category_controller.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import 'package:SuaraKita/models/database.dart' as db;
import 'package:SuaraKita/services/audio_services.dart';
import 'package:SuaraKita/utils/asset_helper.dart';

class CatalogueCard extends StatelessWidget {
  final db.CardWithCategory cardWithCategory;
  final CategoryController categoryController;
  final LanguagesController langController;
  final AudioService audioService = Get.find<AudioService>();

  CatalogueCard({
    super.key,
    required this.cardWithCategory,
    required this.categoryController,
    required this.langController,
  });

  @override
  Widget build(BuildContext context) {
    final card = cardWithCategory.card;
    final category = cardWithCategory.category;
    
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

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasImage) ...[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder<String>(
                        future: AssetHelper.getImage(card.imagePath),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  langController.currentLanguage.value == 'en'
                                      ? card.enName ?? card.name
                                      : card.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }
                          
                          final imagePath = snapshot.data!;
                          return imagePath.startsWith('assets/')
                              ? Image.asset(imagePath, fit: BoxFit.contain)
                              : Image.file(File(imagePath), fit: BoxFit.contain);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                    child: Text(
                      langController.currentLanguage.value == 'en'
                          ? card.enName ?? card.name
                          : card.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]
                else ...[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        langController.currentLanguage.value == 'en'
                            ? card.enName ?? card.name
                            : card.name,
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
                ],
              ],
            ),
          ),
          
          // Audio button
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () async {
              final soundPath = await AssetHelper.getSound(
                langController.currentLanguage.value == 'en'
                    ? card.enSoundPath
                    : card.soundPath,
              );
              audioService.playFile(soundPath);
            },
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
  }
}