// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalRecipesTable extends LocalRecipes
    with TableInfo<$LocalRecipesTable, LocalRecipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prepTimeMeta = const VerificationMeta(
    'prepTime',
  );
  @override
  late final GeneratedColumn<int> prepTime = GeneratedColumn<int>(
    'prep_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cookTimeMeta = const VerificationMeta(
    'cookTime',
  );
  @override
  late final GeneratedColumn<int> cookTime = GeneratedColumn<int>(
    'cook_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPublicMeta = const VerificationMeta(
    'isPublic',
  );
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
    'is_public',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_public" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipsMeta = const VerificationMeta('tips');
  @override
  late final GeneratedColumn<String> tips = GeneratedColumn<String>(
    'tips',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _forkedFromIdMeta = const VerificationMeta(
    'forkedFromId',
  );
  @override
  late final GeneratedColumn<String> forkedFromId = GeneratedColumn<String>(
    'forked_from_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    photoUrl,
    servings,
    prepTime,
    cookTime,
    tagsJson,
    isPublic,
    createdAt,
    updatedAt,
    tips,
    forkedFromId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRecipe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    } else if (isInserting) {
      context.missing(_servingsMeta);
    }
    if (data.containsKey('prep_time')) {
      context.handle(
        _prepTimeMeta,
        prepTime.isAcceptableOrUnknown(data['prep_time']!, _prepTimeMeta),
      );
    }
    if (data.containsKey('cook_time')) {
      context.handle(
        _cookTimeMeta,
        cookTime.isAcceptableOrUnknown(data['cook_time']!, _cookTimeMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_tagsJsonMeta);
    }
    if (data.containsKey('is_public')) {
      context.handle(
        _isPublicMeta,
        isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('tips')) {
      context.handle(
        _tipsMeta,
        tips.isAcceptableOrUnknown(data['tips']!, _tipsMeta),
      );
    }
    if (data.containsKey('forked_from_id')) {
      context.handle(
        _forkedFromIdMeta,
        forkedFromId.isAcceptableOrUnknown(
          data['forked_from_id']!,
          _forkedFromIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRecipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRecipe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}servings'],
      )!,
      prepTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prep_time'],
      ),
      cookTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cook_time'],
      ),
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      isPublic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_public'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      tips: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tips'],
      ),
      forkedFromId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forked_from_id'],
      ),
    );
  }

  @override
  $LocalRecipesTable createAlias(String alias) {
    return $LocalRecipesTable(attachedDatabase, alias);
  }
}

class LocalRecipe extends DataClass implements Insertable<LocalRecipe> {
  final String id;
  final String userId;
  final String title;
  final String? photoUrl;
  final int servings;
  final int? prepTime;
  final int? cookTime;
  final String tagsJson;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? tips;
  final String? forkedFromId;
  const LocalRecipe({
    required this.id,
    required this.userId,
    required this.title,
    this.photoUrl,
    required this.servings,
    this.prepTime,
    this.cookTime,
    required this.tagsJson,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.tips,
    this.forkedFromId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    map['servings'] = Variable<int>(servings);
    if (!nullToAbsent || prepTime != null) {
      map['prep_time'] = Variable<int>(prepTime);
    }
    if (!nullToAbsent || cookTime != null) {
      map['cook_time'] = Variable<int>(cookTime);
    }
    map['tags_json'] = Variable<String>(tagsJson);
    map['is_public'] = Variable<bool>(isPublic);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || tips != null) {
      map['tips'] = Variable<String>(tips);
    }
    if (!nullToAbsent || forkedFromId != null) {
      map['forked_from_id'] = Variable<String>(forkedFromId);
    }
    return map;
  }

