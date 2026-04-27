import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get enName => text().nullable()();
  TextColumn get parentId => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get color => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get enName => text().nullable()();
  TextColumn get categoryId => text()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get soundPath => text().nullable()();
  TextColumn get enSoundPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isAsset => boolean().withDefault(const Constant(true))();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ========== TABLE BARU: SHORTCUTS ==========
class Shortcuts extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text()();  // Reference ke Cards table
  IntColumn get sortOrder => integer()();  // Urutan tampil
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();  // Default atau user-added
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();  // Aktif atau tidak
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Categories, Cards, Shortcuts])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 3) {
          await m.addColumn(cards, cards.isAsset);
        }
        if (from < 4) {
          await m.createTable(shortcuts);
        }
        if (from < 5) {
          await m.addColumn(cards, cards.usageCount);
        }
      },
    );
  }

  Future<void> initializeData() async {
    try {
      print('=== INITIALIZE DATA ===');

      // Load categories.json
      print('Loading categories.json...');
      final categoriesJson = await rootBundle.loadString('assets/data/categories.json');
      final List<dynamic> categoriesData = json.decode(categoriesJson);
      print('Categories loaded: ${categoriesData.length}');

      final Map<String, int?> colorCache = {};

      for (var item in categoriesData) {
        try {
          final existingCat = await (select(categories)
                ..where((tbl) => tbl.id.equals(item['id'])))
              .getSingleOrNull();

          if (existingCat != null) continue;

          // Ambil warna dari JSON
          final String? hexColor = item['defaultColor'];
          int? resolvedColor;

          if (hexColor != null) {
            resolvedColor = int.parse(hexColor.replaceFirst('#', '0xFF'));
          } else {
            final parentId = item['parent_id'];
            resolvedColor = colorCache[parentId];
          }

          colorCache[item['id']] = resolvedColor;

          await into(categories).insert(
            CategoriesCompanion.insert(
              id: item['id'],
              name: item['name'],
              enName: Value(item['enName']),
              parentId: Value(item['parent_id']),
              imagePath: Value(item['imagePath']),
              color: Value(resolvedColor),
            ),
          );

          print('Inserted category: ${item['name']} | color: $resolvedColor');
        } catch (e) {
          print('Error inserting category ${item['id']}: $e');
        }
      }

      // Load cards.json
      print('Loading cards.json...');
      final cardsJson = await rootBundle.loadString('assets/data/card.json');
      final Map<String, dynamic> cardsMap = json.decode(cardsJson);
      final List<dynamic> cardsData = cardsMap['cards'];
      print('Cards loaded: ${cardsData.length}');

      // Insert cards dengan cek duplikat
      for (var card in cardsData) {
        try {
          final existingCard = await (select(cards)
                ..where((tbl) => tbl.id.equals(card['id'])))
              .getSingleOrNull();

          if (existingCard == null) {
            await into(cards).insert(
              CardsCompanion.insert(
                id: card['id'],
                name: card['name'],
                enName: Value(card['enName']),
                categoryId: card['categoryId'],
                imagePath: Value(card['imagePath']),
                soundPath: Value(card['soundPath']),
                enSoundPath: Value(card['enSoundPath']),
                createdAt: DateTime.now(),
                isAsset: const Value(true),
              ),
            );
            print('Inserted card: ${card['name']}');
          }
        } catch (e) {
          print('Error inserting card ${card['id']}: $e');
        }
      }

      print('=== INITIALIZATION COMPLETE ===');

      // Seed / migrate the recommended shortcut set.
      await ensureRecommendedShortcuts();
      
      // Verifikasi data terinsert
      final finalCategories = await select(categories).get();
      final finalCards = await select(cards).get();
      final finalShortcuts = await select(shortcuts).get();
      print('Final categories count: ${finalCategories.length}');
      print('Final cards count: ${finalCards.length}');
      print('Final shortcuts count: ${finalShortcuts.length}');

    } catch (e) {
      print('ERROR in initializeData: $e');
      rethrow;
    }
  }

  // ========== SHORTCUT METHODS ==========

  // Bump this when the recommended list below changes — every install will
  // be migrated up to the new set on next launch (user-added shortcuts are
  // preserved; only defaults are replaced).
  static const int _kRecommendedShortcutsVersion = 2;
  static const String _kRecommendedShortcutsPrefKey =
      'shortcuts.recommendedVersion';

  /// High-utility AAC core vocabulary — the words a child will combine into
  /// almost every sentence. One row in the play screen's shortcut grid.
  static const List<String> recommendedShortcutCardIds = [
    'c320', // Saya  - I / Me
    'c275', // Mau   - Want
    'c193', // Makan - Eat
    'c165', // Minum - Drink
    'c175', // Tidur - Sleep
    'c299', // Senang - Happy
    'c284', // Sedih  - Sad
    'c354', // Selesai - Done
  ];

  /// Make sure the recommended set is present.
  /// - Fresh install: seeds them.
  /// - Existing install on an older recommended version: replaces the
  ///   default shortcuts (isDefault=true) with the current set, preserving
  ///   any user-added shortcuts.
  /// - `force: true` re-applies regardless of stored version (used by the
  ///   "Restore recommended" button in shortcut settings).
  Future<void> ensureRecommendedShortcuts({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final installed = prefs.getInt(_kRecommendedShortcutsPrefKey) ?? 0;
    if (!force && installed >= _kRecommendedShortcutsVersion) return;

    print('=== ENSURE RECOMMENDED SHORTCUTS (v$_kRecommendedShortcutsVersion, force=$force) ===');

    // Wipe old defaults; user-added shortcuts (isDefault=false) untouched.
    await (delete(shortcuts)..where((tbl) => tbl.isDefault.equals(true))).go();

    for (int i = 0; i < recommendedShortcutCardIds.length; i++) {
      final cardId = recommendedShortcutCardIds[i];
      final card = await (select(cards)
            ..where((tbl) => tbl.id.equals(cardId)))
          .getSingleOrNull();
      if (card == null) {
        print('Recommended card not in dataset: $cardId');
        continue;
      }

      // If the user already added this card themselves, leave it as theirs.
      final existing = await (select(shortcuts)
            ..where((tbl) => tbl.cardId.equals(cardId)))
          .getSingleOrNull();
      if (existing != null) continue;

      await into(shortcuts).insert(
        ShortcutsCompanion.insert(
          id: const Uuid().v4(),
          cardId: cardId,
          sortOrder: i,
          isDefault: const Value(true),
          isActive: const Value(true),
          createdAt: DateTime.now(),
        ),
      );
      print('Seeded recommended shortcut: ${card.name}');
    }

    // Re-number so defaults appear first in the play screen, then user picks.
    final all = await (select(shortcuts)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.isDefault,
                  mode: OrderingMode.desc,
                ),
            (t) => OrderingTerm(expression: t.sortOrder),
          ]))
        .get();
    for (int i = 0; i < all.length; i++) {
      await (update(shortcuts)..where((t) => t.id.equals(all[i].id)))
          .write(ShortcutsCompanion(sortOrder: Value(i)));
    }

    await prefs.setInt(
      _kRecommendedShortcutsPrefKey,
      _kRecommendedShortcutsVersion,
    );
    print('=== RECOMMENDED SHORTCUTS READY ===');
  }

  // Stream untuk watch active shortcuts dengan card data
