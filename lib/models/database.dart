import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Categories, Cards])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> initializeData() async {
    try {
      print('=== INITIALIZE DATA ===');

      // Tidak perlu cek existing data, kita akan insert data dari JSON
      // hanya jika ID-nya belum ada di database

      // 2. Load categories.json
      print('Loading categories.json...');
      final categoriesJson = await rootBundle.loadString('assets/data/categories.json');
      final List<dynamic> categoriesData = json.decode(categoriesJson);
      print('Categories loaded: ${categoriesData.length}');

      // 3. Warna default
      final List<int> defaultColors = [
        0xFFFF8A5B, // Orange
        0xFFFF6B6B, // Red
        0xFFFFC107, // Yellow
        0xFF64C5F2, // Light Blue
        0xFF5B8DEF, // Blue
        0xFF4ECB71, // Green
        0xFF6DB5C6, // Teal
        0xFF9C27B0, // Purple
        0xFFE91E63, // Pink
      ];

      final random = Random();

      // 4. Insert categories dengan cek duplikat
      for (var item in categoriesData) {
        try {
          final existingCat = await (select(categories)
                ..where((tbl) => tbl.id.equals(item['id'])))
              .getSingleOrNull();

          if (existingCat == null) {
            await into(categories).insert(
              CategoriesCompanion.insert(
                id: item['id'],
                name: item['name'],
                enName: Value(item['enName']),
                parentId: Value(item['parent_id']),
                imagePath: const Value(null),
                color: Value(defaultColors[random.nextInt(defaultColors.length)]),
              ),
            );
            print('Inserted category: ${item['name']}');
          }
        } catch (e) {
          print('Error inserting category ${item['id']}: $e');
        }
      }

      // 5. Load cards.json
      print('Loading cards.json...');
      final cardsJson = await rootBundle.loadString('assets/data/card.json');
      final Map<String, dynamic> cardsMap = json.decode(cardsJson);
      final List<dynamic> cardsData = cardsMap['cards'];
      print('Cards loaded: ${cardsData.length}');

      // 6. Insert cards dengan cek duplikat
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
              ),
            );
            print('Inserted card: ${card['name']}');
          }
        } catch (e) {
          print('Error inserting card ${card['id']}: $e');
        }
      }

      print('=== INITIALIZATION COMPLETE ===');
      
      // Verifikasi data terinsert
      final finalCategories = await select(categories).get();
      final finalCards = await select(cards).get();
      print('Final categories count: ${finalCategories.length}');
      print('Final cards count: ${finalCards.length}');

    } catch (e) {
      print('ERROR in initializeData: $e');
      rethrow;
    }
  }

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

// KONEKSI DATABASE
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}