  LocalRecipesCompanion toCompanion(bool nullToAbsent) {
    return LocalRecipesCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      servings: Value(servings),
      prepTime: prepTime == null && nullToAbsent
          ? const Value.absent()
          : Value(prepTime),
      cookTime: cookTime == null && nullToAbsent
          ? const Value.absent()
          : Value(cookTime),
      tagsJson: Value(tagsJson),
      isPublic: Value(isPublic),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tips: tips == null && nullToAbsent ? const Value.absent() : Value(tips),
      forkedFromId: forkedFromId == null && nullToAbsent
          ? const Value.absent()
          : Value(forkedFromId),
    );
  }

  factory LocalRecipe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRecipe(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      servings: serializer.fromJson<int>(json['servings']),
      prepTime: serializer.fromJson<int?>(json['prepTime']),
      cookTime: serializer.fromJson<int?>(json['cookTime']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      tips: serializer.fromJson<String?>(json['tips']),
      forkedFromId: serializer.fromJson<String?>(json['forkedFromId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'servings': serializer.toJson<int>(servings),
      'prepTime': serializer.toJson<int?>(prepTime),
      'cookTime': serializer.toJson<int?>(cookTime),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'isPublic': serializer.toJson<bool>(isPublic),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'tips': serializer.toJson<String?>(tips),
      'forkedFromId': serializer.toJson<String?>(forkedFromId),
    };
  }

  LocalRecipe copyWith({
    String? id,
    String? userId,
    String? title,
    Value<String?> photoUrl = const Value.absent(),
    int? servings,
    Value<int?> prepTime = const Value.absent(),
    Value<int?> cookTime = const Value.absent(),
    String? tagsJson,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> tips = const Value.absent(),
    Value<String?> forkedFromId = const Value.absent(),
  }) => LocalRecipe(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    servings: servings ?? this.servings,
    prepTime: prepTime.present ? prepTime.value : this.prepTime,
    cookTime: cookTime.present ? cookTime.value : this.cookTime,
    tagsJson: tagsJson ?? this.tagsJson,
    isPublic: isPublic ?? this.isPublic,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tips: tips.present ? tips.value : this.tips,
    forkedFromId: forkedFromId.present ? forkedFromId.value : this.forkedFromId,
  );
  LocalRecipe copyWithCompanion(LocalRecipesCompanion data) {
    return LocalRecipe(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      servings: data.servings.present ? data.servings.value : this.servings,
      prepTime: data.prepTime.present ? data.prepTime.value : this.prepTime,
      cookTime: data.cookTime.present ? data.cookTime.value : this.cookTime,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tips: data.tips.present ? data.tips.value : this.tips,
      forkedFromId: data.forkedFromId.present
          ? data.forkedFromId.value
          : this.forkedFromId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecipe(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('servings: $servings, ')
          ..write('prepTime: $prepTime, ')
          ..write('cookTime: $cookTime, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('isPublic: $isPublic, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tips: $tips, ')
          ..write('forkedFromId: $forkedFromId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    photoUrl,
    servings,
    prepTime,
    cookTime,
    tagsJson,
    isPublic,
    createdAt,
    updatedAt,
    tips,
    forkedFromId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRecipe &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.photoUrl == this.photoUrl &&
          other.servings == this.servings &&
          other.prepTime == this.prepTime &&
          other.cookTime == this.cookTime &&
          other.tagsJson == this.tagsJson &&
          other.isPublic == this.isPublic &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tips == this.tips &&
          other.forkedFromId == this.forkedFromId);
}

class LocalRecipesCompanion extends UpdateCompanion<LocalRecipe> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> photoUrl;
  final Value<int> servings;
  final Value<int?> prepTime;
  final Value<int?> cookTime;
  final Value<String> tagsJson;
  final Value<bool> isPublic;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> tips;
  final Value<String?> forkedFromId;
  final Value<int> rowid;
  const LocalRecipesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.servings = const Value.absent(),
    this.prepTime = const Value.absent(),
    this.cookTime = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tips = const Value.absent(),
    this.forkedFromId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRecipesCompanion.insert({
    required String id,
    required String userId,
    required String title,
    this.photoUrl = const Value.absent(),
    required int servings,
    this.prepTime = const Value.absent(),
    this.cookTime = const Value.absent(),
    required String tagsJson,
    this.isPublic = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.tips = const Value.absent(),
    this.forkedFromId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       servings = Value(servings),
       tagsJson = Value(tagsJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocalRecipe> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? photoUrl,
    Expression<int>? servings,
    Expression<int>? prepTime,
    Expression<int>? cookTime,
    Expression<String>? tagsJson,
    Expression<bool>? isPublic,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? tips,
    Expression<String>? forkedFromId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (servings != null) 'servings': servings,
      if (prepTime != null) 'prep_time': prepTime,
      if (cookTime != null) 'cook_time': cookTime,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (isPublic != null) 'is_public': isPublic,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tips != null) 'tips': tips,
      if (forkedFromId != null) 'forked_from_id': forkedFromId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRecipesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String?>? photoUrl,
    Value<int>? servings,
    Value<int?>? prepTime,
    Value<int?>? cookTime,
    Value<String>? tagsJson,
    Value<bool>? isPublic,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? tips,
    Value<String?>? forkedFromId,
    Value<int>? rowid,
  }) {
    return LocalRecipesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      photoUrl: photoUrl ?? this.photoUrl,
      servings: servings ?? this.servings,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      tagsJson: tagsJson ?? this.tagsJson,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tips: tips ?? this.tips,
      forkedFromId: forkedFromId ?? this.forkedFromId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (prepTime.present) {
      map['prep_time'] = Variable<int>(prepTime.value);
    }
    if (cookTime.present) {
      map['cook_time'] = Variable<int>(cookTime.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (tips.present) {
      map['tips'] = Variable<String>(tips.value);
    }
    if (forkedFromId.present) {
      map['forked_from_id'] = Variable<String>(forkedFromId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecipesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('servings: $servings, ')
          ..write('prepTime: $prepTime, ')
          ..write('cookTime: $cookTime, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('isPublic: $isPublic, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tips: $tips, ')
          ..write('forkedFromId: $forkedFromId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalIngredientsTable extends LocalIngredients
    with TableInfo<$LocalIngredientsTable, LocalIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
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
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOptionalMeta = const VerificationMeta(
    'isOptional',
  );
  @override
  late final GeneratedColumn<bool> isOptional = GeneratedColumn<bool>(
    'is_optional',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_optional" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isIncludedMeta = const VerificationMeta(
    'isIncluded',
  );
  @override
  late final GeneratedColumn<bool> isIncluded = GeneratedColumn<bool>(
    'is_included',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_included" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isToTasteMeta = const VerificationMeta(
    'isToTaste',
  );
  @override
  late final GeneratedColumn<bool> isToTaste = GeneratedColumn<bool>(
    'is_to_taste',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_to_taste" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    name,
    quantity,
    unit,
    category,
    position,
    isOptional,
    isIncluded,
    isToTaste,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('is_optional')) {
      context.handle(
        _isOptionalMeta,
        isOptional.isAcceptableOrUnknown(data['is_optional']!, _isOptionalMeta),
      );
    }
    if (data.containsKey('is_included')) {
      context.handle(
        _isIncludedMeta,
        isIncluded.isAcceptableOrUnknown(data['is_included']!, _isIncludedMeta),
      );
    }
    if (data.containsKey('is_to_taste')) {
      context.handle(
        _isToTasteMeta,
        isToTaste.isAcceptableOrUnknown(data['is_to_taste']!, _isToTasteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalIngredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      isOptional: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_optional'],
      )!,
      isIncluded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_included'],
      )!,
      isToTaste: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_to_taste'],
      )!,
    );
  }

  @override
  $LocalIngredientsTable createAlias(String alias) {
    return $LocalIngredientsTable(attachedDatabase, alias);
  }
}

class LocalIngredient extends DataClass implements Insertable<LocalIngredient> {
  final String id;
  final String recipeId;
  final String name;
  final double? quantity;
  final String? unit;
  final String? category;
  final int position;
  final bool isOptional;
  final bool isIncluded;
  final bool isToTaste;
  const LocalIngredient({
    required this.id,
    required this.recipeId,
    required this.name,
    this.quantity,
    this.unit,
    this.category,
    required this.position,
    required this.isOptional,
    required this.isIncluded,
    required this.isToTaste,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['position'] = Variable<int>(position);
    map['is_optional'] = Variable<bool>(isOptional);
    map['is_included'] = Variable<bool>(isIncluded);
    map['is_to_taste'] = Variable<bool>(isToTaste);
    return map;
  }

  LocalIngredientsCompanion toCompanion(bool nullToAbsent) {
    return LocalIngredientsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      name: Value(name),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      position: Value(position),
      isOptional: Value(isOptional),
      isIncluded: Value(isIncluded),
      isToTaste: Value(isToTaste),
    );
  }

  factory LocalIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalIngredient(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      category: serializer.fromJson<String?>(json['category']),
      position: serializer.fromJson<int>(json['position']),
      isOptional: serializer.fromJson<bool>(json['isOptional']),
      isIncluded: serializer.fromJson<bool>(json['isIncluded']),
      isToTaste: serializer.fromJson<bool>(json['isToTaste']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double?>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'category': serializer.toJson<String?>(category),
      'position': serializer.toJson<int>(position),
      'isOptional': serializer.toJson<bool>(isOptional),
      'isIncluded': serializer.toJson<bool>(isIncluded),
      'isToTaste': serializer.toJson<bool>(isToTaste),
    };
  }

  LocalIngredient copyWith({
    String? id,
    String? recipeId,
    String? name,
    Value<double?> quantity = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<String?> category = const Value.absent(),
    int? position,
    bool? isOptional,
    bool? isIncluded,
    bool? isToTaste,
  }) => LocalIngredient(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    name: name ?? this.name,
    quantity: quantity.present ? quantity.value : this.quantity,
    unit: unit.present ? unit.value : this.unit,
    category: category.present ? category.value : this.category,
    position: position ?? this.position,
    isOptional: isOptional ?? this.isOptional,
    isIncluded: isIncluded ?? this.isIncluded,
    isToTaste: isToTaste ?? this.isToTaste,
  );
  LocalIngredient copyWithCompanion(LocalIngredientsCompanion data) {
    return LocalIngredient(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      category: data.category.present ? data.category.value : this.category,
      position: data.position.present ? data.position.value : this.position,
      isOptional: data.isOptional.present
          ? data.isOptional.value
          : this.isOptional,
      isIncluded: data.isIncluded.present
          ? data.isIncluded.value
          : this.isIncluded,
      isToTaste: data.isToTaste.present ? data.isToTaste.value : this.isToTaste,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalIngredient(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('position: $position, ')
          ..write('isOptional: $isOptional, ')
          ..write('isIncluded: $isIncluded, ')
          ..write('isToTaste: $isToTaste')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recipeId,
    name,
    quantity,
    unit,
    category,
    position,
    isOptional,
    isIncluded,
    isToTaste,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalIngredient &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.category == this.category &&
          other.position == this.position &&
          other.isOptional == this.isOptional &&
          other.isIncluded == this.isIncluded &&
          other.isToTaste == this.isToTaste);
}

class LocalIngredientsCompanion extends UpdateCompanion<LocalIngredient> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<String> name;
  final Value<double?> quantity;
  final Value<String?> unit;
  final Value<String?> category;
  final Value<int> position;
  final Value<bool> isOptional;
  final Value<bool> isIncluded;
  final Value<bool> isToTaste;
  final Value<int> rowid;
  const LocalIngredientsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.position = const Value.absent(),
    this.isOptional = const Value.absent(),
    this.isIncluded = const Value.absent(),
    this.isToTaste = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalIngredientsCompanion.insert({
    required String id,
    required String recipeId,
    required String name,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    required int position,
    this.isOptional = const Value.absent(),
    this.isIncluded = const Value.absent(),
    this.isToTaste = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       name = Value(name),
       position = Value(position);
  static Insertable<LocalIngredient> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? category,
    Expression<int>? position,
    Expression<bool>? isOptional,
    Expression<bool>? isIncluded,
    Expression<bool>? isToTaste,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
      if (position != null) 'position': position,
      if (isOptional != null) 'is_optional': isOptional,
      if (isIncluded != null) 'is_included': isIncluded,
      if (isToTaste != null) 'is_to_taste': isToTaste,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalIngredientsCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<String>? name,
    Value<double?>? quantity,
    Value<String?>? unit,
    Value<String?>? category,
    Value<int>? position,
    Value<bool>? isOptional,
    Value<bool>? isIncluded,
    Value<bool>? isToTaste,
    Value<int>? rowid,
  }) {
    return LocalIngredientsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      position: position ?? this.position,
      isOptional: isOptional ?? this.isOptional,
      isIncluded: isIncluded ?? this.isIncluded,
      isToTaste: isToTaste ?? this.isToTaste,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isOptional.present) {
      map['is_optional'] = Variable<bool>(isOptional.value);
    }
    if (isIncluded.present) {
      map['is_included'] = Variable<bool>(isIncluded.value);
    }
    if (isToTaste.present) {
      map['is_to_taste'] = Variable<bool>(isToTaste.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('position: $position, ')
          ..write('isOptional: $isOptional, ')
          ..write('isIncluded: $isIncluded, ')
          ..write('isToTaste: $isToTaste, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalRecipeStepsTable extends LocalRecipeSteps
    with TableInfo<$LocalRecipeStepsTable, LocalRecipeStep> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRecipeStepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOptionalMeta = const VerificationMeta(
    'isOptional',
  );
  @override
  late final GeneratedColumn<bool> isOptional = GeneratedColumn<bool>(
    'is_optional',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_optional" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    position,
    description,
    isOptional,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_recipe_steps';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalRecipeStep> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_optional')) {
      context.handle(
        _isOptionalMeta,
        isOptional.isAcceptableOrUnknown(data['is_optional']!, _isOptionalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRecipeStep map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRecipeStep(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      isOptional: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_optional'],
      )!,
    );
  }

  @override
  $LocalRecipeStepsTable createAlias(String alias) {
    return $LocalRecipeStepsTable(attachedDatabase, alias);
  }
}

class LocalRecipeStep extends DataClass implements Insertable<LocalRecipeStep> {
  final String id;
  final String recipeId;
  final int position;
  final String description;
  final bool isOptional;
  const LocalRecipeStep({
    required this.id,
    required this.recipeId,
    required this.position,
    required this.description,
    required this.isOptional,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['position'] = Variable<int>(position);
    map['description'] = Variable<String>(description);
    map['is_optional'] = Variable<bool>(isOptional);
    return map;
  }

  LocalRecipeStepsCompanion toCompanion(bool nullToAbsent) {
    return LocalRecipeStepsCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      position: Value(position),
      description: Value(description),
      isOptional: Value(isOptional),
    );
  }

  factory LocalRecipeStep.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRecipeStep(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      position: serializer.fromJson<int>(json['position']),
      description: serializer.fromJson<String>(json['description']),
      isOptional: serializer.fromJson<bool>(json['isOptional']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'position': serializer.toJson<int>(position),
      'description': serializer.toJson<String>(description),
      'isOptional': serializer.toJson<bool>(isOptional),
    };
  }

  LocalRecipeStep copyWith({
    String? id,
    String? recipeId,
    int? position,
    String? description,
    bool? isOptional,
  }) => LocalRecipeStep(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    position: position ?? this.position,
    description: description ?? this.description,
    isOptional: isOptional ?? this.isOptional,
  );
  LocalRecipeStep copyWithCompanion(LocalRecipeStepsCompanion data) {
    return LocalRecipeStep(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      position: data.position.present ? data.position.value : this.position,
      description: data.description.present
          ? data.description.value
          : this.description,
      isOptional: data.isOptional.present
          ? data.isOptional.value
          : this.isOptional,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecipeStep(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('description: $description, ')
          ..write('isOptional: $isOptional')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recipeId, position, description, isOptional);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRecipeStep &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.position == this.position &&
          other.description == this.description &&
          other.isOptional == this.isOptional);
}

class LocalRecipeStepsCompanion extends UpdateCompanion<LocalRecipeStep> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<int> position;
  final Value<String> description;
  final Value<bool> isOptional;
  final Value<int> rowid;
  const LocalRecipeStepsCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.position = const Value.absent(),
    this.description = const Value.absent(),
    this.isOptional = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRecipeStepsCompanion.insert({
    required String id,
    required String recipeId,
    required int position,
    required String description,
    this.isOptional = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId),
       position = Value(position),
       description = Value(description);
  static Insertable<LocalRecipeStep> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<int>? position,
    Expression<String>? description,
    Expression<bool>? isOptional,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (position != null) 'position': position,
      if (description != null) 'description': description,
      if (isOptional != null) 'is_optional': isOptional,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRecipeStepsCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<int>? position,
    Value<String>? description,
    Value<bool>? isOptional,
    Value<int>? rowid,
  }) {
    return LocalRecipeStepsCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      position: position ?? this.position,
      description: description ?? this.description,
      isOptional: isOptional ?? this.isOptional,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isOptional.present) {
      map['is_optional'] = Variable<bool>(isOptional.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecipeStepsCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('position: $position, ')
          ..write('description: $description, ')
          ..write('isOptional: $isOptional, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalNutritionInfoTable extends LocalNutritionInfo
    with TableInfo<$LocalNutritionInfoTable, LocalNutritionInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalNutritionInfoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbohydratesMeta = const VerificationMeta(
    'carbohydrates',
  );
  @override
  late final GeneratedColumn<double> carbohydrates = GeneratedColumn<double>(
    'carbohydrates',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
    'fiber',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recipeId,
    calories,
    protein,
    carbohydrates,
    fat,
    fiber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_nutrition_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalNutritionInfoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carbohydrates')) {
      context.handle(
        _carbohydratesMeta,
        carbohydrates.isAcceptableOrUnknown(
          data['carbohydrates']!,
          _carbohydratesMeta,
        ),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalNutritionInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalNutritionInfoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      ),
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      ),
      carbohydrates: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbohydrates'],
      ),
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      ),
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber'],
      ),
    );
  }

  @override
  $LocalNutritionInfoTable createAlias(String alias) {
    return $LocalNutritionInfoTable(attachedDatabase, alias);
  }
}

class LocalNutritionInfoData extends DataClass
    implements Insertable<LocalNutritionInfoData> {
  final String id;
  final String recipeId;
  final double? calories;
  final double? protein;
  final double? carbohydrates;
  final double? fat;
  final double? fiber;
  const LocalNutritionInfoData({
    required this.id,
    required this.recipeId,
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.fiber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<double>(calories);
    }
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    if (!nullToAbsent || carbohydrates != null) {
      map['carbohydrates'] = Variable<double>(carbohydrates);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    if (!nullToAbsent || fiber != null) {
      map['fiber'] = Variable<double>(fiber);
    }
    return map;
  }

  LocalNutritionInfoCompanion toCompanion(bool nullToAbsent) {
    return LocalNutritionInfoCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      calories: calories == null && nullToAbsent
          ? const Value.absent()
          : Value(calories),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
      carbohydrates: carbohydrates == null && nullToAbsent
          ? const Value.absent()
          : Value(carbohydrates),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      fiber: fiber == null && nullToAbsent
          ? const Value.absent()
          : Value(fiber),
    );
  }

  factory LocalNutritionInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalNutritionInfoData(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      calories: serializer.fromJson<double?>(json['calories']),
      protein: serializer.fromJson<double?>(json['protein']),
      carbohydrates: serializer.fromJson<double?>(json['carbohydrates']),
      fat: serializer.fromJson<double?>(json['fat']),
      fiber: serializer.fromJson<double?>(json['fiber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'calories': serializer.toJson<double?>(calories),
      'protein': serializer.toJson<double?>(protein),
      'carbohydrates': serializer.toJson<double?>(carbohydrates),
      'fat': serializer.toJson<double?>(fat),
      'fiber': serializer.toJson<double?>(fiber),
    };
  }

  LocalNutritionInfoData copyWith({
    String? id,
    String? recipeId,
    Value<double?> calories = const Value.absent(),
    Value<double?> protein = const Value.absent(),
    Value<double?> carbohydrates = const Value.absent(),
    Value<double?> fat = const Value.absent(),
    Value<double?> fiber = const Value.absent(),
  }) => LocalNutritionInfoData(
    id: id ?? this.id,
    recipeId: recipeId ?? this.recipeId,
    calories: calories.present ? calories.value : this.calories,
    protein: protein.present ? protein.value : this.protein,
    carbohydrates: carbohydrates.present
        ? carbohydrates.value
        : this.carbohydrates,
    fat: fat.present ? fat.value : this.fat,
    fiber: fiber.present ? fiber.value : this.fiber,
  );
  LocalNutritionInfoData copyWithCompanion(LocalNutritionInfoCompanion data) {
    return LocalNutritionInfoData(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbohydrates: data.carbohydrates.present
          ? data.carbohydrates.value
          : this.carbohydrates,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalNutritionInfoData(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbohydrates: $carbohydrates, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recipeId, calories, protein, carbohydrates, fat, fiber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalNutritionInfoData &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbohydrates == this.carbohydrates &&
          other.fat == this.fat &&
          other.fiber == this.fiber);
}

class LocalNutritionInfoCompanion
    extends UpdateCompanion<LocalNutritionInfoData> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<double?> calories;
  final Value<double?> protein;
  final Value<double?> carbohydrates;
  final Value<double?> fat;
  final Value<double?> fiber;
  final Value<int> rowid;
  const LocalNutritionInfoCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbohydrates = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalNutritionInfoCompanion.insert({
    required String id,
    required String recipeId,
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbohydrates = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recipeId = Value(recipeId);
  static Insertable<LocalNutritionInfoData> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? carbohydrates,
    Expression<double>? fat,
    Expression<double>? fiber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbohydrates != null) 'carbohydrates': carbohydrates,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalNutritionInfoCompanion copyWith({
    Value<String>? id,
    Value<String>? recipeId,
    Value<double?>? calories,
    Value<double?>? protein,
    Value<double?>? carbohydrates,
    Value<double?>? fat,
    Value<double?>? fiber,
    Value<int>? rowid,
  }) {
    return LocalNutritionInfoCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbohydrates.present) {
      map['carbohydrates'] = Variable<double>(carbohydrates.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalNutritionInfoCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbohydrates: $carbohydrates, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalWeeklyPlansTable extends LocalWeeklyPlans
    with TableInfo<$LocalWeeklyPlansTable, LocalWeeklyPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalWeeklyPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<String> weekStart = GeneratedColumn<String>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    householdId,
    userId,
    weekStart,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_weekly_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalWeeklyPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
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
  LocalWeeklyPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalWeeklyPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalWeeklyPlansTable createAlias(String alias) {
    return $LocalWeeklyPlansTable(attachedDatabase, alias);
  }
}

class LocalWeeklyPlan extends DataClass implements Insertable<LocalWeeklyPlan> {
  final String id;
  final String? householdId;
  final String? userId;
  final String weekStart;
  final DateTime createdAt;
  const LocalWeeklyPlan({
    required this.id,
    this.householdId,
    this.userId,
    required this.weekStart,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || householdId != null) {
      map['household_id'] = Variable<String>(householdId);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['week_start'] = Variable<String>(weekStart);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalWeeklyPlansCompanion toCompanion(bool nullToAbsent) {
    return LocalWeeklyPlansCompanion(
      id: Value(id),
      householdId: householdId == null && nullToAbsent
          ? const Value.absent()
          : Value(householdId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      weekStart: Value(weekStart),
      createdAt: Value(createdAt),
    );
  }

  factory LocalWeeklyPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalWeeklyPlan(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String?>(json['householdId']),
      userId: serializer.fromJson<String?>(json['userId']),
      weekStart: serializer.fromJson<String>(json['weekStart']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String?>(householdId),
      'userId': serializer.toJson<String?>(userId),
      'weekStart': serializer.toJson<String>(weekStart),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalWeeklyPlan copyWith({
    String? id,
    Value<String?> householdId = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    String? weekStart,
    DateTime? createdAt,
  }) => LocalWeeklyPlan(
    id: id ?? this.id,
    householdId: householdId.present ? householdId.value : this.householdId,
    userId: userId.present ? userId.value : this.userId,
    weekStart: weekStart ?? this.weekStart,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalWeeklyPlan copyWithCompanion(LocalWeeklyPlansCompanion data) {
    return LocalWeeklyPlan(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      userId: data.userId.present ? data.userId.value : this.userId,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalWeeklyPlan(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('userId: $userId, ')
          ..write('weekStart: $weekStart, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, householdId, userId, weekStart, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalWeeklyPlan &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.userId == this.userId &&
          other.weekStart == this.weekStart &&
          other.createdAt == this.createdAt);
}

class LocalWeeklyPlansCompanion extends UpdateCompanion<LocalWeeklyPlan> {
  final Value<String> id;
  final Value<String?> householdId;
  final Value<String?> userId;
  final Value<String> weekStart;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalWeeklyPlansCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.userId = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalWeeklyPlansCompanion.insert({
    required String id,
    this.householdId = const Value.absent(),
    this.userId = const Value.absent(),
    required String weekStart,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       weekStart = Value(weekStart),
       createdAt = Value(createdAt);
  static Insertable<LocalWeeklyPlan> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? userId,
    Expression<String>? weekStart,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (userId != null) 'user_id': userId,
      if (weekStart != null) 'week_start': weekStart,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalWeeklyPlansCompanion copyWith({
    Value<String>? id,
    Value<String?>? householdId,
    Value<String?>? userId,
    Value<String>? weekStart,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalWeeklyPlansCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      userId: userId ?? this.userId,
      weekStart: weekStart ?? this.weekStart,
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
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<String>(weekStart.value);
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
    return (StringBuffer('LocalWeeklyPlansCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('userId: $userId, ')
          ..write('weekStart: $weekStart, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalPlanSlotsTable extends LocalPlanSlots
    with TableInfo<$LocalPlanSlotsTable, LocalPlanSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalPlanSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recipeTitleMeta = const VerificationMeta(
    'recipeTitle',
  );
  @override
  late final GeneratedColumn<String> recipeTitle = GeneratedColumn<String>(
    'recipe_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLeftoverMeta = const VerificationMeta(
    'isLeftover',
  );
  @override
  late final GeneratedColumn<bool> isLeftover = GeneratedColumn<bool>(
    'is_leftover',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_leftover" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    dayOfWeek,
    mealType,
    recipeId,
    recipeTitle,
    servings,
    position,
    isLeftover,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_plan_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalPlanSlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    }
    if (data.containsKey('recipe_title')) {
      context.handle(
        _recipeTitleMeta,
        recipeTitle.isAcceptableOrUnknown(
          data['recipe_title']!,
          _recipeTitleMeta,
        ),
      );
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    } else if (isInserting) {
      context.missing(_servingsMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('is_leftover')) {
      context.handle(
        _isLeftoverMeta,
        isLeftover.isAcceptableOrUnknown(data['is_leftover']!, _isLeftoverMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalPlanSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalPlanSlot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      ),
      recipeTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_title'],
      ),
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}servings'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      isLeftover: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_leftover'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $LocalPlanSlotsTable createAlias(String alias) {
    return $LocalPlanSlotsTable(attachedDatabase, alias);
  }
}

class LocalPlanSlot extends DataClass implements Insertable<LocalPlanSlot> {
  final String id;
  final String planId;
  final int dayOfWeek;
  final String mealType;
  final String? recipeId;
  final String? recipeTitle;
  final int servings;
  final int position;
  final bool isLeftover;
  final String? notes;
  const LocalPlanSlot({
    required this.id,
    required this.planId,
    required this.dayOfWeek,
    required this.mealType,
    this.recipeId,
    this.recipeTitle,
    required this.servings,
    required this.position,
    required this.isLeftover,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['meal_type'] = Variable<String>(mealType);
    if (!nullToAbsent || recipeId != null) {
      map['recipe_id'] = Variable<String>(recipeId);
    }
    if (!nullToAbsent || recipeTitle != null) {
      map['recipe_title'] = Variable<String>(recipeTitle);
    }
    map['servings'] = Variable<int>(servings);
    map['position'] = Variable<int>(position);
    map['is_leftover'] = Variable<bool>(isLeftover);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocalPlanSlotsCompanion toCompanion(bool nullToAbsent) {
    return LocalPlanSlotsCompanion(
      id: Value(id),
      planId: Value(planId),
      dayOfWeek: Value(dayOfWeek),
      mealType: Value(mealType),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
      recipeTitle: recipeTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeTitle),
      servings: Value(servings),
      position: Value(position),
      isLeftover: Value(isLeftover),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LocalPlanSlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalPlanSlot(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      mealType: serializer.fromJson<String>(json['mealType']),
      recipeId: serializer.fromJson<String?>(json['recipeId']),
      recipeTitle: serializer.fromJson<String?>(json['recipeTitle']),
      servings: serializer.fromJson<int>(json['servings']),
      position: serializer.fromJson<int>(json['position']),
      isLeftover: serializer.fromJson<bool>(json['isLeftover']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'mealType': serializer.toJson<String>(mealType),
      'recipeId': serializer.toJson<String?>(recipeId),
      'recipeTitle': serializer.toJson<String?>(recipeTitle),
      'servings': serializer.toJson<int>(servings),
      'position': serializer.toJson<int>(position),
      'isLeftover': serializer.toJson<bool>(isLeftover),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocalPlanSlot copyWith({
    String? id,
    String? planId,
    int? dayOfWeek,
    String? mealType,
    Value<String?> recipeId = const Value.absent(),
    Value<String?> recipeTitle = const Value.absent(),
    int? servings,
    int? position,
    bool? isLeftover,
    Value<String?> notes = const Value.absent(),
  }) => LocalPlanSlot(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    mealType: mealType ?? this.mealType,
    recipeId: recipeId.present ? recipeId.value : this.recipeId,
    recipeTitle: recipeTitle.present ? recipeTitle.value : this.recipeTitle,
    servings: servings ?? this.servings,
    position: position ?? this.position,
    isLeftover: isLeftover ?? this.isLeftover,
    notes: notes.present ? notes.value : this.notes,
  );
  LocalPlanSlot copyWithCompanion(LocalPlanSlotsCompanion data) {
    return LocalPlanSlot(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      recipeTitle: data.recipeTitle.present
          ? data.recipeTitle.value
          : this.recipeTitle,
      servings: data.servings.present ? data.servings.value : this.servings,
      position: data.position.present ? data.position.value : this.position,
      isLeftover: data.isLeftover.present
          ? data.isLeftover.value
          : this.isLeftover,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlanSlot(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('mealType: $mealType, ')
          ..write('recipeId: $recipeId, ')
          ..write('recipeTitle: $recipeTitle, ')
          ..write('servings: $servings, ')
          ..write('position: $position, ')
          ..write('isLeftover: $isLeftover, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    dayOfWeek,
    mealType,
    recipeId,
    recipeTitle,
    servings,
    position,
    isLeftover,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalPlanSlot &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.mealType == this.mealType &&
          other.recipeId == this.recipeId &&
          other.recipeTitle == this.recipeTitle &&
          other.servings == this.servings &&
          other.position == this.position &&
          other.isLeftover == this.isLeftover &&
          other.notes == this.notes);
}

class LocalPlanSlotsCompanion extends UpdateCompanion<LocalPlanSlot> {
  final Value<String> id;
  final Value<String> planId;
  final Value<int> dayOfWeek;
  final Value<String> mealType;
  final Value<String?> recipeId;
  final Value<String?> recipeTitle;
  final Value<int> servings;
  final Value<int> position;
  final Value<bool> isLeftover;
  final Value<String?> notes;
  final Value<int> rowid;
  const LocalPlanSlotsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.mealType = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.recipeTitle = const Value.absent(),
    this.servings = const Value.absent(),
    this.position = const Value.absent(),
    this.isLeftover = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalPlanSlotsCompanion.insert({
    required String id,
    required String planId,
    required int dayOfWeek,
    required String mealType,
    this.recipeId = const Value.absent(),
    this.recipeTitle = const Value.absent(),
    required int servings,
    required int position,
    this.isLeftover = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       dayOfWeek = Value(dayOfWeek),
       mealType = Value(mealType),
       servings = Value(servings),
       position = Value(position);
  static Insertable<LocalPlanSlot> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<int>? dayOfWeek,
    Expression<String>? mealType,
    Expression<String>? recipeId,
    Expression<String>? recipeTitle,
    Expression<int>? servings,
    Expression<int>? position,
    Expression<bool>? isLeftover,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (mealType != null) 'meal_type': mealType,
      if (recipeId != null) 'recipe_id': recipeId,
      if (recipeTitle != null) 'recipe_title': recipeTitle,
      if (servings != null) 'servings': servings,
      if (position != null) 'position': position,
      if (isLeftover != null) 'is_leftover': isLeftover,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalPlanSlotsCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<int>? dayOfWeek,
    Value<String>? mealType,
    Value<String?>? recipeId,
    Value<String?>? recipeTitle,
    Value<int>? servings,
    Value<int>? position,
    Value<bool>? isLeftover,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return LocalPlanSlotsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      servings: servings ?? this.servings,
      position: position ?? this.position,
      isLeftover: isLeftover ?? this.isLeftover,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (recipeTitle.present) {
      map['recipe_title'] = Variable<String>(recipeTitle.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isLeftover.present) {
      map['is_leftover'] = Variable<bool>(isLeftover.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalPlanSlotsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('mealType: $mealType, ')
          ..write('recipeId: $recipeId, ')
          ..write('recipeTitle: $recipeTitle, ')
          ..write('servings: $servings, ')
          ..write('position: $position, ')
          ..write('isLeftover: $isLeftover, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalShoppingListsTable extends LocalShoppingLists
    with TableInfo<$LocalShoppingListsTable, LocalShoppingList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalShoppingListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _householdIdMeta = const VerificationMeta(
    'householdId',
  );
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
    'household_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  List<GeneratedColumn> get $columns => [id, householdId, userId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_shopping_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalShoppingList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
        _householdIdMeta,
        householdId.isAcceptableOrUnknown(
          data['household_id']!,
          _householdIdMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
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
  LocalShoppingList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalShoppingList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      householdId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}household_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalShoppingListsTable createAlias(String alias) {
    return $LocalShoppingListsTable(attachedDatabase, alias);
  }
}

class LocalShoppingList extends DataClass
    implements Insertable<LocalShoppingList> {
  final String id;
  final String? householdId;
  final String? userId;
  final DateTime createdAt;
  const LocalShoppingList({
    required this.id,
    this.householdId,
    this.userId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || householdId != null) {
      map['household_id'] = Variable<String>(householdId);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalShoppingListsCompanion toCompanion(bool nullToAbsent) {
    return LocalShoppingListsCompanion(
      id: Value(id),
      householdId: householdId == null && nullToAbsent
          ? const Value.absent()
          : Value(householdId),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      createdAt: Value(createdAt),
    );
  }

  factory LocalShoppingList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalShoppingList(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String?>(json['householdId']),
      userId: serializer.fromJson<String?>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String?>(householdId),
      'userId': serializer.toJson<String?>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalShoppingList copyWith({
    String? id,
    Value<String?> householdId = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    DateTime? createdAt,
  }) => LocalShoppingList(
    id: id ?? this.id,
    householdId: householdId.present ? householdId.value : this.householdId,
    userId: userId.present ? userId.value : this.userId,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalShoppingList copyWithCompanion(LocalShoppingListsCompanion data) {
    return LocalShoppingList(
      id: data.id.present ? data.id.value : this.id,
      householdId: data.householdId.present
          ? data.householdId.value
          : this.householdId,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalShoppingList(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, householdId, userId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalShoppingList &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt);
}

class LocalShoppingListsCompanion extends UpdateCompanion<LocalShoppingList> {
  final Value<String> id;
  final Value<String?> householdId;
  final Value<String?> userId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalShoppingListsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalShoppingListsCompanion.insert({
    required String id,
    this.householdId = const Value.absent(),
    this.userId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt);
  static Insertable<LocalShoppingList> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalShoppingListsCompanion copyWith({
    Value<String>? id,
    Value<String?>? householdId,
    Value<String?>? userId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalShoppingListsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      userId: userId ?? this.userId,
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
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
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
    return (StringBuffer('LocalShoppingListsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalShoppingItemsTable extends LocalShoppingItems
    with TableInfo<$LocalShoppingItemsTable, LocalShoppingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalShoppingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shoppingListIdMeta = const VerificationMeta(
    'shoppingListId',
  );
  @override
  late final GeneratedColumn<String> shoppingListId = GeneratedColumn<String>(
    'shopping_list_id',
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
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCheckedMeta = const VerificationMeta(
    'isChecked',
  );
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
    'is_checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isManualMeta = const VerificationMeta(
    'isManual',
  );
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
    'is_manual',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_manual" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _planSlotIdMeta = const VerificationMeta(
    'planSlotId',
  );
  @override
  late final GeneratedColumn<String> planSlotId = GeneratedColumn<String>(
    'plan_slot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
    'ingredient_id',
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
    shoppingListId,
    name,
    quantity,
    unit,
    category,
    isChecked,
    isManual,
    planSlotId,
    ingredientId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_shopping_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalShoppingItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shopping_list_id')) {
      context.handle(
        _shoppingListIdMeta,
        shoppingListId.isAcceptableOrUnknown(
          data['shopping_list_id']!,
          _shoppingListIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shoppingListIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_checked')) {
      context.handle(
        _isCheckedMeta,
        isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta),
      );
    }
    if (data.containsKey('is_manual')) {
      context.handle(
        _isManualMeta,
        isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta),
      );
    }
    if (data.containsKey('plan_slot_id')) {
      context.handle(
        _planSlotIdMeta,
        planSlotId.isAcceptableOrUnknown(
          data['plan_slot_id']!,
          _planSlotIdMeta,
        ),
      );
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
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
  LocalShoppingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalShoppingItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      shoppingListId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shopping_list_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      isChecked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_checked'],
      )!,
      isManual: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_manual'],
      )!,
      planSlotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_slot_id'],
      ),
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredient_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LocalShoppingItemsTable createAlias(String alias) {
    return $LocalShoppingItemsTable(attachedDatabase, alias);
  }
}

class LocalShoppingItem extends DataClass
    implements Insertable<LocalShoppingItem> {
  final String id;
  final String shoppingListId;
  final String name;
  final double? quantity;
  final String? unit;
  final String? category;
  final bool isChecked;
  final bool isManual;
  final String? planSlotId;
  final String? ingredientId;
  final DateTime createdAt;
  const LocalShoppingItem({
    required this.id,
    required this.shoppingListId,
    required this.name,
    this.quantity,
    this.unit,
    this.category,
    required this.isChecked,
    required this.isManual,
    this.planSlotId,
    this.ingredientId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shopping_list_id'] = Variable<String>(shoppingListId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['is_checked'] = Variable<bool>(isChecked);
    map['is_manual'] = Variable<bool>(isManual);
    if (!nullToAbsent || planSlotId != null) {
      map['plan_slot_id'] = Variable<String>(planSlotId);
    }
    if (!nullToAbsent || ingredientId != null) {
      map['ingredient_id'] = Variable<String>(ingredientId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalShoppingItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalShoppingItemsCompanion(
      id: Value(id),
      shoppingListId: Value(shoppingListId),
      name: Value(name),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      isChecked: Value(isChecked),
      isManual: Value(isManual),
      planSlotId: planSlotId == null && nullToAbsent
          ? const Value.absent()
          : Value(planSlotId),
      ingredientId: ingredientId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientId),
      createdAt: Value(createdAt),
    );
  }

  factory LocalShoppingItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalShoppingItem(
      id: serializer.fromJson<String>(json['id']),
      shoppingListId: serializer.fromJson<String>(json['shoppingListId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      category: serializer.fromJson<String?>(json['category']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      isManual: serializer.fromJson<bool>(json['isManual']),
      planSlotId: serializer.fromJson<String?>(json['planSlotId']),
      ingredientId: serializer.fromJson<String?>(json['ingredientId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shoppingListId': serializer.toJson<String>(shoppingListId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double?>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'category': serializer.toJson<String?>(category),
      'isChecked': serializer.toJson<bool>(isChecked),
      'isManual': serializer.toJson<bool>(isManual),
      'planSlotId': serializer.toJson<String?>(planSlotId),
      'ingredientId': serializer.toJson<String?>(ingredientId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalShoppingItem copyWith({
    String? id,
    String? shoppingListId,
    String? name,
    Value<double?> quantity = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<String?> category = const Value.absent(),
    bool? isChecked,
    bool? isManual,
    Value<String?> planSlotId = const Value.absent(),
    Value<String?> ingredientId = const Value.absent(),
    DateTime? createdAt,
  }) => LocalShoppingItem(
    id: id ?? this.id,
    shoppingListId: shoppingListId ?? this.shoppingListId,
    name: name ?? this.name,
    quantity: quantity.present ? quantity.value : this.quantity,
    unit: unit.present ? unit.value : this.unit,
    category: category.present ? category.value : this.category,
    isChecked: isChecked ?? this.isChecked,
    isManual: isManual ?? this.isManual,
    planSlotId: planSlotId.present ? planSlotId.value : this.planSlotId,
    ingredientId: ingredientId.present ? ingredientId.value : this.ingredientId,
    createdAt: createdAt ?? this.createdAt,
  );
  LocalShoppingItem copyWithCompanion(LocalShoppingItemsCompanion data) {
    return LocalShoppingItem(
      id: data.id.present ? data.id.value : this.id,
      shoppingListId: data.shoppingListId.present
          ? data.shoppingListId.value
          : this.shoppingListId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      category: data.category.present ? data.category.value : this.category,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      isManual: data.isManual.present ? data.isManual.value : this.isManual,
      planSlotId: data.planSlotId.present
          ? data.planSlotId.value
          : this.planSlotId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalShoppingItem(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('isChecked: $isChecked, ')
          ..write('isManual: $isManual, ')
          ..write('planSlotId: $planSlotId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shoppingListId,
    name,
    quantity,
    unit,
    category,
    isChecked,
    isManual,
    planSlotId,
    ingredientId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalShoppingItem &&
          other.id == this.id &&
          other.shoppingListId == this.shoppingListId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.category == this.category &&
          other.isChecked == this.isChecked &&
          other.isManual == this.isManual &&
          other.planSlotId == this.planSlotId &&
          other.ingredientId == this.ingredientId &&
          other.createdAt == this.createdAt);
}

class LocalShoppingItemsCompanion extends UpdateCompanion<LocalShoppingItem> {
  final Value<String> id;
  final Value<String> shoppingListId;
  final Value<String> name;
  final Value<double?> quantity;
  final Value<String?> unit;
  final Value<String?> category;
  final Value<bool> isChecked;
  final Value<bool> isManual;
  final Value<String?> planSlotId;
  final Value<String?> ingredientId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalShoppingItemsCompanion({
    this.id = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.isManual = const Value.absent(),
    this.planSlotId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalShoppingItemsCompanion.insert({
    required String id,
    required String shoppingListId,
    required String name,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.category = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.isManual = const Value.absent(),
    this.planSlotId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       shoppingListId = Value(shoppingListId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<LocalShoppingItem> custom({
    Expression<String>? id,
    Expression<String>? shoppingListId,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? category,
    Expression<bool>? isChecked,
    Expression<bool>? isManual,
    Expression<String>? planSlotId,
    Expression<String>? ingredientId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shoppingListId != null) 'shopping_list_id': shoppingListId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (category != null) 'category': category,
      if (isChecked != null) 'is_checked': isChecked,
      if (isManual != null) 'is_manual': isManual,
      if (planSlotId != null) 'plan_slot_id': planSlotId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalShoppingItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? shoppingListId,
    Value<String>? name,
    Value<double?>? quantity,
    Value<String?>? unit,
    Value<String?>? category,
    Value<bool>? isChecked,
    Value<bool>? isManual,
    Value<String?>? planSlotId,
    Value<String?>? ingredientId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LocalShoppingItemsCompanion(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      isManual: isManual ?? this.isManual,
      planSlotId: planSlotId ?? this.planSlotId,
      ingredientId: ingredientId ?? this.ingredientId,
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
    if (shoppingListId.present) {
      map['shopping_list_id'] = Variable<String>(shoppingListId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    if (planSlotId.present) {
      map['plan_slot_id'] = Variable<String>(planSlotId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
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
    return (StringBuffer('LocalShoppingItemsCompanion(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('category: $category, ')
          ..write('isChecked: $isChecked, ')
          ..write('isManual: $isManual, ')
          ..write('planSlotId: $planSlotId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingOperationsTable extends PendingOperations
    with TableInfo<$PendingOperationsTable, PendingOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    opType,
    payloadJson,
    createdAt,
    retryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
    );
  }

  @override
  $PendingOperationsTable createAlias(String alias) {
    return $PendingOperationsTable(attachedDatabase, alias);
  }
}

class PendingOperation extends DataClass
    implements Insertable<PendingOperation> {
  final String id;
  final String entityType;
  final String opType;
  final String payloadJson;
  final DateTime createdAt;
  final int retryCount;
  const PendingOperation({
    required this.id,
    required this.entityType,
    required this.opType,
    required this.payloadJson,
    required this.createdAt,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['op_type'] = Variable<String>(opType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  PendingOperationsCompanion toCompanion(bool nullToAbsent) {
    return PendingOperationsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      opType: Value(opType),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory PendingOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOperation(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      opType: serializer.fromJson<String>(json['opType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'opType': serializer.toJson<String>(opType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  PendingOperation copyWith({
    String? id,
    String? entityType,
    String? opType,
    String? payloadJson,
    DateTime? createdAt,
    int? retryCount,
  }) => PendingOperation(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    opType: opType ?? this.opType,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
  );
  PendingOperation copyWithCompanion(PendingOperationsCompanion data) {
    return PendingOperation(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      opType: data.opType.present ? data.opType.value : this.opType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperation(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('opType: $opType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityType, opType, payloadJson, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOperation &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.opType == this.opType &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class PendingOperationsCompanion extends UpdateCompanion<PendingOperation> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> opType;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<int> rowid;
  const PendingOperationsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.opType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingOperationsCompanion.insert({
    required String id,
    required String entityType,
    required String opType,
    required String payloadJson,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       opType = Value(opType),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<PendingOperation> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? opType,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (opType != null) 'op_type': opType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingOperationsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? opType,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
    Value<int>? rowid,
  }) {
    return PendingOperationsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      opType: opType ?? this.opType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('opType: $opType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IdMappingsTable extends IdMappings
    with TableInfo<$IdMappingsTable, IdMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tempIdMeta = const VerificationMeta('tempId');
  @override
  late final GeneratedColumn<String> tempId = GeneratedColumn<String>(
    'temp_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _realIdMeta = const VerificationMeta('realId');
  @override
  late final GeneratedColumn<String> realId = GeneratedColumn<String>(
    'real_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tempId, realId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'id_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdMapping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('temp_id')) {
      context.handle(
        _tempIdMeta,
        tempId.isAcceptableOrUnknown(data['temp_id']!, _tempIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tempIdMeta);
    }
    if (data.containsKey('real_id')) {
      context.handle(
        _realIdMeta,
        realId.isAcceptableOrUnknown(data['real_id']!, _realIdMeta),
      );
    } else if (isInserting) {
      context.missing(_realIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tempId};
  @override
  IdMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdMapping(
      tempId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temp_id'],
      )!,
      realId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}real_id'],
      )!,
    );
  }

  @override
  $IdMappingsTable createAlias(String alias) {
    return $IdMappingsTable(attachedDatabase, alias);
  }
}

class IdMapping extends DataClass implements Insertable<IdMapping> {
  final String tempId;
  final String realId;
  const IdMapping({required this.tempId, required this.realId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['temp_id'] = Variable<String>(tempId);
    map['real_id'] = Variable<String>(realId);
    return map;
  }

  IdMappingsCompanion toCompanion(bool nullToAbsent) {
    return IdMappingsCompanion(tempId: Value(tempId), realId: Value(realId));
  }

  factory IdMapping.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdMapping(
      tempId: serializer.fromJson<String>(json['tempId']),
      realId: serializer.fromJson<String>(json['realId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tempId': serializer.toJson<String>(tempId),
      'realId': serializer.toJson<String>(realId),
    };
  }

  IdMapping copyWith({String? tempId, String? realId}) =>
      IdMapping(tempId: tempId ?? this.tempId, realId: realId ?? this.realId);
  IdMapping copyWithCompanion(IdMappingsCompanion data) {
    return IdMapping(
      tempId: data.tempId.present ? data.tempId.value : this.tempId,
      realId: data.realId.present ? data.realId.value : this.realId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdMapping(')
          ..write('tempId: $tempId, ')
          ..write('realId: $realId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tempId, realId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdMapping &&
          other.tempId == this.tempId &&
          other.realId == this.realId);
}

class IdMappingsCompanion extends UpdateCompanion<IdMapping> {
  final Value<String> tempId;
  final Value<String> realId;
  final Value<int> rowid;
  const IdMappingsCompanion({
    this.tempId = const Value.absent(),
    this.realId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdMappingsCompanion.insert({
    required String tempId,
    required String realId,
    this.rowid = const Value.absent(),
  }) : tempId = Value(tempId),
       realId = Value(realId);
  static Insertable<IdMapping> custom({
    Expression<String>? tempId,
    Expression<String>? realId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tempId != null) 'temp_id': tempId,
      if (realId != null) 'real_id': realId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdMappingsCompanion copyWith({
    Value<String>? tempId,
    Value<String>? realId,
    Value<int>? rowid,
  }) {
    return IdMappingsCompanion(
      tempId: tempId ?? this.tempId,
      realId: realId ?? this.realId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tempId.present) {
      map['temp_id'] = Variable<String>(tempId.value);
    }
    if (realId.present) {
      map['real_id'] = Variable<String>(realId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdMappingsCompanion(')
          ..write('tempId: $tempId, ')
          ..write('realId: $realId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalRecipesTable localRecipes = $LocalRecipesTable(this);
  late final $LocalIngredientsTable localIngredients = $LocalIngredientsTable(
    this,
  );
  late final $LocalRecipeStepsTable localRecipeSteps = $LocalRecipeStepsTable(
    this,
  );
  late final $LocalNutritionInfoTable localNutritionInfo =
      $LocalNutritionInfoTable(this);
  late final $LocalWeeklyPlansTable localWeeklyPlans = $LocalWeeklyPlansTable(
    this,
  );
  late final $LocalPlanSlotsTable localPlanSlots = $LocalPlanSlotsTable(this);
  late final $LocalShoppingListsTable localShoppingLists =
      $LocalShoppingListsTable(this);
  late final $LocalShoppingItemsTable localShoppingItems =
      $LocalShoppingItemsTable(this);
  late final $PendingOperationsTable pendingOperations =
      $PendingOperationsTable(this);
  late final $IdMappingsTable idMappings = $IdMappingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localRecipes,
    localIngredients,
    localRecipeSteps,
    localNutritionInfo,
    localWeeklyPlans,
    localPlanSlots,
    localShoppingLists,
    localShoppingItems,
    pendingOperations,
    idMappings,
  ];
}

typedef $$LocalRecipesTableCreateCompanionBuilder =
    LocalRecipesCompanion Function({
      required String id,
      required String userId,
      required String title,
      Value<String?> photoUrl,
      required int servings,
      Value<int?> prepTime,
      Value<int?> cookTime,
      required String tagsJson,
      Value<bool> isPublic,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> tips,
      Value<String?> forkedFromId,
      Value<int> rowid,
    });
typedef $$LocalRecipesTableUpdateCompanionBuilder =
    LocalRecipesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> title,
      Value<String?> photoUrl,
      Value<int> servings,
      Value<int?> prepTime,
      Value<int?> cookTime,
      Value<String> tagsJson,
      Value<bool> isPublic,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> tips,
      Value<String?> forkedFromId,
      Value<int> rowid,
    });

class $$LocalRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRecipesTable> {
  $$LocalRecipesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get prepTime => $composableBuilder(
    column: $table.prepTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cookTime => $composableBuilder(
    column: $table.cookTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tips => $composableBuilder(
    column: $table.tips,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forkedFromId => $composableBuilder(
    column: $table.forkedFromId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRecipesTable> {
  $$LocalRecipesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get prepTime => $composableBuilder(
    column: $table.prepTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cookTime => $composableBuilder(
    column: $table.cookTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublic => $composableBuilder(
    column: $table.isPublic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tips => $composableBuilder(
    column: $table.tips,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forkedFromId => $composableBuilder(
    column: $table.forkedFromId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRecipesTable> {
  $$LocalRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<int> get prepTime =>
      $composableBuilder(column: $table.prepTime, builder: (column) => column);

  GeneratedColumn<int> get cookTime =>
      $composableBuilder(column: $table.cookTime, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get tips =>
      $composableBuilder(column: $table.tips, builder: (column) => column);

  GeneratedColumn<String> get forkedFromId => $composableBuilder(
    column: $table.forkedFromId,
    builder: (column) => column,
  );
}

class $$LocalRecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRecipesTable,
          LocalRecipe,
          $$LocalRecipesTableFilterComposer,
          $$LocalRecipesTableOrderingComposer,
          $$LocalRecipesTableAnnotationComposer,
          $$LocalRecipesTableCreateCompanionBuilder,
          $$LocalRecipesTableUpdateCompanionBuilder,
          (
            LocalRecipe,
            BaseReferences<_$AppDatabase, $LocalRecipesTable, LocalRecipe>,
          ),
          LocalRecipe,
          PrefetchHooks Function()
        > {
  $$LocalRecipesTableTableManager(_$AppDatabase db, $LocalRecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<int?> prepTime = const Value.absent(),
                Value<int?> cookTime = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<bool> isPublic = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> tips = const Value.absent(),
                Value<String?> forkedFromId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecipesCompanion(
                id: id,
                userId: userId,
                title: title,
                photoUrl: photoUrl,
                servings: servings,
                prepTime: prepTime,
                cookTime: cookTime,
                tagsJson: tagsJson,
                isPublic: isPublic,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tips: tips,
                forkedFromId: forkedFromId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String title,
                Value<String?> photoUrl = const Value.absent(),
                required int servings,
                Value<int?> prepTime = const Value.absent(),
                Value<int?> cookTime = const Value.absent(),
                required String tagsJson,
                Value<bool> isPublic = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> tips = const Value.absent(),
                Value<String?> forkedFromId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecipesCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                photoUrl: photoUrl,
                servings: servings,
                prepTime: prepTime,
                cookTime: cookTime,
                tagsJson: tagsJson,
                isPublic: isPublic,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tips: tips,
                forkedFromId: forkedFromId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRecipesTable,
      LocalRecipe,
      $$LocalRecipesTableFilterComposer,
      $$LocalRecipesTableOrderingComposer,
      $$LocalRecipesTableAnnotationComposer,
      $$LocalRecipesTableCreateCompanionBuilder,
      $$LocalRecipesTableUpdateCompanionBuilder,
      (
        LocalRecipe,
        BaseReferences<_$AppDatabase, $LocalRecipesTable, LocalRecipe>,
      ),
      LocalRecipe,
      PrefetchHooks Function()
    >;
typedef $$LocalIngredientsTableCreateCompanionBuilder =
    LocalIngredientsCompanion Function({
      required String id,
      required String recipeId,
      required String name,
      Value<double?> quantity,
      Value<String?> unit,
      Value<String?> category,
      required int position,
      Value<bool> isOptional,
      Value<bool> isIncluded,
      Value<bool> isToTaste,
      Value<int> rowid,
    });
typedef $$LocalIngredientsTableUpdateCompanionBuilder =
    LocalIngredientsCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<String> name,
      Value<double?> quantity,
      Value<String?> unit,
      Value<String?> category,
      Value<int> position,
      Value<bool> isOptional,
      Value<bool> isIncluded,
      Value<bool> isToTaste,
      Value<int> rowid,
    });

class $$LocalIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalIngredientsTable> {
  $$LocalIngredientsTableFilterComposer({
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

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncluded => $composableBuilder(
    column: $table.isIncluded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isToTaste => $composableBuilder(
    column: $table.isToTaste,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalIngredientsTable> {
  $$LocalIngredientsTableOrderingComposer({
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

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncluded => $composableBuilder(
    column: $table.isIncluded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isToTaste => $composableBuilder(
    column: $table.isToTaste,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalIngredientsTable> {
  $$LocalIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIncluded => $composableBuilder(
    column: $table.isIncluded,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isToTaste =>
      $composableBuilder(column: $table.isToTaste, builder: (column) => column);
}

class $$LocalIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalIngredientsTable,
          LocalIngredient,
          $$LocalIngredientsTableFilterComposer,
          $$LocalIngredientsTableOrderingComposer,
          $$LocalIngredientsTableAnnotationComposer,
          $$LocalIngredientsTableCreateCompanionBuilder,
          $$LocalIngredientsTableUpdateCompanionBuilder,
          (
            LocalIngredient,
            BaseReferences<
              _$AppDatabase,
              $LocalIngredientsTable,
              LocalIngredient
            >,
          ),
          LocalIngredient,
          PrefetchHooks Function()
        > {
  $$LocalIngredientsTableTableManager(
    _$AppDatabase db,
    $LocalIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalIngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> isOptional = const Value.absent(),
                Value<bool> isIncluded = const Value.absent(),
                Value<bool> isToTaste = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIngredientsCompanion(
                id: id,
                recipeId: recipeId,
                name: name,
                quantity: quantity,
                unit: unit,
                category: category,
                position: position,
                isOptional: isOptional,
                isIncluded: isIncluded,
                isToTaste: isToTaste,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required String name,
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> category = const Value.absent(),
                required int position,
                Value<bool> isOptional = const Value.absent(),
                Value<bool> isIncluded = const Value.absent(),
                Value<bool> isToTaste = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalIngredientsCompanion.insert(
                id: id,
                recipeId: recipeId,
                name: name,
                quantity: quantity,
                unit: unit,
                category: category,
                position: position,
                isOptional: isOptional,
                isIncluded: isIncluded,
                isToTaste: isToTaste,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalIngredientsTable,
      LocalIngredient,
      $$LocalIngredientsTableFilterComposer,
      $$LocalIngredientsTableOrderingComposer,
      $$LocalIngredientsTableAnnotationComposer,
      $$LocalIngredientsTableCreateCompanionBuilder,
      $$LocalIngredientsTableUpdateCompanionBuilder,
      (
        LocalIngredient,
        BaseReferences<_$AppDatabase, $LocalIngredientsTable, LocalIngredient>,
      ),
      LocalIngredient,
      PrefetchHooks Function()
    >;
typedef $$LocalRecipeStepsTableCreateCompanionBuilder =
    LocalRecipeStepsCompanion Function({
      required String id,
      required String recipeId,
      required int position,
      required String description,
      Value<bool> isOptional,
      Value<int> rowid,
    });
typedef $$LocalRecipeStepsTableUpdateCompanionBuilder =
    LocalRecipeStepsCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<int> position,
      Value<String> description,
      Value<bool> isOptional,
      Value<int> rowid,
    });

class $$LocalRecipeStepsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRecipeStepsTable> {
  $$LocalRecipeStepsTableFilterComposer({
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

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalRecipeStepsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRecipeStepsTable> {
  $$LocalRecipeStepsTableOrderingComposer({
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

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalRecipeStepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRecipeStepsTable> {
  $$LocalRecipeStepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOptional => $composableBuilder(
    column: $table.isOptional,
    builder: (column) => column,
  );
}

class $$LocalRecipeStepsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalRecipeStepsTable,
          LocalRecipeStep,
          $$LocalRecipeStepsTableFilterComposer,
          $$LocalRecipeStepsTableOrderingComposer,
          $$LocalRecipeStepsTableAnnotationComposer,
          $$LocalRecipeStepsTableCreateCompanionBuilder,
          $$LocalRecipeStepsTableUpdateCompanionBuilder,
          (
            LocalRecipeStep,
            BaseReferences<
              _$AppDatabase,
              $LocalRecipeStepsTable,
              LocalRecipeStep
            >,
          ),
          LocalRecipeStep,
          PrefetchHooks Function()
        > {
  $$LocalRecipeStepsTableTableManager(
    _$AppDatabase db,
    $LocalRecipeStepsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRecipeStepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRecipeStepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRecipeStepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> isOptional = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecipeStepsCompanion(
                id: id,
                recipeId: recipeId,
                position: position,
                description: description,
                isOptional: isOptional,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                required int position,
                required String description,
                Value<bool> isOptional = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalRecipeStepsCompanion.insert(
                id: id,
                recipeId: recipeId,
                position: position,
                description: description,
                isOptional: isOptional,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalRecipeStepsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalRecipeStepsTable,
      LocalRecipeStep,
      $$LocalRecipeStepsTableFilterComposer,
      $$LocalRecipeStepsTableOrderingComposer,
      $$LocalRecipeStepsTableAnnotationComposer,
      $$LocalRecipeStepsTableCreateCompanionBuilder,
      $$LocalRecipeStepsTableUpdateCompanionBuilder,
      (
        LocalRecipeStep,
        BaseReferences<_$AppDatabase, $LocalRecipeStepsTable, LocalRecipeStep>,
      ),
      LocalRecipeStep,
      PrefetchHooks Function()
    >;
typedef $$LocalNutritionInfoTableCreateCompanionBuilder =
    LocalNutritionInfoCompanion Function({
      required String id,
      required String recipeId,
      Value<double?> calories,
      Value<double?> protein,
      Value<double?> carbohydrates,
      Value<double?> fat,
      Value<double?> fiber,
      Value<int> rowid,
    });
typedef $$LocalNutritionInfoTableUpdateCompanionBuilder =
    LocalNutritionInfoCompanion Function({
      Value<String> id,
      Value<String> recipeId,
      Value<double?> calories,
      Value<double?> protein,
      Value<double?> carbohydrates,
      Value<double?> fat,
      Value<double?> fiber,
      Value<int> rowid,
    });

class $$LocalNutritionInfoTableFilterComposer
    extends Composer<_$AppDatabase, $LocalNutritionInfoTable> {
  $$LocalNutritionInfoTableFilterComposer({
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

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbohydrates => $composableBuilder(
    column: $table.carbohydrates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalNutritionInfoTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalNutritionInfoTable> {
  $$LocalNutritionInfoTableOrderingComposer({
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

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbohydrates => $composableBuilder(
    column: $table.carbohydrates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalNutritionInfoTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalNutritionInfoTable> {
  $$LocalNutritionInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbohydrates => $composableBuilder(
    column: $table.carbohydrates,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);
}

class $$LocalNutritionInfoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalNutritionInfoTable,
          LocalNutritionInfoData,
          $$LocalNutritionInfoTableFilterComposer,
          $$LocalNutritionInfoTableOrderingComposer,
          $$LocalNutritionInfoTableAnnotationComposer,
          $$LocalNutritionInfoTableCreateCompanionBuilder,
          $$LocalNutritionInfoTableUpdateCompanionBuilder,
          (
            LocalNutritionInfoData,
            BaseReferences<
              _$AppDatabase,
              $LocalNutritionInfoTable,
              LocalNutritionInfoData
            >,
          ),
          LocalNutritionInfoData,
          PrefetchHooks Function()
        > {
  $$LocalNutritionInfoTableTableManager(
    _$AppDatabase db,
    $LocalNutritionInfoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalNutritionInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalNutritionInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalNutritionInfoTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<double?> calories = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carbohydrates = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalNutritionInfoCompanion(
                id: id,
                recipeId: recipeId,
                calories: calories,
                protein: protein,
                carbohydrates: carbohydrates,
                fat: fat,
                fiber: fiber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recipeId,
                Value<double?> calories = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carbohydrates = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalNutritionInfoCompanion.insert(
                id: id,
                recipeId: recipeId,
                calories: calories,
                protein: protein,
                carbohydrates: carbohydrates,
                fat: fat,
                fiber: fiber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalNutritionInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalNutritionInfoTable,
      LocalNutritionInfoData,
      $$LocalNutritionInfoTableFilterComposer,
      $$LocalNutritionInfoTableOrderingComposer,
      $$LocalNutritionInfoTableAnnotationComposer,
      $$LocalNutritionInfoTableCreateCompanionBuilder,
      $$LocalNutritionInfoTableUpdateCompanionBuilder,
      (
        LocalNutritionInfoData,
        BaseReferences<
          _$AppDatabase,
          $LocalNutritionInfoTable,
          LocalNutritionInfoData
        >,
      ),
      LocalNutritionInfoData,
      PrefetchHooks Function()
    >;
typedef $$LocalWeeklyPlansTableCreateCompanionBuilder =
    LocalWeeklyPlansCompanion Function({
      required String id,
      Value<String?> householdId,
      Value<String?> userId,
      required String weekStart,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalWeeklyPlansTableUpdateCompanionBuilder =
    LocalWeeklyPlansCompanion Function({
      Value<String> id,
      Value<String?> householdId,
      Value<String?> userId,
      Value<String> weekStart,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalWeeklyPlansTableFilterComposer
    extends Composer<_$AppDatabase, $LocalWeeklyPlansTable> {
  $$LocalWeeklyPlansTableFilterComposer({
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

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalWeeklyPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalWeeklyPlansTable> {
  $$LocalWeeklyPlansTableOrderingComposer({
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

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalWeeklyPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalWeeklyPlansTable> {
  $$LocalWeeklyPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalWeeklyPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalWeeklyPlansTable,
          LocalWeeklyPlan,
          $$LocalWeeklyPlansTableFilterComposer,
          $$LocalWeeklyPlansTableOrderingComposer,
          $$LocalWeeklyPlansTableAnnotationComposer,
          $$LocalWeeklyPlansTableCreateCompanionBuilder,
          $$LocalWeeklyPlansTableUpdateCompanionBuilder,
          (
            LocalWeeklyPlan,
            BaseReferences<
              _$AppDatabase,
              $LocalWeeklyPlansTable,
              LocalWeeklyPlan
            >,
          ),
          LocalWeeklyPlan,
          PrefetchHooks Function()
        > {
  $$LocalWeeklyPlansTableTableManager(
    _$AppDatabase db,
    $LocalWeeklyPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalWeeklyPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalWeeklyPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalWeeklyPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> householdId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String> weekStart = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalWeeklyPlansCompanion(
                id: id,
                householdId: householdId,
                userId: userId,
                weekStart: weekStart,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> householdId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                required String weekStart,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalWeeklyPlansCompanion.insert(
                id: id,
                householdId: householdId,
                userId: userId,
                weekStart: weekStart,
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

typedef $$LocalWeeklyPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalWeeklyPlansTable,
      LocalWeeklyPlan,
      $$LocalWeeklyPlansTableFilterComposer,
      $$LocalWeeklyPlansTableOrderingComposer,
      $$LocalWeeklyPlansTableAnnotationComposer,
      $$LocalWeeklyPlansTableCreateCompanionBuilder,
      $$LocalWeeklyPlansTableUpdateCompanionBuilder,
      (
        LocalWeeklyPlan,
        BaseReferences<_$AppDatabase, $LocalWeeklyPlansTable, LocalWeeklyPlan>,
      ),
      LocalWeeklyPlan,
      PrefetchHooks Function()
    >;
typedef $$LocalPlanSlotsTableCreateCompanionBuilder =
    LocalPlanSlotsCompanion Function({
      required String id,
      required String planId,
      required int dayOfWeek,
      required String mealType,
      Value<String?> recipeId,
      Value<String?> recipeTitle,
      required int servings,
      required int position,
      Value<bool> isLeftover,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$LocalPlanSlotsTableUpdateCompanionBuilder =
    LocalPlanSlotsCompanion Function({
      Value<String> id,
      Value<String> planId,
      Value<int> dayOfWeek,
      Value<String> mealType,
      Value<String?> recipeId,
      Value<String?> recipeTitle,
      Value<int> servings,
      Value<int> position,
      Value<bool> isLeftover,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$LocalPlanSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalPlanSlotsTable> {
  $$LocalPlanSlotsTableFilterComposer({
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

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeTitle => $composableBuilder(
    column: $table.recipeTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLeftover => $composableBuilder(
    column: $table.isLeftover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalPlanSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalPlanSlotsTable> {
  $$LocalPlanSlotsTableOrderingComposer({
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

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeTitle => $composableBuilder(
    column: $table.recipeTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLeftover => $composableBuilder(
    column: $table.isLeftover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalPlanSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalPlanSlotsTable> {
  $$LocalPlanSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get recipeTitle => $composableBuilder(
    column: $table.recipeTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isLeftover => $composableBuilder(
    column: $table.isLeftover,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LocalPlanSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalPlanSlotsTable,
          LocalPlanSlot,
          $$LocalPlanSlotsTableFilterComposer,
          $$LocalPlanSlotsTableOrderingComposer,
          $$LocalPlanSlotsTableAnnotationComposer,
          $$LocalPlanSlotsTableCreateCompanionBuilder,
          $$LocalPlanSlotsTableUpdateCompanionBuilder,
          (
            LocalPlanSlot,
            BaseReferences<_$AppDatabase, $LocalPlanSlotsTable, LocalPlanSlot>,
          ),
          LocalPlanSlot,
          PrefetchHooks Function()
        > {
  $$LocalPlanSlotsTableTableManager(
    _$AppDatabase db,
    $LocalPlanSlotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalPlanSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalPlanSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalPlanSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<int> dayOfWeek = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<String?> recipeId = const Value.absent(),
                Value<String?> recipeTitle = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> isLeftover = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlanSlotsCompanion(
                id: id,
                planId: planId,
                dayOfWeek: dayOfWeek,
                mealType: mealType,
                recipeId: recipeId,
                recipeTitle: recipeTitle,
                servings: servings,
                position: position,
                isLeftover: isLeftover,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required int dayOfWeek,
                required String mealType,
                Value<String?> recipeId = const Value.absent(),
                Value<String?> recipeTitle = const Value.absent(),
                required int servings,
                required int position,
                Value<bool> isLeftover = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalPlanSlotsCompanion.insert(
                id: id,
                planId: planId,
                dayOfWeek: dayOfWeek,
                mealType: mealType,
                recipeId: recipeId,
                recipeTitle: recipeTitle,
                servings: servings,
                position: position,
                isLeftover: isLeftover,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalPlanSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalPlanSlotsTable,
      LocalPlanSlot,
      $$LocalPlanSlotsTableFilterComposer,
      $$LocalPlanSlotsTableOrderingComposer,
      $$LocalPlanSlotsTableAnnotationComposer,
      $$LocalPlanSlotsTableCreateCompanionBuilder,
      $$LocalPlanSlotsTableUpdateCompanionBuilder,
      (
        LocalPlanSlot,
        BaseReferences<_$AppDatabase, $LocalPlanSlotsTable, LocalPlanSlot>,
      ),
      LocalPlanSlot,
      PrefetchHooks Function()
    >;
typedef $$LocalShoppingListsTableCreateCompanionBuilder =
    LocalShoppingListsCompanion Function({
      required String id,
      Value<String?> householdId,
      Value<String?> userId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalShoppingListsTableUpdateCompanionBuilder =
    LocalShoppingListsCompanion Function({
      Value<String> id,
      Value<String?> householdId,
      Value<String?> userId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalShoppingListsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalShoppingListsTable> {
  $$LocalShoppingListsTableFilterComposer({
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

  ColumnFilters<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalShoppingListsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalShoppingListsTable> {
  $$LocalShoppingListsTableOrderingComposer({
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

  ColumnOrderings<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalShoppingListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalShoppingListsTable> {
  $$LocalShoppingListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
    column: $table.householdId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalShoppingListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalShoppingListsTable,
          LocalShoppingList,
          $$LocalShoppingListsTableFilterComposer,
          $$LocalShoppingListsTableOrderingComposer,
          $$LocalShoppingListsTableAnnotationComposer,
          $$LocalShoppingListsTableCreateCompanionBuilder,
          $$LocalShoppingListsTableUpdateCompanionBuilder,
          (
            LocalShoppingList,
            BaseReferences<
              _$AppDatabase,
              $LocalShoppingListsTable,
              LocalShoppingList
            >,
          ),
          LocalShoppingList,
          PrefetchHooks Function()
        > {
  $$LocalShoppingListsTableTableManager(
    _$AppDatabase db,
    $LocalShoppingListsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalShoppingListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalShoppingListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalShoppingListsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> householdId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalShoppingListsCompanion(
                id: id,
                householdId: householdId,
                userId: userId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> householdId = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalShoppingListsCompanion.insert(
                id: id,
                householdId: householdId,
                userId: userId,
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

typedef $$LocalShoppingListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalShoppingListsTable,
      LocalShoppingList,
      $$LocalShoppingListsTableFilterComposer,
      $$LocalShoppingListsTableOrderingComposer,
      $$LocalShoppingListsTableAnnotationComposer,
      $$LocalShoppingListsTableCreateCompanionBuilder,
      $$LocalShoppingListsTableUpdateCompanionBuilder,
      (
        LocalShoppingList,
        BaseReferences<
          _$AppDatabase,
          $LocalShoppingListsTable,
          LocalShoppingList
        >,
      ),
      LocalShoppingList,
      PrefetchHooks Function()
    >;
typedef $$LocalShoppingItemsTableCreateCompanionBuilder =
    LocalShoppingItemsCompanion Function({
      required String id,
      required String shoppingListId,
      required String name,
      Value<double?> quantity,
      Value<String?> unit,
      Value<String?> category,
      Value<bool> isChecked,
      Value<bool> isManual,
      Value<String?> planSlotId,
      Value<String?> ingredientId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$LocalShoppingItemsTableUpdateCompanionBuilder =
    LocalShoppingItemsCompanion Function({
      Value<String> id,
      Value<String> shoppingListId,
      Value<String> name,
      Value<double?> quantity,
      Value<String?> unit,
      Value<String?> category,
      Value<bool> isChecked,
      Value<bool> isManual,
      Value<String?> planSlotId,
      Value<String?> ingredientId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$LocalShoppingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalShoppingItemsTable> {
  $$LocalShoppingItemsTableFilterComposer({
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

  ColumnFilters<String> get shoppingListId => $composableBuilder(
    column: $table.shoppingListId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planSlotId => $composableBuilder(
    column: $table.planSlotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalShoppingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalShoppingItemsTable> {
  $$LocalShoppingItemsTableOrderingComposer({
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

  ColumnOrderings<String> get shoppingListId => $composableBuilder(
    column: $table.shoppingListId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isChecked => $composableBuilder(
    column: $table.isChecked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isManual => $composableBuilder(
    column: $table.isManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planSlotId => $composableBuilder(
    column: $table.planSlotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalShoppingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalShoppingItemsTable> {
  $$LocalShoppingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shoppingListId => $composableBuilder(
    column: $table.shoppingListId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);

  GeneratedColumn<String> get planSlotId => $composableBuilder(
    column: $table.planSlotId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ingredientId => $composableBuilder(
    column: $table.ingredientId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LocalShoppingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalShoppingItemsTable,
          LocalShoppingItem,
          $$LocalShoppingItemsTableFilterComposer,
          $$LocalShoppingItemsTableOrderingComposer,
          $$LocalShoppingItemsTableAnnotationComposer,
          $$LocalShoppingItemsTableCreateCompanionBuilder,
          $$LocalShoppingItemsTableUpdateCompanionBuilder,
          (
            LocalShoppingItem,
            BaseReferences<
              _$AppDatabase,
              $LocalShoppingItemsTable,
              LocalShoppingItem
            >,
          ),
          LocalShoppingItem,
          PrefetchHooks Function()
        > {
  $$LocalShoppingItemsTableTableManager(
    _$AppDatabase db,
    $LocalShoppingItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalShoppingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalShoppingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalShoppingItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> shoppingListId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> isChecked = const Value.absent(),
                Value<bool> isManual = const Value.absent(),
                Value<String?> planSlotId = const Value.absent(),
                Value<String?> ingredientId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalShoppingItemsCompanion(
                id: id,
                shoppingListId: shoppingListId,
                name: name,
                quantity: quantity,
                unit: unit,
                category: category,
                isChecked: isChecked,
                isManual: isManual,
                planSlotId: planSlotId,
                ingredientId: ingredientId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String shoppingListId,
                required String name,
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> isChecked = const Value.absent(),
                Value<bool> isManual = const Value.absent(),
                Value<String?> planSlotId = const Value.absent(),
                Value<String?> ingredientId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalShoppingItemsCompanion.insert(
                id: id,
                shoppingListId: shoppingListId,
                name: name,
                quantity: quantity,
                unit: unit,
                category: category,
                isChecked: isChecked,
                isManual: isManual,
                planSlotId: planSlotId,
                ingredientId: ingredientId,
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

typedef $$LocalShoppingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalShoppingItemsTable,
      LocalShoppingItem,
      $$LocalShoppingItemsTableFilterComposer,
      $$LocalShoppingItemsTableOrderingComposer,
      $$LocalShoppingItemsTableAnnotationComposer,
      $$LocalShoppingItemsTableCreateCompanionBuilder,
      $$LocalShoppingItemsTableUpdateCompanionBuilder,
      (
        LocalShoppingItem,
        BaseReferences<
          _$AppDatabase,
          $LocalShoppingItemsTable,
          LocalShoppingItem
        >,
      ),
      LocalShoppingItem,
      PrefetchHooks Function()
    >;
typedef $$PendingOperationsTableCreateCompanionBuilder =
    PendingOperationsCompanion Function({
      required String id,
      required String entityType,
      required String opType,
      required String payloadJson,
      required DateTime createdAt,
      Value<int> retryCount,
      Value<int> rowid,
    });
typedef $$PendingOperationsTableUpdateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> opType,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> retryCount,
      Value<int> rowid,
    });

class $$PendingOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingOperationsTable> {
  $$PendingOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );
}

class $$PendingOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOperation,
          $$PendingOperationsTableFilterComposer,
          $$PendingOperationsTableOrderingComposer,
          $$PendingOperationsTableAnnotationComposer,
          $$PendingOperationsTableCreateCompanionBuilder,
          $$PendingOperationsTableUpdateCompanionBuilder,
          (
            PendingOperation,
            BaseReferences<
              _$AppDatabase,
              $PendingOperationsTable,
              PendingOperation
            >,
          ),
          PendingOperation,
          PrefetchHooks Function()
        > {
  $$PendingOperationsTableTableManager(
    _$AppDatabase db,
    $PendingOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingOperationsCompanion(
                id: id,
                entityType: entityType,
                opType: opType,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retryCount: retryCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String opType,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingOperationsCompanion.insert(
                id: id,
                entityType: entityType,
                opType: opType,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retryCount: retryCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingOperationsTable,
      PendingOperation,
      $$PendingOperationsTableFilterComposer,
      $$PendingOperationsTableOrderingComposer,
      $$PendingOperationsTableAnnotationComposer,
      $$PendingOperationsTableCreateCompanionBuilder,
      $$PendingOperationsTableUpdateCompanionBuilder,
      (
        PendingOperation,
        BaseReferences<
          _$AppDatabase,
          $PendingOperationsTable,
          PendingOperation
        >,
      ),
      PendingOperation,
      PrefetchHooks Function()
    >;
typedef $$IdMappingsTableCreateCompanionBuilder =
    IdMappingsCompanion Function({
      required String tempId,
      required String realId,
      Value<int> rowid,
    });
typedef $$IdMappingsTableUpdateCompanionBuilder =
    IdMappingsCompanion Function({
      Value<String> tempId,
      Value<String> realId,
      Value<int> rowid,
    });

class $$IdMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $IdMappingsTable> {
  $$IdMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tempId => $composableBuilder(
    column: $table.tempId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get realId => $composableBuilder(
    column: $table.realId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IdMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $IdMappingsTable> {
  $$IdMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tempId => $composableBuilder(
    column: $table.tempId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get realId => $composableBuilder(
    column: $table.realId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IdMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdMappingsTable> {
  $$IdMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tempId =>
      $composableBuilder(column: $table.tempId, builder: (column) => column);

  GeneratedColumn<String> get realId =>
      $composableBuilder(column: $table.realId, builder: (column) => column);
}

class $$IdMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IdMappingsTable,
          IdMapping,
          $$IdMappingsTableFilterComposer,
          $$IdMappingsTableOrderingComposer,
          $$IdMappingsTableAnnotationComposer,
          $$IdMappingsTableCreateCompanionBuilder,
          $$IdMappingsTableUpdateCompanionBuilder,
          (
            IdMapping,
            BaseReferences<_$AppDatabase, $IdMappingsTable, IdMapping>,
          ),
          IdMapping,
          PrefetchHooks Function()
        > {
  $$IdMappingsTableTableManager(_$AppDatabase db, $IdMappingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdMappingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tempId = const Value.absent(),
                Value<String> realId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdMappingsCompanion(
                tempId: tempId,
                realId: realId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tempId,
                required String realId,
                Value<int> rowid = const Value.absent(),
              }) => IdMappingsCompanion.insert(
                tempId: tempId,
                realId: realId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IdMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IdMappingsTable,
      IdMapping,
      $$IdMappingsTableFilterComposer,
      $$IdMappingsTableOrderingComposer,
      $$IdMappingsTableAnnotationComposer,
      $$IdMappingsTableCreateCompanionBuilder,
      $$IdMappingsTableUpdateCompanionBuilder,
      (IdMapping, BaseReferences<_$AppDatabase, $IdMappingsTable, IdMapping>),
      IdMapping,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalRecipesTableTableManager get localRecipes =>
      $$LocalRecipesTableTableManager(_db, _db.localRecipes);
  $$LocalIngredientsTableTableManager get localIngredients =>
      $$LocalIngredientsTableTableManager(_db, _db.localIngredients);
  $$LocalRecipeStepsTableTableManager get localRecipeSteps =>
      $$LocalRecipeStepsTableTableManager(_db, _db.localRecipeSteps);
  $$LocalNutritionInfoTableTableManager get localNutritionInfo =>
      $$LocalNutritionInfoTableTableManager(_db, _db.localNutritionInfo);
  $$LocalWeeklyPlansTableTableManager get localWeeklyPlans =>
      $$LocalWeeklyPlansTableTableManager(_db, _db.localWeeklyPlans);
  $$LocalPlanSlotsTableTableManager get localPlanSlots =>
      $$LocalPlanSlotsTableTableManager(_db, _db.localPlanSlots);
  $$LocalShoppingListsTableTableManager get localShoppingLists =>
      $$LocalShoppingListsTableTableManager(_db, _db.localShoppingLists);
  $$LocalShoppingItemsTableTableManager get localShoppingItems =>
      $$LocalShoppingItemsTableTableManager(_db, _db.localShoppingItems);
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(_db, _db.pendingOperations);
  $$IdMappingsTableTableManager get idMappings =>
      $$IdMappingsTableTableManager(_db, _db.idMappings);
}