Stream<List<ShortcutWithCard>> watchActiveShortcuts() {
  return (select(shortcuts).join([
    innerJoin(cards, cards.id.equalsExp(shortcuts.cardId)),
  ])
  ..where(shortcuts.isActive.equals(true))
  ..orderBy([OrderingTerm(expression: shortcuts.sortOrder)]))
  .watch()
  .map((rows) {
    return rows.map((row) {
      final shortcut = row.readTable(shortcuts);
      final card = row.readTable(cards);
      return ShortcutWithCard(shortcut, card);
    }).toList();
  });
}

// Get all shortcuts (untuk settings page)
Future<List<ShortcutWithCard>> getAllShortcuts() async {
  final rows = await (select(shortcuts).join([
    innerJoin(cards, cards.id.equalsExp(shortcuts.cardId)),
  ])
  ..orderBy([OrderingTerm(expression: shortcuts.sortOrder)]))
  .get();
  
  return rows.map((row) {
    final shortcut = row.readTable(shortcuts);
    final card = row.readTable(cards);
    return ShortcutWithCard(shortcut, card);
  }).toList();
}

  // Toggle shortcut active status
  Future<void> toggleShortcut(String shortcutId, bool isActive) async {
    await (update(shortcuts)..where((tbl) => tbl.id.equals(shortcutId)))
      .write(ShortcutsCompanion(isActive: Value(isActive)));
  }

  // Add new shortcut
  Future<void> addShortcut(String cardId) async {
    // Get max sort order
    final maxOrder = await (selectOnly(shortcuts)
      ..addColumns([shortcuts.sortOrder.max()]))
      .getSingleOrNull();
    
    final nextOrder = (maxOrder?.read(shortcuts.sortOrder.max()) ?? 0) + 1;

    await into(shortcuts).insert(
      ShortcutsCompanion.insert(
        id: const Uuid().v4(),
        cardId: cardId,
        sortOrder: nextOrder,
        isDefault: const Value(false),
        isActive: const Value(true),
        createdAt: DateTime.now(),
      ),
    );
  }

  // Remove shortcut (only if not default)
  Future<bool> removeShortcut(String shortcutId) async {
    final shortcut = await (select(shortcuts)
      ..where((tbl) => tbl.id.equals(shortcutId)))
      .getSingleOrNull();
    
    if (shortcut == null || shortcut.isDefault) {
      return false; // Cannot remove default shortcuts
    }

    await (delete(shortcuts)..where((tbl) => tbl.id.equals(shortcutId))).go();
    return true;
  }

  // Reorder shortcuts
  Future<void> reorderShortcuts(List<String> shortcutIds) async {
    for (int i = 0; i < shortcutIds.length; i++) {
      await (update(shortcuts)..where((tbl) => tbl.id.equals(shortcutIds[i])))
        .write(ShortcutsCompanion(sortOrder: Value(i)));
    }
  }

  // ========== EXISTING METHODS ==========

  // STREAM UNTUK RELASI CARD DAN CATEGORY
  Stream<List<CardWithCategory>> watchCardsWithCategories() {
    final query = select(cards).join([
      leftOuterJoin(categories, categories.id.equalsExp(cards.categoryId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return CardWithCategory(
          row.readTable(cards),
          row.readTableOrNull(categories),
        );
      }).toList();
    });
  }

  // Method untuk reset database (untuk testing)
  Future<void> resetDatabase() async {
    await delete(shortcuts).go();  // Tambah ini
    await delete(cards).go();
    await delete(categories).go();
    print('Database reset complete');
  }
}

// MODEL UNTUK RELASI CARD DAN CATEGORY
class CardWithCategory {
  final Card card;
  final Category? category;
  CardWithCategory(this.card, this.category);
}

// MODEL UNTUK SHORTCUT DENGAN CARD DATA
class ShortcutWithCard {
  final Shortcut shortcut;
  final Card card;
  
  ShortcutWithCard(this.shortcut, this.card);
}

// KONEKSI DATABASE
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}