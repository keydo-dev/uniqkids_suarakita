// lib/controllers/shortcut_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/models/database.dart';

class ShortcutController extends GetxController {
  final AppDatabase db;
  
  var shortcuts = <ShortcutWithCard>[].obs;
  var isLoading = false.obs;

  ShortcutController(this.db);

  @override
  void onInit() {
    super.onInit();
    loadShortcuts();
  }

  // Load all shortcuts untuk settings page
  Future<void> loadShortcuts() async {
    try {
      isLoading.value = true;
      final allShortcuts = await db.getAllShortcuts();
      shortcuts.assignAll(allShortcuts);
    } catch (e) {
      print('Error loading shortcuts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Stream untuk active shortcuts (untuk PlayScreen)
  Stream<List<ShortcutWithCard>> watchActiveShortcuts() {
    return db.watchActiveShortcuts();
  }

  // Toggle shortcut on/off
  Future<void> toggleShortcut(String shortcutId, bool isActive) async {
    try {
      await db.toggleShortcut(shortcutId, isActive);
      await loadShortcuts(); // Reload
      
      Get.snackbar(
        'Success',
        isActive ? 'Shortcut activated' : 'Shortcut deactivated',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white
      );
    } catch (e) {
      print('Error toggling shortcut: $e');
      Get.snackbar(
        'Error',
        'Failed to toggle shortcut',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white
      );
    }
  }

  // Add card to shortcuts
  Future<void> addShortcut(String cardId) async {
    try {
      // Check if card already in shortcuts
      final existing = shortcuts.firstWhereOrNull(
        (s) => s.shortcut.cardId == cardId
      );
      
      if (existing != null) {
        // If exists but inactive, activate it
        if (!existing.shortcut.isActive) {
          await toggleShortcut(existing.shortcut.id, true);
        } else {
          Get.snackbar(
            'Info',
            'Card already in shortcuts',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.white
          );
        }
        return;
      }

      await db.addShortcut(cardId);
      await loadShortcuts();
      
      Get.snackbar(
        'Success',
        'Added to shortcuts',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white
      );
    } catch (e) {
      print('Error adding shortcut: $e');
      Get.snackbar(
        'Error',
        'Failed to add shortcut',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white
      );
    }
  }

  // Remove shortcut (only non-default)
  Future<void> removeShortcut(String shortcutId) async {
    try {
      final success = await db.removeShortcut(shortcutId);
      
      if (success) {
        await loadShortcuts();
        Get.snackbar(
          'Success',
          'Shortcut removed',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white
        );
      } else {
        Get.snackbar(
          'Info',
          'Cannot remove default shortcuts',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white
        );
      }
    } catch (e) {
      print('Error removing shortcut: $e');
      Get.snackbar(
        'Error',
        'Failed to remove shortcut',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white
      );
    }
  }

  // Reorder shortcuts (untuk drag & drop)
  Future<void> reorderShortcuts(int oldIndex, int newIndex) async {
    try {
      if (newIndex > oldIndex) newIndex--;
      
      // Update local list
      final item = shortcuts.removeAt(oldIndex);
      shortcuts.insert(newIndex, item);
      
      // Update database
      final shortcutIds = shortcuts.map((s) => s.shortcut.id).toList();
      await db.reorderShortcuts(shortcutIds);
      
    } catch (e) {
      print('Error reordering shortcuts: $e');
      await loadShortcuts(); // Reload on error
    }
  }

  // Check if card is already in shortcuts
  bool isInShortcuts(String cardId) {
    return shortcuts.any((s) => 
      s.shortcut.cardId == cardId && s.shortcut.isActive
    );
  }

  // Get active shortcuts count
  int get activeShortcutsCount {
    return shortcuts.where((s) => s.shortcut.isActive).length;
  }

  // Get default shortcuts count
  int get defaultShortcutsCount {
    return shortcuts.where((s) => s.shortcut.isDefault).length;
  }

  // Get user-added shortcuts count
  int get userShortcutsCount {
    return shortcuts.where((s) => !s.shortcut.isDefault).length;
  }
}