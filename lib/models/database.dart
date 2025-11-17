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
  BoolColumn get isAsset => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Categories, Cards])
class AppDatabase extends _$AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  AppDatabase._internal() : super(_openConnection());

  @override
  int get schemaVersion => 3;

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
      },
    );
  }

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

      // Load generated_categories.json and add to the list
      // print('Loading generated_categories.json...');
      // final generatedCategoriesJson = await rootBundle.loadString('assets/data/generated_categories.json');
      // final List<dynamic> generatedCategoriesData = json.decode(generatedCategoriesJson);
      // categoriesData.addAll(generatedCategoriesData);
      // print('Total categories after adding generated data: ${categoriesData.length}');

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
              imagePath: const Value(null),
              color: Value(resolvedColor),
            ),
          );

          print('Inserted category: ${item['name']} | color: $resolvedColor');
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

      // Load generated_cards.json and add to the list
      // print('Loading generated_cards.json...');
      // final generatedCardsJson = await rootBundle.loadString('assets/data/generated_cards.json');
      // final Map<String, dynamic> generatedCardsMap = json.decode(generatedCardsJson);
      // final List<dynamic> generatedCardsData = generatedCardsMap['cards'];
      // cardsData.addAll(generatedCardsData);
      // print('Total cards after adding generated data: ${cardsData.length}');

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
                isAsset: const Value(true), // Assume true for all JSON data
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