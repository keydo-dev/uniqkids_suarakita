// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enNameMeta = const VerificationMeta('enName');
  @override
  late final GeneratedColumn<String> enName = GeneratedColumn<String>(
    'en_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    enName,
    parentId,
    level,
    imagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('en_name')) {
      context.handle(
        _enNameMeta,
        enName.isAcceptableOrUnknown(data['en_name']!, _enNameMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      enName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}en_name'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;
  final String? enName;
  final String? parentId;
  final int level;
  final String? imagePath;
  const Category({
    required this.id,
    required this.name,
    this.enName,
    this.parentId,
    required this.level,
    this.imagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || enName != null) {
      map['en_name'] = Variable<String>(enName);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['level'] = Variable<int>(level);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      enName: enName == null && nullToAbsent
          ? const Value.absent()
          : Value(enName),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      level: Value(level),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      enName: serializer.fromJson<String?>(json['enName']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      level: serializer.fromJson<int>(json['level']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'enName': serializer.toJson<String?>(enName),
      'parentId': serializer.toJson<String?>(parentId),
      'level': serializer.toJson<int>(level),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    Value<String?> enName = const Value.absent(),
    Value<String?> parentId = const Value.absent(),
    int? level,
    Value<String?> imagePath = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    enName: enName.present ? enName.value : this.enName,
    parentId: parentId.present ? parentId.value : this.parentId,
    level: level ?? this.level,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      enName: data.enName.present ? data.enName.value : this.enName,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      level: data.level.present ? data.level.value : this.level,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enName: $enName, ')
          ..write('parentId: $parentId, ')
          ..write('level: $level, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, enName, parentId, level, imagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.enName == this.enName &&
          other.parentId == this.parentId &&
          other.level == this.level &&
          other.imagePath == this.imagePath);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> enName;
  final Value<String?> parentId;
  final Value<int> level;
  final Value<String?> imagePath;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.enName = const Value.absent(),
    this.parentId = const Value.absent(),
    this.level = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.enName = const Value.absent(),
    this.parentId = const Value.absent(),
    required int level,
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       level = Value(level);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? enName,
    Expression<String>? parentId,
    Expression<int>? level,
    Expression<String>? imagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (enName != null) 'en_name': enName,
      if (parentId != null) 'parent_id': parentId,
      if (level != null) 'level': level,
      if (imagePath != null) 'image_path': imagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? enName,
    Value<String?>? parentId,
    Value<int>? level,
    Value<String?>? imagePath,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      enName: enName ?? this.enName,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      imagePath: imagePath ?? this.imagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (enName.present) {
      map['en_name'] = Variable<String>(enName.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enName: $enName, ')
          ..write('parentId: $parentId, ')
          ..write('level: $level, ')
          ..write('imagePath: $imagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, Card> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enNameMeta = const VerificationMeta('enName');
  @override
  late final GeneratedColumn<String> enName = GeneratedColumn<String>(
    'en_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _soundPathMeta = const VerificationMeta(
    'soundPath',
  );
  @override
  late final GeneratedColumn<String> soundPath = GeneratedColumn<String>(
    'sound_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enSoundPathMeta = const VerificationMeta(
    'enSoundPath',
  );
  @override
  late final GeneratedColumn<String> enSoundPath = GeneratedColumn<String>(
    'en_sound_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    enName,
    categoryId,
    imagePath,
    soundPath,
    enSoundPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Card> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('en_name')) {
      context.handle(
        _enNameMeta,
        enName.isAcceptableOrUnknown(data['en_name']!, _enNameMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('sound_path')) {
      context.handle(
        _soundPathMeta,
        soundPath.isAcceptableOrUnknown(data['sound_path']!, _soundPathMeta),
      );
    }
    if (data.containsKey('en_sound_path')) {
      context.handle(
        _enSoundPathMeta,
        enSoundPath.isAcceptableOrUnknown(
          data['en_sound_path']!,
          _enSoundPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Card map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Card(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      enName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}en_name'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      soundPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_path'],
      ),
      enSoundPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}en_sound_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class Card extends DataClass implements Insertable<Card> {
  final String id;
  final String name;
  final String? enName;
  final String categoryId;
  final String? imagePath;
  final String? soundPath;
  final String? enSoundPath;
  final DateTime createdAt;
  const Card({
    required this.id,
    required this.name,
    this.enName,
    required this.categoryId,
    this.imagePath,
    this.soundPath,
    this.enSoundPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || enName != null) {
      map['en_name'] = Variable<String>(enName);
    }
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || soundPath != null) {
      map['sound_path'] = Variable<String>(soundPath);
    }
    if (!nullToAbsent || enSoundPath != null) {
      map['en_sound_path'] = Variable<String>(enSoundPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      name: Value(name),
      enName: enName == null && nullToAbsent
          ? const Value.absent()
          : Value(enName),
      categoryId: Value(categoryId),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      soundPath: soundPath == null && nullToAbsent
          ? const Value.absent()
          : Value(soundPath),
      enSoundPath: enSoundPath == null && nullToAbsent
          ? const Value.absent()
          : Value(enSoundPath),
      createdAt: Value(createdAt),
    );
  }

  factory Card.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Card(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      enName: serializer.fromJson<String?>(json['enName']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      soundPath: serializer.fromJson<String?>(json['soundPath']),
      enSoundPath: serializer.fromJson<String?>(json['enSoundPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'enName': serializer.toJson<String?>(enName),
      'categoryId': serializer.toJson<String>(categoryId),
      'imagePath': serializer.toJson<String?>(imagePath),
      'soundPath': serializer.toJson<String?>(soundPath),
      'enSoundPath': serializer.toJson<String?>(enSoundPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Card copyWith({
    String? id,
    String? name,
    Value<String?> enName = const Value.absent(),
    String? categoryId,
    Value<String?> imagePath = const Value.absent(),
    Value<String?> soundPath = const Value.absent(),
    Value<String?> enSoundPath = const Value.absent(),
    DateTime? createdAt,
  }) => Card(
    id: id ?? this.id,
    name: name ?? this.name,
    enName: enName.present ? enName.value : this.enName,
    categoryId: categoryId ?? this.categoryId,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    soundPath: soundPath.present ? soundPath.value : this.soundPath,
    enSoundPath: enSoundPath.present ? enSoundPath.value : this.enSoundPath,
    createdAt: createdAt ?? this.createdAt,
  );
  Card copyWithCompanion(CardsCompanion data) {
    return Card(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      enName: data.enName.present ? data.enName.value : this.enName,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      soundPath: data.soundPath.present ? data.soundPath.value : this.soundPath,
      enSoundPath: data.enSoundPath.present
          ? data.enSoundPath.value
          : this.enSoundPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Card(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enName: $enName, ')
          ..write('categoryId: $categoryId, ')
          ..write('imagePath: $imagePath, ')
          ..write('soundPath: $soundPath, ')
          ..write('enSoundPath: $enSoundPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    enName,
    categoryId,
    imagePath,
    soundPath,
    enSoundPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card &&
          other.id == this.id &&
          other.name == this.name &&
          other.enName == this.enName &&
          other.categoryId == this.categoryId &&
          other.imagePath == this.imagePath &&
          other.soundPath == this.soundPath &&
          other.enSoundPath == this.enSoundPath &&
          other.createdAt == this.createdAt);
}

class CardsCompanion extends UpdateCompanion<Card> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> enName;
  final Value<String> categoryId;
  final Value<String?> imagePath;
  final Value<String?> soundPath;
  final Value<String?> enSoundPath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.enName = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.soundPath = const Value.absent(),
    this.enSoundPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    required String name,
    this.enName = const Value.absent(),
    required String categoryId,
    this.imagePath = const Value.absent(),
    this.soundPath = const Value.absent(),
    this.enSoundPath = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       categoryId = Value(categoryId),
       createdAt = Value(createdAt);
  static Insertable<Card> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? enName,
    Expression<String>? categoryId,
    Expression<String>? imagePath,
    Expression<String>? soundPath,
    Expression<String>? enSoundPath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (enName != null) 'en_name': enName,
      if (categoryId != null) 'category_id': categoryId,
      if (imagePath != null) 'image_path': imagePath,
      if (soundPath != null) 'sound_path': soundPath,
      if (enSoundPath != null) 'en_sound_path': enSoundPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? enName,
    Value<String>? categoryId,
    Value<String?>? imagePath,
    Value<String?>? soundPath,
    Value<String?>? enSoundPath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      enName: enName ?? this.enName,
      categoryId: categoryId ?? this.categoryId,
      imagePath: imagePath ?? this.imagePath,
      soundPath: soundPath ?? this.soundPath,
      enSoundPath: enSoundPath ?? this.enSoundPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (enName.present) {
      map['en_name'] = Variable<String>(enName.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (soundPath.present) {
      map['sound_path'] = Variable<String>(soundPath.value);
    }
    if (enSoundPath.present) {
      map['en_sound_path'] = Variable<String>(enSoundPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('enName: $enName, ')
          ..write('categoryId: $categoryId, ')
          ..write('imagePath: $imagePath, ')
          ..write('soundPath: $soundPath, ')
          ..write('enSoundPath: $enSoundPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CardsTable cards = $CardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [categories, cards];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      Value<String?> enName,
      Value<String?> parentId,
      required int level,
      Value<String?> imagePath,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> enName,
      Value<String?> parentId,
      Value<int> level,
      Value<String?> imagePath,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enName => $composableBuilder(
    column: $table.enName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enName => $composableBuilder(
    column: $table.enName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get enName =>
      $composableBuilder(column: $table.enName, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> enName = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                enName: enName,
                parentId: parentId,
                level: level,
                imagePath: imagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> enName = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                required int level,
                Value<String?> imagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                enName: enName,
                parentId: parentId,
                level: level,
                imagePath: imagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$CardsTableCreateCompanionBuilder =
    CardsCompanion Function({
      required String id,
      required String name,
      Value<String?> enName,
      required String categoryId,
      Value<String?> imagePath,
      Value<String?> soundPath,
      Value<String?> enSoundPath,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CardsTableUpdateCompanionBuilder =
    CardsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> enName,
      Value<String> categoryId,
      Value<String?> imagePath,
      Value<String?> soundPath,
      Value<String?> enSoundPath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enName => $composableBuilder(
    column: $table.enName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundPath => $composableBuilder(
    column: $table.soundPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enSoundPath => $composableBuilder(
    column: $table.enSoundPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enName => $composableBuilder(
    column: $table.enName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundPath => $composableBuilder(
    column: $table.soundPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enSoundPath => $composableBuilder(
    column: $table.enSoundPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get enName =>
      $composableBuilder(column: $table.enName, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get soundPath =>
      $composableBuilder(column: $table.soundPath, builder: (column) => column);

  GeneratedColumn<String> get enSoundPath => $composableBuilder(
    column: $table.enSoundPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          Card,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (Card, BaseReferences<_$AppDatabase, $CardsTable, Card>),
          Card,
          PrefetchHooks Function()
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> enName = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> soundPath = const Value.absent(),
                Value<String?> enSoundPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                name: name,
                enName: enName,
                categoryId: categoryId,
                imagePath: imagePath,
                soundPath: soundPath,
                enSoundPath: enSoundPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> enName = const Value.absent(),
                required String categoryId,
                Value<String?> imagePath = const Value.absent(),
                Value<String?> soundPath = const Value.absent(),
                Value<String?> enSoundPath = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                name: name,
                enName: enName,
                categoryId: categoryId,
                imagePath: imagePath,
                soundPath: soundPath,
                enSoundPath: enSoundPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      Card,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (Card, BaseReferences<_$AppDatabase, $CardsTable, Card>),
      Card,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
}
