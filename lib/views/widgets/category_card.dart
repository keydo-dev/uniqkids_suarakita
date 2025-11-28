
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/models/database.dart' as db;

class CategoryCard extends StatelessWidget {
  final db.Category category;
  final Color color;

  const CategoryCard({
    super.key,
    required this.category,
    required this.color,
  });

  // Helper function untuk menentukan warna text berdasarkan brightness background
  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

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
                  Get.locale?.languageCode == 'id' ? category.name : category.enName ?? category.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getTextColor(color),
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
