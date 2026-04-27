import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:SuaraKita/const.dart';
import 'package:SuaraKita/controllers/shortcut_controller.dart';
import 'package:SuaraKita/controllers/languages_controller.dart';
import 'package:SuaraKita/models/database.dart' as database;

class ShortcutSettingsScreen extends StatelessWidget {
  const ShortcutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcutController = Get.find<ShortcutController>();
    final langController = Get.find<LanguagesController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: btnPrimaryColor,
        title: Text(
          langController.currentLanguage.value == 'en'
              ? 'Manage Shortcuts'
              : 'Kelola Pintasan',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt, color: Colors.white),
            tooltip: 'shortcuts_restore_recommended'.tr,
            onPressed: () => _confirmRestoreRecommended(shortcutController),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Obx(() => _buildStatCard(
                  icon: Icons.star,
                  label: langController.currentLanguage.value == 'en'
                      ? 'Active'
                      : 'Aktif',
                  value: '${shortcutController.activeShortcutsCount}',
                  color: Colors.amber,
                )),
                Obx(() => _buildStatCard(
                  icon: Icons.stars,
                  label: langController.currentLanguage.value == 'en'
                      ? 'Default'
                      : 'Bawaan',
                  value: '${shortcutController.defaultShortcutsCount}',
                  color: Colors.blue,
                )),
                Obx(() => _buildStatCard(
                  icon: Icons.person,
                  label: langController.currentLanguage.value == 'en'
                      ? 'Custom'
                      : 'Kustom',
                  value: '${shortcutController.userShortcutsCount}',
                  color: Colors.green,
                )),
              ],
            ),
          ),
          const Divider(thickness: 2),
          Expanded(
            child: Obx(() {
              if (shortcutController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (shortcutController.shortcuts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        langController.currentLanguage.value == 'en'
                            ? 'No shortcuts yet'
                            : 'Belum ada pintasan',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ReorderableListView.builder(
                onReorder: shortcutController.reorderShortcuts,
                itemCount: shortcutController.shortcuts.length,
                itemBuilder: (context, index) {
                  final item = shortcutController.shortcuts[index];
                  return _buildShortcutItem(
                    key: ValueKey(item.shortcut.id),
                    item: item,
                    shortcutController: shortcutController,
                    langController: langController,
                  );
                },
              );
            }),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).toInt()),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddShortcutDialog(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  langController.currentLanguage.value == 'en'
                      ? 'Add Shortcut'
                      : 'Tambah Pintasan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutItem({
    required Key key,
    required database.ShortcutWithCard item,
    required ShortcutController shortcutController,
    required LanguagesController langController,
  }) {
    final card = item.card;
    final shortcut = item.shortcut;
    final cardName = langController.currentLanguage.value == 'en'
        ? card.enName ?? card.name
        : card.name;

    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_handle, color: Colors.grey),
            const SizedBox(width: 8),
            if (shortcut.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEFAULT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          cardName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: shortcut.isActive
                ? TextDecoration.none
                : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          langController.currentLanguage.value == 'en'
              ? 'Order: ${shortcut.sortOrder}'
              : 'Urutan: ${shortcut.sortOrder}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: shortcut.isActive,
              onChanged: (value) {
                shortcutController.toggleShortcut(shortcut.id, value);
              },
              activeColor: Colors.deepOrangeAccent,
            ),
            const SizedBox(width: 8),
            if (!shortcut.isDefault)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(
                  Get.context!,
                  shortcut.id,
                  cardName,
                  shortcutController,
                  langController,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String shortcutId,
    String cardName,
    ShortcutController shortcutController,
    LanguagesController langController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          langController.currentLanguage.value == 'en'
              ? 'Remove Shortcut?'
              : 'Hapus Pintasan?',
        ),
        content: Text(
          langController.currentLanguage.value == 'en'
              ? 'Remove "$cardName" from shortcuts?'
              : 'Hapus "$cardName" dari pintasan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              langController.currentLanguage.value == 'en'
                  ? 'Cancel'
                  : 'Batal',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              shortcutController.removeShortcut(shortcutId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              langController.currentLanguage.value == 'en'
                  ? 'Remove'
                  : 'Hapus',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRestoreRecommended(ShortcutController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('shortcuts_restore_confirm_title'.tr),
        content: Text('shortcuts_restore_confirm_body'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('edit_cancel'.tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: btnPrimaryColor),
            onPressed: () async {
              Get.back();
              await controller.resetToRecommended();
            },
            child: Text(
              'shortcuts_restore_confirm_action'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddShortcutDialog(BuildContext context) {
    final shortcutController = Get.find<ShortcutController>();
    final langController = Get.find<LanguagesController>();
    final db = Get.find<database.AppDatabase>();
    
    final searchController = TextEditingController();
    final searchQuery = ''.obs;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 10,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(12),
          color: Color(0xFFEEFEFF),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      langController.currentLanguage.value == 'en'
                          ? 'Add Shortcut'
                          : 'Tambah Pintasan',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              TextField(
                controller: searchController,
                onChanged: (value) => searchQuery.value = value.toLowerCase(),
                decoration: InputDecoration(
                  hintText: langController.currentLanguage.value == 'en'
                      ? 'Search cards...'
                      : 'Cari kartu...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(() => searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
                          },
                        )
                      : const SizedBox.shrink()),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<database.CardWithCategory>>(
                  stream: db.watchCardsWithCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allCards = snapshot.data!;
                    
                    return Obx(() {
                      final filteredCards = searchQuery.value.isEmpty
                          ? allCards
                          : allCards.where((cardWithCat) {
                              final card = cardWithCat.card;
                              final cardName = langController.currentLanguage.value == 'en'
                                  ? card.enName ?? card.name
                                  : card.name;
                              final categoryName = cardWithCat.category?.name ?? '';
                              
                              return cardName.toLowerCase().contains(searchQuery.value) ||
                                     categoryName.toLowerCase().contains(searchQuery.value);
                            }).toList();

                      if (filteredCards.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                langController.currentLanguage.value == 'en'
                                    ? 'No cards found'
                                    : 'Kartu tidak ditemukan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: filteredCards.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final cardWithCat = filteredCards[index];
                          final card = cardWithCat.card;
                          final cardName = langController.currentLanguage.value == 'en'
                              ? card.enName ?? card.name
                              : card.name;
                          
                          final isInShortcuts = shortcutController.isInShortcuts(card.id);

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isInShortcuts 
                                    ? Colors.green.shade50 
                                    : Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isInShortcuts ? Icons.check_circle : Icons.add_circle_outline,
                                color: isInShortcuts ? Colors.green : Colors.blue,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              cardName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isInShortcuts ? Colors.grey : Colors.black,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(
                                  Icons.folder,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  cardWithCat.category?.name ?? 'No category',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: isInShortcuts
                                ? Chip(
                                    label: Text(
                                      langController.currentLanguage.value == 'en'
                                          ? 'Added'
                                          : 'Ditambah',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.zero,
                                  )
                                : null,
                            enabled: !isInShortcuts,
                            onTap: isInShortcuts
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    shortcutController.addShortcut(card.id);
                                  },
                          );
                        },
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: Text(
                    langController.currentLanguage.value == 'en'
                        ? 'Close'
                        : 'Tutup',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}