import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get enName => text().nullable()();
  TextColumn get parentId => text().nullable()();
  IntColumn get level => integer()();
  TextColumn get imagePath => text().nullable()();

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

    factory AppDatabase() {
      return _instance;
    }

  AppDatabase._internal() : super(_openConnection());

    @override
    int get schemaVersion => 1;

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
}

  class CardWithCategory {
  final Card card;
  final Category? category;
  CardWithCategory(this.card, this.category);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // dapatkan folder aplikasi yang writable
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database.sqlite'));
    return NativeDatabase(file);
  });
}