// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class Profiles extends Table with TableInfo<Profiles, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Profiles(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL PRIMARY KEY CHECK (length(trim(profile_id)) > 0)',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _avatarKeyMeta = const VerificationMeta(
    'avatarKey',
  );
  late final GeneratedColumn<String> avatarKey = GeneratedColumn<String>(
    'avatar_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'neko\' CHECK (avatar_key IN (\'neko\', \'piggy\', \'kuma\', \'boba\'))',
    defaultValue: const CustomExpression('\'neko\''),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(currency_code) = 3 AND currency_code GLOB \'[A-Z][A-Z][A-Z]\')',
  );
  static const VerificationMeta _currencyScaleMeta = const VerificationMeta(
    'currencyScale',
  );
  late final GeneratedColumn<int> currencyScale = GeneratedColumn<int>(
    'currency_scale',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (currency_scale BETWEEN 0 AND 4)',
  );
  static const VerificationMeta _autoSavingsMeta = const VerificationMeta(
    'autoSavings',
  );
  late final GeneratedColumn<int> autoSavings = GeneratedColumn<int>(
    'auto_savings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (auto_savings IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _autoSavingsSinceMeta = const VerificationMeta(
    'autoSavingsSince',
  );
  late final GeneratedColumn<String> autoSavingsSince = GeneratedColumn<String>(
    'auto_savings_since',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (local_revision > 0)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  late final GeneratedColumn<int> isSynced = GeneratedColumn<int>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    name,
    avatarKey,
    currencyCode,
    currencyScale,
    autoSavings,
    autoSavingsSince,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_key')) {
      context.handle(
        _avatarKeyMeta,
        avatarKey.isAcceptableOrUnknown(data['avatar_key']!, _avatarKeyMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('currency_scale')) {
      context.handle(
        _currencyScaleMeta,
        currencyScale.isAcceptableOrUnknown(
          data['currency_scale']!,
          _currencyScaleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyScaleMeta);
    }
    if (data.containsKey('auto_savings')) {
      context.handle(
        _autoSavingsMeta,
        autoSavings.isAcceptableOrUnknown(
          data['auto_savings']!,
          _autoSavingsMeta,
        ),
      );
    }
    if (data.containsKey('auto_savings_since')) {
      context.handle(
        _autoSavingsSinceMeta,
        autoSavingsSince.isAcceptableOrUnknown(
          data['auto_savings_since']!,
          _autoSavingsSinceMeta,
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_key'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      currencyScale: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}currency_scale'],
      )!,
      autoSavings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_savings'],
      )!,
      autoSavingsSince: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_savings_since'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  Profiles createAlias(String alias) {
    return Profiles(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Profile extends DataClass implements Insertable<Profile> {
  final String profileId;
  final String name;
  final String avatarKey;
  final String currencyCode;
  final int currencyScale;
  final int autoSavings;
  final String? autoSavingsSince;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int localRevision;
  final int isSynced;
  const Profile({
    required this.profileId,
    required this.name,
    required this.avatarKey,
    required this.currencyCode,
    required this.currencyScale,
    required this.autoSavings,
    this.autoSavingsSince,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRevision,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['name'] = Variable<String>(name);
    map['avatar_key'] = Variable<String>(avatarKey);
    map['currency_code'] = Variable<String>(currencyCode);
    map['currency_scale'] = Variable<int>(currencyScale);
    map['auto_savings'] = Variable<int>(autoSavings);
    if (!nullToAbsent || autoSavingsSince != null) {
      map['auto_savings_since'] = Variable<String>(autoSavingsSince);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_revision'] = Variable<int>(localRevision);
    map['is_synced'] = Variable<int>(isSynced);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      profileId: Value(profileId),
      name: Value(name),
      avatarKey: Value(avatarKey),
      currencyCode: Value(currencyCode),
      currencyScale: Value(currencyScale),
      autoSavings: Value(autoSavings),
      autoSavingsSince: autoSavingsSince == null && nullToAbsent
          ? const Value.absent()
          : Value(autoSavingsSince),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRevision: Value(localRevision),
      isSynced: Value(isSynced),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      profileId: serializer.fromJson<String>(json['profile_id']),
      name: serializer.fromJson<String>(json['name']),
      avatarKey: serializer.fromJson<String>(json['avatar_key']),
      currencyCode: serializer.fromJson<String>(json['currency_code']),
      currencyScale: serializer.fromJson<int>(json['currency_scale']),
      autoSavings: serializer.fromJson<int>(json['auto_savings']),
      autoSavingsSince: serializer.fromJson<String?>(
        json['auto_savings_since'],
      ),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      localRevision: serializer.fromJson<int>(json['local_revision']),
      isSynced: serializer.fromJson<int>(json['is_synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profile_id': serializer.toJson<String>(profileId),
      'name': serializer.toJson<String>(name),
      'avatar_key': serializer.toJson<String>(avatarKey),
      'currency_code': serializer.toJson<String>(currencyCode),
      'currency_scale': serializer.toJson<int>(currencyScale),
      'auto_savings': serializer.toJson<int>(autoSavings),
      'auto_savings_since': serializer.toJson<String?>(autoSavingsSince),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'local_revision': serializer.toJson<int>(localRevision),
      'is_synced': serializer.toJson<int>(isSynced),
    };
  }

  Profile copyWith({
    String? profileId,
    String? name,
    String? avatarKey,
    String? currencyCode,
    int? currencyScale,
    int? autoSavings,
    Value<String?> autoSavingsSince = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? localRevision,
    int? isSynced,
  }) => Profile(
    profileId: profileId ?? this.profileId,
    name: name ?? this.name,
    avatarKey: avatarKey ?? this.avatarKey,
    currencyCode: currencyCode ?? this.currencyCode,
    currencyScale: currencyScale ?? this.currencyScale,
    autoSavings: autoSavings ?? this.autoSavings,
    autoSavingsSince: autoSavingsSince.present
        ? autoSavingsSince.value
        : this.autoSavingsSince,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRevision: localRevision ?? this.localRevision,
    isSynced: isSynced ?? this.isSynced,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      name: data.name.present ? data.name.value : this.name,
      avatarKey: data.avatarKey.present ? data.avatarKey.value : this.avatarKey,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      currencyScale: data.currencyScale.present
          ? data.currencyScale.value
          : this.currencyScale,
      autoSavings: data.autoSavings.present
          ? data.autoSavings.value
          : this.autoSavings,
      autoSavingsSince: data.autoSavingsSince.present
          ? data.autoSavingsSince.value
          : this.autoSavingsSince,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('avatarKey: $avatarKey, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyScale: $currencyScale, ')
          ..write('autoSavings: $autoSavings, ')
          ..write('autoSavingsSince: $autoSavingsSince, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    name,
    avatarKey,
    currencyCode,
    currencyScale,
    autoSavings,
    autoSavingsSince,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.profileId == this.profileId &&
          other.name == this.name &&
          other.avatarKey == this.avatarKey &&
          other.currencyCode == this.currencyCode &&
          other.currencyScale == this.currencyScale &&
          other.autoSavings == this.autoSavings &&
          other.autoSavingsSince == this.autoSavingsSince &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRevision == this.localRevision &&
          other.isSynced == this.isSynced);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> profileId;
  final Value<String> name;
  final Value<String> avatarKey;
  final Value<String> currencyCode;
  final Value<int> currencyScale;
  final Value<int> autoSavings;
  final Value<String?> autoSavingsSince;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> localRevision;
  final Value<int> isSynced;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.profileId = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarKey = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.currencyScale = const Value.absent(),
    this.autoSavings = const Value.absent(),
    this.autoSavingsSince = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String profileId,
    required String name,
    this.avatarKey = const Value.absent(),
    required String currencyCode,
    required int currencyScale,
    this.autoSavings = const Value.absent(),
    this.autoSavingsSince = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       name = Value(name),
       currencyCode = Value(currencyCode),
       currencyScale = Value(currencyScale),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Profile> custom({
    Expression<String>? profileId,
    Expression<String>? name,
    Expression<String>? avatarKey,
    Expression<String>? currencyCode,
    Expression<int>? currencyScale,
    Expression<int>? autoSavings,
    Expression<String>? autoSavingsSince,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localRevision,
    Expression<int>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (name != null) 'name': name,
      if (avatarKey != null) 'avatar_key': avatarKey,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (currencyScale != null) 'currency_scale': currencyScale,
      if (autoSavings != null) 'auto_savings': autoSavings,
      if (autoSavingsSince != null) 'auto_savings_since': autoSavingsSince,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRevision != null) 'local_revision': localRevision,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? profileId,
    Value<String>? name,
    Value<String>? avatarKey,
    Value<String>? currencyCode,
    Value<int>? currencyScale,
    Value<int>? autoSavings,
    Value<String?>? autoSavingsSince,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? localRevision,
    Value<int>? isSynced,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      avatarKey: avatarKey ?? this.avatarKey,
      currencyCode: currencyCode ?? this.currencyCode,
      currencyScale: currencyScale ?? this.currencyScale,
      autoSavings: autoSavings ?? this.autoSavings,
      autoSavingsSince: autoSavingsSince ?? this.autoSavingsSince,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRevision: localRevision ?? this.localRevision,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarKey.present) {
      map['avatar_key'] = Variable<String>(avatarKey.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (currencyScale.present) {
      map['currency_scale'] = Variable<int>(currencyScale.value);
    }
    if (autoSavings.present) {
      map['auto_savings'] = Variable<int>(autoSavings.value);
    }
    if (autoSavingsSince.present) {
      map['auto_savings_since'] = Variable<String>(autoSavingsSince.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<int>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('name: $name, ')
          ..write('avatarKey: $avatarKey, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('currencyScale: $currencyScale, ')
          ..write('autoSavings: $autoSavings, ')
          ..write('autoSavingsSince: $autoSavingsSince, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Categories extends Table with TableInfo<Categories, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Categories(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profiles(profile_id)',
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(category_id)) > 0)',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (type IN (\'income\', \'expense\', \'savings\'))',
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'category\'',
    defaultValue: const CustomExpression('\'category\''),
  );
  static const VerificationMeta _colorArgbMeta = const VerificationMeta(
    'colorArgb',
  );
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
    'color_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 4282365204',
    defaultValue: const CustomExpression('4282365204'),
  );
  static const VerificationMeta _defaultBudgetBucketMeta =
      const VerificationMeta('defaultBudgetBucket');
  late final GeneratedColumn<String> defaultBudgetBucket =
      GeneratedColumn<String>(
        'default_budget_bucket',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints:
            'CHECK (default_budget_bucket IN (\'needs\', \'wants\'))',
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (local_revision > 0)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  late final GeneratedColumn<int> isSynced = GeneratedColumn<int>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    categoryId,
    name,
    type,
    iconKey,
    colorArgb,
    defaultBudgetBucket,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
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
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('color_argb')) {
      context.handle(
        _colorArgbMeta,
        colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta),
      );
    }
    if (data.containsKey('default_budget_bucket')) {
      context.handle(
        _defaultBudgetBucketMeta,
        defaultBudgetBucket.isAcceptableOrUnknown(
          data['default_budget_bucket']!,
          _defaultBudgetBucketMeta,
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, categoryId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {profileId, categoryId, type},
  ];
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_argb'],
      )!,
      defaultBudgetBucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_budget_bucket'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  Categories createAlias(String alias) {
    return Categories(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, category_id)',
    'UNIQUE(profile_id, category_id, type)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Category extends DataClass implements Insertable<Category> {
  final String profileId;
  final String categoryId;
  final String name;
  final String type;
  final String iconKey;
  final int colorArgb;
  final String? defaultBudgetBucket;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int localRevision;
  final int isSynced;
  const Category({
    required this.profileId,
    required this.categoryId,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorArgb,
    this.defaultBudgetBucket,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRevision,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['icon_key'] = Variable<String>(iconKey);
    map['color_argb'] = Variable<int>(colorArgb);
    if (!nullToAbsent || defaultBudgetBucket != null) {
      map['default_budget_bucket'] = Variable<String>(defaultBudgetBucket);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_revision'] = Variable<int>(localRevision);
    map['is_synced'] = Variable<int>(isSynced);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      profileId: Value(profileId),
      categoryId: Value(categoryId),
      name: Value(name),
      type: Value(type),
      iconKey: Value(iconKey),
      colorArgb: Value(colorArgb),
      defaultBudgetBucket: defaultBudgetBucket == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultBudgetBucket),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRevision: Value(localRevision),
      isSynced: Value(isSynced),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      profileId: serializer.fromJson<String>(json['profile_id']),
      categoryId: serializer.fromJson<String>(json['category_id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      iconKey: serializer.fromJson<String>(json['icon_key']),
      colorArgb: serializer.fromJson<int>(json['color_argb']),
      defaultBudgetBucket: serializer.fromJson<String?>(
        json['default_budget_bucket'],
      ),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      localRevision: serializer.fromJson<int>(json['local_revision']),
      isSynced: serializer.fromJson<int>(json['is_synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profile_id': serializer.toJson<String>(profileId),
      'category_id': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon_key': serializer.toJson<String>(iconKey),
      'color_argb': serializer.toJson<int>(colorArgb),
      'default_budget_bucket': serializer.toJson<String?>(defaultBudgetBucket),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'local_revision': serializer.toJson<int>(localRevision),
      'is_synced': serializer.toJson<int>(isSynced),
    };
  }

  Category copyWith({
    String? profileId,
    String? categoryId,
    String? name,
    String? type,
    String? iconKey,
    int? colorArgb,
    Value<String?> defaultBudgetBucket = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? localRevision,
    int? isSynced,
  }) => Category(
    profileId: profileId ?? this.profileId,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    type: type ?? this.type,
    iconKey: iconKey ?? this.iconKey,
    colorArgb: colorArgb ?? this.colorArgb,
    defaultBudgetBucket: defaultBudgetBucket.present
        ? defaultBudgetBucket.value
        : this.defaultBudgetBucket,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRevision: localRevision ?? this.localRevision,
    isSynced: isSynced ?? this.isSynced,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
      defaultBudgetBucket: data.defaultBudgetBucket.present
          ? data.defaultBudgetBucket.value
          : this.defaultBudgetBucket,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('profileId: $profileId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('defaultBudgetBucket: $defaultBudgetBucket, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    categoryId,
    name,
    type,
    iconKey,
    colorArgb,
    defaultBudgetBucket,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.profileId == this.profileId &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.type == this.type &&
          other.iconKey == this.iconKey &&
          other.colorArgb == this.colorArgb &&
          other.defaultBudgetBucket == this.defaultBudgetBucket &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRevision == this.localRevision &&
          other.isSynced == this.isSynced);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> profileId;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> iconKey;
  final Value<int> colorArgb;
  final Value<String?> defaultBudgetBucket;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> localRevision;
  final Value<int> isSynced;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.profileId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.defaultBudgetBucket = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String profileId,
    required String categoryId,
    required String name,
    required String type,
    this.iconKey = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.defaultBudgetBucket = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       categoryId = Value(categoryId),
       name = Value(name),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Category> custom({
    Expression<String>? profileId,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? iconKey,
    Expression<int>? colorArgb,
    Expression<String>? defaultBudgetBucket,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localRevision,
    Expression<int>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorArgb != null) 'color_argb': colorArgb,
      if (defaultBudgetBucket != null)
        'default_budget_bucket': defaultBudgetBucket,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRevision != null) 'local_revision': localRevision,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? profileId,
    Value<String>? categoryId,
    Value<String>? name,
    Value<String>? type,
    Value<String>? iconKey,
    Value<int>? colorArgb,
    Value<String?>? defaultBudgetBucket,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? localRevision,
    Value<int>? isSynced,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      profileId: profileId ?? this.profileId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      type: type ?? this.type,
      iconKey: iconKey ?? this.iconKey,
      colorArgb: colorArgb ?? this.colorArgb,
      defaultBudgetBucket: defaultBudgetBucket ?? this.defaultBudgetBucket,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRevision: localRevision ?? this.localRevision,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    if (defaultBudgetBucket.present) {
      map['default_budget_bucket'] = Variable<String>(
        defaultBudgetBucket.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<int>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('defaultBudgetBucket: $defaultBudgetBucket, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Transactions extends Table with TableInfo<Transactions, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Transactions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profiles(profile_id)',
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(transaction_id)) > 0)',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_minor > 0)',
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (type IN (\'income\', \'expense\', \'savings\'))',
  );
  static const VerificationMeta _savingsMonthMeta = const VerificationMeta(
    'savingsMonth',
  );
  late final GeneratedColumn<String> savingsMonth = GeneratedColumn<String>(
    'savings_month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (local_revision > 0)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  late final GeneratedColumn<int> isSynced = GeneratedColumn<int>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    transactionId,
    notes,
    amountMinor,
    type,
    savingsMonth,
    categoryId,
    occurredAt,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('savings_month')) {
      context.handle(
        _savingsMonthMeta,
        savingsMonth.isAcceptableOrUnknown(
          data['savings_month']!,
          _savingsMonthMeta,
        ),
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
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, transactionId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {profileId, savingsMonth},
  ];
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      savingsMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}savings_month'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  Transactions createAlias(String alias) {
    return Transactions(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, transaction_id)',
    'UNIQUE(profile_id, savings_month)',
    'FOREIGN KEY(profile_id, category_id, type)REFERENCES categories(profile_id, category_id, type)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String profileId;
  final String transactionId;
  final String notes;
  final int amountMinor;
  final String type;
  final String? savingsMonth;
  final String categoryId;
  final int occurredAt;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int localRevision;
  final int isSynced;
  const Transaction({
    required this.profileId,
    required this.transactionId,
    required this.notes,
    required this.amountMinor,
    required this.type,
    this.savingsMonth,
    required this.categoryId,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRevision,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['transaction_id'] = Variable<String>(transactionId);
    map['notes'] = Variable<String>(notes);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || savingsMonth != null) {
      map['savings_month'] = Variable<String>(savingsMonth);
    }
    map['category_id'] = Variable<String>(categoryId);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_revision'] = Variable<int>(localRevision);
    map['is_synced'] = Variable<int>(isSynced);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      profileId: Value(profileId),
      transactionId: Value(transactionId),
      notes: Value(notes),
      amountMinor: Value(amountMinor),
      type: Value(type),
      savingsMonth: savingsMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(savingsMonth),
      categoryId: Value(categoryId),
      occurredAt: Value(occurredAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRevision: Value(localRevision),
      isSynced: Value(isSynced),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      profileId: serializer.fromJson<String>(json['profile_id']),
      transactionId: serializer.fromJson<String>(json['transaction_id']),
      notes: serializer.fromJson<String>(json['notes']),
      amountMinor: serializer.fromJson<int>(json['amount_minor']),
      type: serializer.fromJson<String>(json['type']),
      savingsMonth: serializer.fromJson<String?>(json['savings_month']),
      categoryId: serializer.fromJson<String>(json['category_id']),
      occurredAt: serializer.fromJson<int>(json['occurred_at']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      localRevision: serializer.fromJson<int>(json['local_revision']),
      isSynced: serializer.fromJson<int>(json['is_synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profile_id': serializer.toJson<String>(profileId),
      'transaction_id': serializer.toJson<String>(transactionId),
      'notes': serializer.toJson<String>(notes),
      'amount_minor': serializer.toJson<int>(amountMinor),
      'type': serializer.toJson<String>(type),
      'savings_month': serializer.toJson<String?>(savingsMonth),
      'category_id': serializer.toJson<String>(categoryId),
      'occurred_at': serializer.toJson<int>(occurredAt),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'local_revision': serializer.toJson<int>(localRevision),
      'is_synced': serializer.toJson<int>(isSynced),
    };
  }

  Transaction copyWith({
    String? profileId,
    String? transactionId,
    String? notes,
    int? amountMinor,
    String? type,
    Value<String?> savingsMonth = const Value.absent(),
    String? categoryId,
    int? occurredAt,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? localRevision,
    int? isSynced,
  }) => Transaction(
    profileId: profileId ?? this.profileId,
    transactionId: transactionId ?? this.transactionId,
    notes: notes ?? this.notes,
    amountMinor: amountMinor ?? this.amountMinor,
    type: type ?? this.type,
    savingsMonth: savingsMonth.present ? savingsMonth.value : this.savingsMonth,
    categoryId: categoryId ?? this.categoryId,
    occurredAt: occurredAt ?? this.occurredAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRevision: localRevision ?? this.localRevision,
    isSynced: isSynced ?? this.isSynced,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      notes: data.notes.present ? data.notes.value : this.notes,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      type: data.type.present ? data.type.value : this.type,
      savingsMonth: data.savingsMonth.present
          ? data.savingsMonth.value
          : this.savingsMonth,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('profileId: $profileId, ')
          ..write('transactionId: $transactionId, ')
          ..write('notes: $notes, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('type: $type, ')
          ..write('savingsMonth: $savingsMonth, ')
          ..write('categoryId: $categoryId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    transactionId,
    notes,
    amountMinor,
    type,
    savingsMonth,
    categoryId,
    occurredAt,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.profileId == this.profileId &&
          other.transactionId == this.transactionId &&
          other.notes == this.notes &&
          other.amountMinor == this.amountMinor &&
          other.type == this.type &&
          other.savingsMonth == this.savingsMonth &&
          other.categoryId == this.categoryId &&
          other.occurredAt == this.occurredAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRevision == this.localRevision &&
          other.isSynced == this.isSynced);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> profileId;
  final Value<String> transactionId;
  final Value<String> notes;
  final Value<int> amountMinor;
  final Value<String> type;
  final Value<String?> savingsMonth;
  final Value<String> categoryId;
  final Value<int> occurredAt;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> localRevision;
  final Value<int> isSynced;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.profileId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.notes = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.type = const Value.absent(),
    this.savingsMonth = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String profileId,
    required String transactionId,
    this.notes = const Value.absent(),
    required int amountMinor,
    required String type,
    this.savingsMonth = const Value.absent(),
    required String categoryId,
    required int occurredAt,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       transactionId = Value(transactionId),
       amountMinor = Value(amountMinor),
       type = Value(type),
       categoryId = Value(categoryId),
       occurredAt = Value(occurredAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Transaction> custom({
    Expression<String>? profileId,
    Expression<String>? transactionId,
    Expression<String>? notes,
    Expression<int>? amountMinor,
    Expression<String>? type,
    Expression<String>? savingsMonth,
    Expression<String>? categoryId,
    Expression<int>? occurredAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localRevision,
    Expression<int>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (notes != null) 'notes': notes,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (type != null) 'type': type,
      if (savingsMonth != null) 'savings_month': savingsMonth,
      if (categoryId != null) 'category_id': categoryId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRevision != null) 'local_revision': localRevision,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? profileId,
    Value<String>? transactionId,
    Value<String>? notes,
    Value<int>? amountMinor,
    Value<String>? type,
    Value<String?>? savingsMonth,
    Value<String>? categoryId,
    Value<int>? occurredAt,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? localRevision,
    Value<int>? isSynced,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      profileId: profileId ?? this.profileId,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
      amountMinor: amountMinor ?? this.amountMinor,
      type: type ?? this.type,
      savingsMonth: savingsMonth ?? this.savingsMonth,
      categoryId: categoryId ?? this.categoryId,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRevision: localRevision ?? this.localRevision,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (savingsMonth.present) {
      map['savings_month'] = Variable<String>(savingsMonth.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<int>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('transactionId: $transactionId, ')
          ..write('notes: $notes, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('type: $type, ')
          ..write('savingsMonth: $savingsMonth, ')
          ..write('categoryId: $categoryId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Budgets extends Table with TableInfo<Budgets, Budget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Budgets(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profiles(profile_id)',
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(budget_id)) > 0)',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  late final GeneratedColumn<int> periodStart = GeneratedColumn<int>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _periodEndMeta = const VerificationMeta(
    'periodEnd',
  );
  late final GeneratedColumn<int> periodEnd = GeneratedColumn<int>(
    'period_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (period_end > period_start)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (local_revision > 0)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  late final GeneratedColumn<int> isSynced = GeneratedColumn<int>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    budgetId,
    name,
    periodStart,
    periodEnd,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Budget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(
        _periodEndMeta,
        periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta),
      );
    } else if (isInserting) {
      context.missing(_periodEndMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, budgetId};
  @override
  Budget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Budget(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_start'],
      )!,
      periodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_end'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  Budgets createAlias(String alias) {
    return Budgets(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, budget_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Budget extends DataClass implements Insertable<Budget> {
  final String profileId;
  final String budgetId;
  final String name;
  final int periodStart;
  final int periodEnd;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int localRevision;
  final int isSynced;
  const Budget({
    required this.profileId,
    required this.budgetId,
    required this.name,
    required this.periodStart,
    required this.periodEnd,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRevision,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['budget_id'] = Variable<String>(budgetId);
    map['name'] = Variable<String>(name);
    map['period_start'] = Variable<int>(periodStart);
    map['period_end'] = Variable<int>(periodEnd);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_revision'] = Variable<int>(localRevision);
    map['is_synced'] = Variable<int>(isSynced);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      profileId: Value(profileId),
      budgetId: Value(budgetId),
      name: Value(name),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRevision: Value(localRevision),
      isSynced: Value(isSynced),
    );
  }

  factory Budget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Budget(
      profileId: serializer.fromJson<String>(json['profile_id']),
      budgetId: serializer.fromJson<String>(json['budget_id']),
      name: serializer.fromJson<String>(json['name']),
      periodStart: serializer.fromJson<int>(json['period_start']),
      periodEnd: serializer.fromJson<int>(json['period_end']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      localRevision: serializer.fromJson<int>(json['local_revision']),
      isSynced: serializer.fromJson<int>(json['is_synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profile_id': serializer.toJson<String>(profileId),
      'budget_id': serializer.toJson<String>(budgetId),
      'name': serializer.toJson<String>(name),
      'period_start': serializer.toJson<int>(periodStart),
      'period_end': serializer.toJson<int>(periodEnd),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'local_revision': serializer.toJson<int>(localRevision),
      'is_synced': serializer.toJson<int>(isSynced),
    };
  }

  Budget copyWith({
    String? profileId,
    String? budgetId,
    String? name,
    int? periodStart,
    int? periodEnd,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? localRevision,
    int? isSynced,
  }) => Budget(
    profileId: profileId ?? this.profileId,
    budgetId: budgetId ?? this.budgetId,
    name: name ?? this.name,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRevision: localRevision ?? this.localRevision,
    isSynced: isSynced ?? this.isSynced,
  );
  Budget copyWithCompanion(BudgetsCompanion data) {
    return Budget(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      name: data.name.present ? data.name.value : this.name,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Budget(')
          ..write('profileId: $profileId, ')
          ..write('budgetId: $budgetId, ')
          ..write('name: $name, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    budgetId,
    name,
    periodStart,
    periodEnd,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Budget &&
          other.profileId == this.profileId &&
          other.budgetId == this.budgetId &&
          other.name == this.name &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRevision == this.localRevision &&
          other.isSynced == this.isSynced);
}

class BudgetsCompanion extends UpdateCompanion<Budget> {
  final Value<String> profileId;
  final Value<String> budgetId;
  final Value<String> name;
  final Value<int> periodStart;
  final Value<int> periodEnd;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> localRevision;
  final Value<int> isSynced;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.profileId = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.name = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String profileId,
    required String budgetId,
    required String name,
    required int periodStart,
    required int periodEnd,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       budgetId = Value(budgetId),
       name = Value(name),
       periodStart = Value(periodStart),
       periodEnd = Value(periodEnd),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Budget> custom({
    Expression<String>? profileId,
    Expression<String>? budgetId,
    Expression<String>? name,
    Expression<int>? periodStart,
    Expression<int>? periodEnd,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localRevision,
    Expression<int>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (budgetId != null) 'budget_id': budgetId,
      if (name != null) 'name': name,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRevision != null) 'local_revision': localRevision,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? profileId,
    Value<String>? budgetId,
    Value<String>? name,
    Value<int>? periodStart,
    Value<int>? periodEnd,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? localRevision,
    Value<int>? isSynced,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      profileId: profileId ?? this.profileId,
      budgetId: budgetId ?? this.budgetId,
      name: name ?? this.name,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRevision: localRevision ?? this.localRevision,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<int>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<int>(periodEnd.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<int>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('budgetId: $budgetId, ')
          ..write('name: $name, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BudgetBuckets extends Table with TableInfo<BudgetBuckets, BudgetBucket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BudgetBuckets(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bucketIdMeta = const VerificationMeta(
    'bucketId',
  );
  late final GeneratedColumn<String> bucketId = GeneratedColumn<String>(
    'bucket_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(bucket_id)) > 0)',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _allocationBpsMeta = const VerificationMeta(
    'allocationBps',
  );
  late final GeneratedColumn<int> allocationBps = GeneratedColumn<int>(
    'allocation_bps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (allocation_bps BETWEEN 0 AND 10000)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (local_revision > 0)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  late final GeneratedColumn<int> isSynced = GeneratedColumn<int>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    budgetId,
    bucketId,
    name,
    allocationBps,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_buckets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetBucket> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('bucket_id')) {
      context.handle(
        _bucketIdMeta,
        bucketId.isAcceptableOrUnknown(data['bucket_id']!, _bucketIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bucketIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('allocation_bps')) {
      context.handle(
        _allocationBpsMeta,
        allocationBps.isAcceptableOrUnknown(
          data['allocation_bps']!,
          _allocationBpsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allocationBpsMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, budgetId, bucketId};
  @override
  BudgetBucket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetBucket(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      )!,
      bucketId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      allocationBps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allocation_bps'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  BudgetBuckets createAlias(String alias) {
    return BudgetBuckets(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, budget_id, bucket_id)',
    'FOREIGN KEY(profile_id, budget_id)REFERENCES budgets(profile_id, budget_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class BudgetBucket extends DataClass implements Insertable<BudgetBucket> {
  final String profileId;
  final String budgetId;
  final String bucketId;
  final String name;
  final int allocationBps;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int localRevision;
  final int isSynced;
  const BudgetBucket({
    required this.profileId,
    required this.budgetId,
    required this.bucketId,
    required this.name,
    required this.allocationBps,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRevision,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['budget_id'] = Variable<String>(budgetId);
    map['bucket_id'] = Variable<String>(bucketId);
    map['name'] = Variable<String>(name);
    map['allocation_bps'] = Variable<int>(allocationBps);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_revision'] = Variable<int>(localRevision);
    map['is_synced'] = Variable<int>(isSynced);
    return map;
  }

  BudgetBucketsCompanion toCompanion(bool nullToAbsent) {
    return BudgetBucketsCompanion(
      profileId: Value(profileId),
      budgetId: Value(budgetId),
      bucketId: Value(bucketId),
      name: Value(name),
      allocationBps: Value(allocationBps),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRevision: Value(localRevision),
      isSynced: Value(isSynced),
    );
  }

  factory BudgetBucket.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetBucket(
      profileId: serializer.fromJson<String>(json['profile_id']),
      budgetId: serializer.fromJson<String>(json['budget_id']),
      bucketId: serializer.fromJson<String>(json['bucket_id']),
      name: serializer.fromJson<String>(json['name']),
      allocationBps: serializer.fromJson<int>(json['allocation_bps']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      localRevision: serializer.fromJson<int>(json['local_revision']),
      isSynced: serializer.fromJson<int>(json['is_synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profile_id': serializer.toJson<String>(profileId),
      'budget_id': serializer.toJson<String>(budgetId),
      'bucket_id': serializer.toJson<String>(bucketId),
      'name': serializer.toJson<String>(name),
      'allocation_bps': serializer.toJson<int>(allocationBps),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'local_revision': serializer.toJson<int>(localRevision),
      'is_synced': serializer.toJson<int>(isSynced),
    };
  }

  BudgetBucket copyWith({
    String? profileId,
    String? budgetId,
    String? bucketId,
    String? name,
    int? allocationBps,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? localRevision,
    int? isSynced,
  }) => BudgetBucket(
    profileId: profileId ?? this.profileId,
    budgetId: budgetId ?? this.budgetId,
    bucketId: bucketId ?? this.bucketId,
    name: name ?? this.name,
    allocationBps: allocationBps ?? this.allocationBps,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRevision: localRevision ?? this.localRevision,
    isSynced: isSynced ?? this.isSynced,
  );
  BudgetBucket copyWithCompanion(BudgetBucketsCompanion data) {
    return BudgetBucket(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      bucketId: data.bucketId.present ? data.bucketId.value : this.bucketId,
      name: data.name.present ? data.name.value : this.name,
      allocationBps: data.allocationBps.present
          ? data.allocationBps.value
          : this.allocationBps,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetBucket(')
          ..write('profileId: $profileId, ')
          ..write('budgetId: $budgetId, ')
          ..write('bucketId: $bucketId, ')
          ..write('name: $name, ')
          ..write('allocationBps: $allocationBps, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    budgetId,
    bucketId,
    name,
    allocationBps,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetBucket &&
          other.profileId == this.profileId &&
          other.budgetId == this.budgetId &&
          other.bucketId == this.bucketId &&
          other.name == this.name &&
          other.allocationBps == this.allocationBps &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRevision == this.localRevision &&
          other.isSynced == this.isSynced);
}

class BudgetBucketsCompanion extends UpdateCompanion<BudgetBucket> {
  final Value<String> profileId;
  final Value<String> budgetId;
  final Value<String> bucketId;
  final Value<String> name;
  final Value<int> allocationBps;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> localRevision;
  final Value<int> isSynced;
  final Value<int> rowid;
  const BudgetBucketsCompanion({
    this.profileId = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.bucketId = const Value.absent(),
    this.name = const Value.absent(),
    this.allocationBps = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetBucketsCompanion.insert({
    required String profileId,
    required String budgetId,
    required String bucketId,
    required String name,
    required int allocationBps,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       budgetId = Value(budgetId),
       bucketId = Value(bucketId),
       name = Value(name),
       allocationBps = Value(allocationBps),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BudgetBucket> custom({
    Expression<String>? profileId,
    Expression<String>? budgetId,
    Expression<String>? bucketId,
    Expression<String>? name,
    Expression<int>? allocationBps,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localRevision,
    Expression<int>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (budgetId != null) 'budget_id': budgetId,
      if (bucketId != null) 'bucket_id': bucketId,
      if (name != null) 'name': name,
      if (allocationBps != null) 'allocation_bps': allocationBps,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRevision != null) 'local_revision': localRevision,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetBucketsCompanion copyWith({
    Value<String>? profileId,
    Value<String>? budgetId,
    Value<String>? bucketId,
    Value<String>? name,
    Value<int>? allocationBps,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? localRevision,
    Value<int>? isSynced,
    Value<int>? rowid,
  }) {
    return BudgetBucketsCompanion(
      profileId: profileId ?? this.profileId,
      budgetId: budgetId ?? this.budgetId,
      bucketId: bucketId ?? this.bucketId,
      name: name ?? this.name,
      allocationBps: allocationBps ?? this.allocationBps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRevision: localRevision ?? this.localRevision,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (bucketId.present) {
      map['bucket_id'] = Variable<String>(bucketId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (allocationBps.present) {
      map['allocation_bps'] = Variable<int>(allocationBps.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<int>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetBucketsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('budgetId: $budgetId, ')
          ..write('bucketId: $bucketId, ')
          ..write('name: $name, ')
          ..write('allocationBps: $allocationBps, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BudgetCategoryAllocations extends Table
    with TableInfo<BudgetCategoryAllocations, BudgetCategoryAllocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BudgetCategoryAllocations(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _bucketIdMeta = const VerificationMeta(
    'bucketId',
  );
  late final GeneratedColumn<String> bucketId = GeneratedColumn<String>(
    'bucket_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (local_revision > 0)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  late final GeneratedColumn<int> isSynced = GeneratedColumn<int>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    budgetId,
    bucketId,
    categoryId,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_category_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetCategoryAllocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('bucket_id')) {
      context.handle(
        _bucketIdMeta,
        bucketId.isAcceptableOrUnknown(data['bucket_id']!, _bucketIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bucketIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, budgetId, categoryId};
  @override
  BudgetCategoryAllocation map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetCategoryAllocation(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      )!,
      bucketId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  BudgetCategoryAllocations createAlias(String alias) {
    return BudgetCategoryAllocations(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, budget_id, category_id)',
    'FOREIGN KEY(profile_id, budget_id, bucket_id)REFERENCES budget_buckets(profile_id, budget_id, bucket_id)',
    'FOREIGN KEY(profile_id, category_id)REFERENCES categories(profile_id, category_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class BudgetCategoryAllocation extends DataClass
    implements Insertable<BudgetCategoryAllocation> {
  final String profileId;
  final String budgetId;
  final String bucketId;
  final String categoryId;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int localRevision;
  final int isSynced;
  const BudgetCategoryAllocation({
    required this.profileId,
    required this.budgetId,
    required this.bucketId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRevision,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['budget_id'] = Variable<String>(budgetId);
    map['bucket_id'] = Variable<String>(bucketId);
    map['category_id'] = Variable<String>(categoryId);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_revision'] = Variable<int>(localRevision);
    map['is_synced'] = Variable<int>(isSynced);
    return map;
  }

  BudgetCategoryAllocationsCompanion toCompanion(bool nullToAbsent) {
    return BudgetCategoryAllocationsCompanion(
      profileId: Value(profileId),
      budgetId: Value(budgetId),
      bucketId: Value(bucketId),
      categoryId: Value(categoryId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRevision: Value(localRevision),
      isSynced: Value(isSynced),
    );
  }

  factory BudgetCategoryAllocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetCategoryAllocation(
      profileId: serializer.fromJson<String>(json['profile_id']),
      budgetId: serializer.fromJson<String>(json['budget_id']),
      bucketId: serializer.fromJson<String>(json['bucket_id']),
      categoryId: serializer.fromJson<String>(json['category_id']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      localRevision: serializer.fromJson<int>(json['local_revision']),
      isSynced: serializer.fromJson<int>(json['is_synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profile_id': serializer.toJson<String>(profileId),
      'budget_id': serializer.toJson<String>(budgetId),
      'bucket_id': serializer.toJson<String>(bucketId),
      'category_id': serializer.toJson<String>(categoryId),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'local_revision': serializer.toJson<int>(localRevision),
      'is_synced': serializer.toJson<int>(isSynced),
    };
  }

  BudgetCategoryAllocation copyWith({
    String? profileId,
    String? budgetId,
    String? bucketId,
    String? categoryId,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? localRevision,
    int? isSynced,
  }) => BudgetCategoryAllocation(
    profileId: profileId ?? this.profileId,
    budgetId: budgetId ?? this.budgetId,
    bucketId: bucketId ?? this.bucketId,
    categoryId: categoryId ?? this.categoryId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRevision: localRevision ?? this.localRevision,
    isSynced: isSynced ?? this.isSynced,
  );
  BudgetCategoryAllocation copyWithCompanion(
    BudgetCategoryAllocationsCompanion data,
  ) {
    return BudgetCategoryAllocation(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      bucketId: data.bucketId.present ? data.bucketId.value : this.bucketId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetCategoryAllocation(')
          ..write('profileId: $profileId, ')
          ..write('budgetId: $budgetId, ')
          ..write('bucketId: $bucketId, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    budgetId,
    bucketId,
    categoryId,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetCategoryAllocation &&
          other.profileId == this.profileId &&
          other.budgetId == this.budgetId &&
          other.bucketId == this.bucketId &&
          other.categoryId == this.categoryId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRevision == this.localRevision &&
          other.isSynced == this.isSynced);
}

class BudgetCategoryAllocationsCompanion
    extends UpdateCompanion<BudgetCategoryAllocation> {
  final Value<String> profileId;
  final Value<String> budgetId;
  final Value<String> bucketId;
  final Value<String> categoryId;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> localRevision;
  final Value<int> isSynced;
  final Value<int> rowid;
  const BudgetCategoryAllocationsCompanion({
    this.profileId = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.bucketId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetCategoryAllocationsCompanion.insert({
    required String profileId,
    required String budgetId,
    required String bucketId,
    required String categoryId,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       budgetId = Value(budgetId),
       bucketId = Value(bucketId),
       categoryId = Value(categoryId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BudgetCategoryAllocation> custom({
    Expression<String>? profileId,
    Expression<String>? budgetId,
    Expression<String>? bucketId,
    Expression<String>? categoryId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localRevision,
    Expression<int>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (budgetId != null) 'budget_id': budgetId,
      if (bucketId != null) 'bucket_id': bucketId,
      if (categoryId != null) 'category_id': categoryId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRevision != null) 'local_revision': localRevision,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetCategoryAllocationsCompanion copyWith({
    Value<String>? profileId,
    Value<String>? budgetId,
    Value<String>? bucketId,
    Value<String>? categoryId,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? localRevision,
    Value<int>? isSynced,
    Value<int>? rowid,
  }) {
    return BudgetCategoryAllocationsCompanion(
      profileId: profileId ?? this.profileId,
      budgetId: budgetId ?? this.budgetId,
      bucketId: bucketId ?? this.bucketId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRevision: localRevision ?? this.localRevision,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (bucketId.present) {
      map['bucket_id'] = Variable<String>(bucketId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<int>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetCategoryAllocationsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('budgetId: $budgetId, ')
          ..write('bucketId: $bucketId, ')
          ..write('categoryId: $categoryId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TransactionSchedules extends Table
    with TableInfo<TransactionSchedules, TransactionSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TransactionSchedules(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES profiles(profile_id)',
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
    'schedule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(schedule_id)) > 0)',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (length(trim(name)) > 0)',
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'\'',
    defaultValue: const CustomExpression('\'\''),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_minor > 0)',
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (type IN (\'income\', \'expense\', \'savings\'))',
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _repeatUnitMeta = const VerificationMeta(
    'repeatUnit',
  );
  late final GeneratedColumn<String> repeatUnit = GeneratedColumn<String>(
    'repeat_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (repeat_unit IN (\'once\', \'day\', \'week\', \'month\', \'year\'))',
  );
  static const VerificationMeta _repeatIntervalMeta = const VerificationMeta(
    'repeatInterval',
  );
  late final GeneratedColumn<int> repeatInterval = GeneratedColumn<int>(
    'repeat_interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (repeat_interval BETWEEN 1 AND 999)',
  );
  static const VerificationMeta _automaticMeta = const VerificationMeta(
    'automatic',
  );
  late final GeneratedColumn<int> automatic = GeneratedColumn<int>(
    'automatic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (automatic IN (0, 1))',
  );
  static const VerificationMeta _nextIndexMeta = const VerificationMeta(
    'nextIndex',
  );
  late final GeneratedColumn<int> nextIndex = GeneratedColumn<int>(
    'next_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (next_index >= 0)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _pausedMeta = const VerificationMeta('paused');
  late final GeneratedColumn<int> paused = GeneratedColumn<int>(
    'paused',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (paused IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _localRevisionMeta = const VerificationMeta(
    'localRevision',
  );
  late final GeneratedColumn<int> localRevision = GeneratedColumn<int>(
    'local_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (local_revision > 0)',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  late final GeneratedColumn<int> isSynced = GeneratedColumn<int>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_synced IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    scheduleId,
    name,
    notes,
    amountMinor,
    type,
    categoryId,
    startDate,
    endDate,
    repeatUnit,
    repeatInterval,
    automatic,
    nextIndex,
    paused,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('repeat_unit')) {
      context.handle(
        _repeatUnitMeta,
        repeatUnit.isAcceptableOrUnknown(data['repeat_unit']!, _repeatUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_repeatUnitMeta);
    }
    if (data.containsKey('repeat_interval')) {
      context.handle(
        _repeatIntervalMeta,
        repeatInterval.isAcceptableOrUnknown(
          data['repeat_interval']!,
          _repeatIntervalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repeatIntervalMeta);
    }
    if (data.containsKey('automatic')) {
      context.handle(
        _automaticMeta,
        automatic.isAcceptableOrUnknown(data['automatic']!, _automaticMeta),
      );
    } else if (isInserting) {
      context.missing(_automaticMeta);
    }
    if (data.containsKey('next_index')) {
      context.handle(
        _nextIndexMeta,
        nextIndex.isAcceptableOrUnknown(data['next_index']!, _nextIndexMeta),
      );
    }
    if (data.containsKey('paused')) {
      context.handle(
        _pausedMeta,
        paused.isAcceptableOrUnknown(data['paused']!, _pausedMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('local_revision')) {
      context.handle(
        _localRevisionMeta,
        localRevision.isAcceptableOrUnknown(
          data['local_revision']!,
          _localRevisionMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, scheduleId};
  @override
  TransactionSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionSchedule(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      repeatUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_unit'],
      )!,
      repeatInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_interval'],
      )!,
      automatic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}automatic'],
      )!,
      nextIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_index'],
      )!,
      paused: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      localRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_revision'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  TransactionSchedules createAlias(String alias) {
    return TransactionSchedules(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, schedule_id)',
    'FOREIGN KEY(profile_id, category_id, type)REFERENCES categories(profile_id, category_id, type)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class TransactionSchedule extends DataClass
    implements Insertable<TransactionSchedule> {
  final String profileId;
  final String scheduleId;
  final String name;
  final String notes;
  final int amountMinor;
  final String type;
  final String categoryId;
  final String startDate;
  final String? endDate;
  final String repeatUnit;
  final int repeatInterval;
  final int automatic;
  final int nextIndex;
  final int paused;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final int localRevision;
  final int isSynced;
  const TransactionSchedule({
    required this.profileId,
    required this.scheduleId,
    required this.name,
    required this.notes,
    required this.amountMinor,
    required this.type,
    required this.categoryId,
    required this.startDate,
    this.endDate,
    required this.repeatUnit,
    required this.repeatInterval,
    required this.automatic,
    required this.nextIndex,
    required this.paused,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.localRevision,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['schedule_id'] = Variable<String>(scheduleId);
    map['name'] = Variable<String>(name);
    map['notes'] = Variable<String>(notes);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['type'] = Variable<String>(type);
    map['category_id'] = Variable<String>(categoryId);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['repeat_unit'] = Variable<String>(repeatUnit);
    map['repeat_interval'] = Variable<int>(repeatInterval);
    map['automatic'] = Variable<int>(automatic);
    map['next_index'] = Variable<int>(nextIndex);
    map['paused'] = Variable<int>(paused);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['local_revision'] = Variable<int>(localRevision);
    map['is_synced'] = Variable<int>(isSynced);
    return map;
  }

  TransactionSchedulesCompanion toCompanion(bool nullToAbsent) {
    return TransactionSchedulesCompanion(
      profileId: Value(profileId),
      scheduleId: Value(scheduleId),
      name: Value(name),
      notes: Value(notes),
      amountMinor: Value(amountMinor),
      type: Value(type),
      categoryId: Value(categoryId),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      repeatUnit: Value(repeatUnit),
      repeatInterval: Value(repeatInterval),
      automatic: Value(automatic),
      nextIndex: Value(nextIndex),
      paused: Value(paused),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      localRevision: Value(localRevision),
      isSynced: Value(isSynced),
    );
  }

  factory TransactionSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionSchedule(
      profileId: serializer.fromJson<String>(json['profile_id']),
      scheduleId: serializer.fromJson<String>(json['schedule_id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String>(json['notes']),
      amountMinor: serializer.fromJson<int>(json['amount_minor']),
      type: serializer.fromJson<String>(json['type']),
      categoryId: serializer.fromJson<String>(json['category_id']),
      startDate: serializer.fromJson<String>(json['start_date']),
      endDate: serializer.fromJson<String?>(json['end_date']),
      repeatUnit: serializer.fromJson<String>(json['repeat_unit']),
      repeatInterval: serializer.fromJson<int>(json['repeat_interval']),
      automatic: serializer.fromJson<int>(json['automatic']),
      nextIndex: serializer.fromJson<int>(json['next_index']),
      paused: serializer.fromJson<int>(json['paused']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      localRevision: serializer.fromJson<int>(json['local_revision']),
      isSynced: serializer.fromJson<int>(json['is_synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profile_id': serializer.toJson<String>(profileId),
      'schedule_id': serializer.toJson<String>(scheduleId),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String>(notes),
      'amount_minor': serializer.toJson<int>(amountMinor),
      'type': serializer.toJson<String>(type),
      'category_id': serializer.toJson<String>(categoryId),
      'start_date': serializer.toJson<String>(startDate),
      'end_date': serializer.toJson<String?>(endDate),
      'repeat_unit': serializer.toJson<String>(repeatUnit),
      'repeat_interval': serializer.toJson<int>(repeatInterval),
      'automatic': serializer.toJson<int>(automatic),
      'next_index': serializer.toJson<int>(nextIndex),
      'paused': serializer.toJson<int>(paused),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'local_revision': serializer.toJson<int>(localRevision),
      'is_synced': serializer.toJson<int>(isSynced),
    };
  }

  TransactionSchedule copyWith({
    String? profileId,
    String? scheduleId,
    String? name,
    String? notes,
    int? amountMinor,
    String? type,
    String? categoryId,
    String? startDate,
    Value<String?> endDate = const Value.absent(),
    String? repeatUnit,
    int? repeatInterval,
    int? automatic,
    int? nextIndex,
    int? paused,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? localRevision,
    int? isSynced,
  }) => TransactionSchedule(
    profileId: profileId ?? this.profileId,
    scheduleId: scheduleId ?? this.scheduleId,
    name: name ?? this.name,
    notes: notes ?? this.notes,
    amountMinor: amountMinor ?? this.amountMinor,
    type: type ?? this.type,
    categoryId: categoryId ?? this.categoryId,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    repeatUnit: repeatUnit ?? this.repeatUnit,
    repeatInterval: repeatInterval ?? this.repeatInterval,
    automatic: automatic ?? this.automatic,
    nextIndex: nextIndex ?? this.nextIndex,
    paused: paused ?? this.paused,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    localRevision: localRevision ?? this.localRevision,
    isSynced: isSynced ?? this.isSynced,
  );
  TransactionSchedule copyWithCompanion(TransactionSchedulesCompanion data) {
    return TransactionSchedule(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      type: data.type.present ? data.type.value : this.type,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      repeatUnit: data.repeatUnit.present
          ? data.repeatUnit.value
          : this.repeatUnit,
      repeatInterval: data.repeatInterval.present
          ? data.repeatInterval.value
          : this.repeatInterval,
      automatic: data.automatic.present ? data.automatic.value : this.automatic,
      nextIndex: data.nextIndex.present ? data.nextIndex.value : this.nextIndex,
      paused: data.paused.present ? data.paused.value : this.paused,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      localRevision: data.localRevision.present
          ? data.localRevision.value
          : this.localRevision,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionSchedule(')
          ..write('profileId: $profileId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('repeatUnit: $repeatUnit, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('automatic: $automatic, ')
          ..write('nextIndex: $nextIndex, ')
          ..write('paused: $paused, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    scheduleId,
    name,
    notes,
    amountMinor,
    type,
    categoryId,
    startDate,
    endDate,
    repeatUnit,
    repeatInterval,
    automatic,
    nextIndex,
    paused,
    createdAt,
    updatedAt,
    deletedAt,
    localRevision,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionSchedule &&
          other.profileId == this.profileId &&
          other.scheduleId == this.scheduleId &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.amountMinor == this.amountMinor &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.repeatUnit == this.repeatUnit &&
          other.repeatInterval == this.repeatInterval &&
          other.automatic == this.automatic &&
          other.nextIndex == this.nextIndex &&
          other.paused == this.paused &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.localRevision == this.localRevision &&
          other.isSynced == this.isSynced);
}

class TransactionSchedulesCompanion
    extends UpdateCompanion<TransactionSchedule> {
  final Value<String> profileId;
  final Value<String> scheduleId;
  final Value<String> name;
  final Value<String> notes;
  final Value<int> amountMinor;
  final Value<String> type;
  final Value<String> categoryId;
  final Value<String> startDate;
  final Value<String?> endDate;
  final Value<String> repeatUnit;
  final Value<int> repeatInterval;
  final Value<int> automatic;
  final Value<int> nextIndex;
  final Value<int> paused;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<int> localRevision;
  final Value<int> isSynced;
  final Value<int> rowid;
  const TransactionSchedulesCompanion({
    this.profileId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.repeatUnit = const Value.absent(),
    this.repeatInterval = const Value.absent(),
    this.automatic = const Value.absent(),
    this.nextIndex = const Value.absent(),
    this.paused = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionSchedulesCompanion.insert({
    required String profileId,
    required String scheduleId,
    required String name,
    this.notes = const Value.absent(),
    required int amountMinor,
    required String type,
    required String categoryId,
    required String startDate,
    this.endDate = const Value.absent(),
    required String repeatUnit,
    required int repeatInterval,
    required int automatic,
    this.nextIndex = const Value.absent(),
    this.paused = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.localRevision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       scheduleId = Value(scheduleId),
       name = Value(name),
       amountMinor = Value(amountMinor),
       type = Value(type),
       categoryId = Value(categoryId),
       startDate = Value(startDate),
       repeatUnit = Value(repeatUnit),
       repeatInterval = Value(repeatInterval),
       automatic = Value(automatic),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TransactionSchedule> custom({
    Expression<String>? profileId,
    Expression<String>? scheduleId,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<int>? amountMinor,
    Expression<String>? type,
    Expression<String>? categoryId,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? repeatUnit,
    Expression<int>? repeatInterval,
    Expression<int>? automatic,
    Expression<int>? nextIndex,
    Expression<int>? paused,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? localRevision,
    Expression<int>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (repeatUnit != null) 'repeat_unit': repeatUnit,
      if (repeatInterval != null) 'repeat_interval': repeatInterval,
      if (automatic != null) 'automatic': automatic,
      if (nextIndex != null) 'next_index': nextIndex,
      if (paused != null) 'paused': paused,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (localRevision != null) 'local_revision': localRevision,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionSchedulesCompanion copyWith({
    Value<String>? profileId,
    Value<String>? scheduleId,
    Value<String>? name,
    Value<String>? notes,
    Value<int>? amountMinor,
    Value<String>? type,
    Value<String>? categoryId,
    Value<String>? startDate,
    Value<String?>? endDate,
    Value<String>? repeatUnit,
    Value<int>? repeatInterval,
    Value<int>? automatic,
    Value<int>? nextIndex,
    Value<int>? paused,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<int>? localRevision,
    Value<int>? isSynced,
    Value<int>? rowid,
  }) {
    return TransactionSchedulesCompanion(
      profileId: profileId ?? this.profileId,
      scheduleId: scheduleId ?? this.scheduleId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      amountMinor: amountMinor ?? this.amountMinor,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      repeatUnit: repeatUnit ?? this.repeatUnit,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      automatic: automatic ?? this.automatic,
      nextIndex: nextIndex ?? this.nextIndex,
      paused: paused ?? this.paused,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      localRevision: localRevision ?? this.localRevision,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (repeatUnit.present) {
      map['repeat_unit'] = Variable<String>(repeatUnit.value);
    }
    if (repeatInterval.present) {
      map['repeat_interval'] = Variable<int>(repeatInterval.value);
    }
    if (automatic.present) {
      map['automatic'] = Variable<int>(automatic.value);
    }
    if (nextIndex.present) {
      map['next_index'] = Variable<int>(nextIndex.value);
    }
    if (paused.present) {
      map['paused'] = Variable<int>(paused.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (localRevision.present) {
      map['local_revision'] = Variable<int>(localRevision.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<int>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionSchedulesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('repeatUnit: $repeatUnit, ')
          ..write('repeatInterval: $repeatInterval, ')
          ..write('automatic: $automatic, ')
          ..write('nextIndex: $nextIndex, ')
          ..write('paused: $paused, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('localRevision: $localRevision, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ScheduleOccurrences extends Table
    with TableInfo<ScheduleOccurrences, ScheduleOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ScheduleOccurrences(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
    'schedule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _occurrenceIndexMeta = const VerificationMeta(
    'occurrenceIndex',
  );
  late final GeneratedColumn<int> occurrenceIndex = GeneratedColumn<int>(
    'occurrence_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (occurrence_index >= 0)',
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  late final GeneratedColumn<int> resolvedAt = GeneratedColumn<int>(
    'resolved_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    profileId,
    scheduleId,
    occurrenceIndex,
    dueDate,
    transactionId,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleIdMeta);
    }
    if (data.containsKey('occurrence_index')) {
      context.handle(
        _occurrenceIndexMeta,
        occurrenceIndex.isAcceptableOrUnknown(
          data['occurrence_index']!,
          _occurrenceIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceIndexMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_resolvedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    profileId,
    scheduleId,
    occurrenceIndex,
  };
  @override
  ScheduleOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleOccurrence(
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_id'],
      )!,
      occurrenceIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurrence_index'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_at'],
      )!,
    );
  }

  @override
  ScheduleOccurrences createAlias(String alias) {
    return ScheduleOccurrences(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(profile_id, schedule_id, occurrence_index)',
    'FOREIGN KEY(profile_id, schedule_id)REFERENCES transaction_schedules(profile_id, schedule_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class ScheduleOccurrence extends DataClass
    implements Insertable<ScheduleOccurrence> {
  final String profileId;
  final String scheduleId;
  final int occurrenceIndex;
  final String dueDate;
  final String? transactionId;
  final int resolvedAt;
  const ScheduleOccurrence({
    required this.profileId,
    required this.scheduleId,
    required this.occurrenceIndex,
    required this.dueDate,
    this.transactionId,
    required this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['schedule_id'] = Variable<String>(scheduleId);
    map['occurrence_index'] = Variable<int>(occurrenceIndex);
    map['due_date'] = Variable<String>(dueDate);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    map['resolved_at'] = Variable<int>(resolvedAt);
    return map;
  }

  ScheduleOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return ScheduleOccurrencesCompanion(
      profileId: Value(profileId),
      scheduleId: Value(scheduleId),
      occurrenceIndex: Value(occurrenceIndex),
      dueDate: Value(dueDate),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      resolvedAt: Value(resolvedAt),
    );
  }

  factory ScheduleOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleOccurrence(
      profileId: serializer.fromJson<String>(json['profile_id']),
      scheduleId: serializer.fromJson<String>(json['schedule_id']),
      occurrenceIndex: serializer.fromJson<int>(json['occurrence_index']),
      dueDate: serializer.fromJson<String>(json['due_date']),
      transactionId: serializer.fromJson<String?>(json['transaction_id']),
      resolvedAt: serializer.fromJson<int>(json['resolved_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profile_id': serializer.toJson<String>(profileId),
      'schedule_id': serializer.toJson<String>(scheduleId),
      'occurrence_index': serializer.toJson<int>(occurrenceIndex),
      'due_date': serializer.toJson<String>(dueDate),
      'transaction_id': serializer.toJson<String?>(transactionId),
      'resolved_at': serializer.toJson<int>(resolvedAt),
    };
  }

  ScheduleOccurrence copyWith({
    String? profileId,
    String? scheduleId,
    int? occurrenceIndex,
    String? dueDate,
    Value<String?> transactionId = const Value.absent(),
    int? resolvedAt,
  }) => ScheduleOccurrence(
    profileId: profileId ?? this.profileId,
    scheduleId: scheduleId ?? this.scheduleId,
    occurrenceIndex: occurrenceIndex ?? this.occurrenceIndex,
    dueDate: dueDate ?? this.dueDate,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    resolvedAt: resolvedAt ?? this.resolvedAt,
  );
  ScheduleOccurrence copyWithCompanion(ScheduleOccurrencesCompanion data) {
    return ScheduleOccurrence(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      occurrenceIndex: data.occurrenceIndex.present
          ? data.occurrenceIndex.value
          : this.occurrenceIndex,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleOccurrence(')
          ..write('profileId: $profileId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('occurrenceIndex: $occurrenceIndex, ')
          ..write('dueDate: $dueDate, ')
          ..write('transactionId: $transactionId, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    profileId,
    scheduleId,
    occurrenceIndex,
    dueDate,
    transactionId,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleOccurrence &&
          other.profileId == this.profileId &&
          other.scheduleId == this.scheduleId &&
          other.occurrenceIndex == this.occurrenceIndex &&
          other.dueDate == this.dueDate &&
          other.transactionId == this.transactionId &&
          other.resolvedAt == this.resolvedAt);
}

class ScheduleOccurrencesCompanion extends UpdateCompanion<ScheduleOccurrence> {
  final Value<String> profileId;
  final Value<String> scheduleId;
  final Value<int> occurrenceIndex;
  final Value<String> dueDate;
  final Value<String?> transactionId;
  final Value<int> resolvedAt;
  final Value<int> rowid;
  const ScheduleOccurrencesCompanion({
    this.profileId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.occurrenceIndex = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleOccurrencesCompanion.insert({
    required String profileId,
    required String scheduleId,
    required int occurrenceIndex,
    required String dueDate,
    this.transactionId = const Value.absent(),
    required int resolvedAt,
    this.rowid = const Value.absent(),
  }) : profileId = Value(profileId),
       scheduleId = Value(scheduleId),
       occurrenceIndex = Value(occurrenceIndex),
       dueDate = Value(dueDate),
       resolvedAt = Value(resolvedAt);
  static Insertable<ScheduleOccurrence> custom({
    Expression<String>? profileId,
    Expression<String>? scheduleId,
    Expression<int>? occurrenceIndex,
    Expression<String>? dueDate,
    Expression<String>? transactionId,
    Expression<int>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (occurrenceIndex != null) 'occurrence_index': occurrenceIndex,
      if (dueDate != null) 'due_date': dueDate,
      if (transactionId != null) 'transaction_id': transactionId,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleOccurrencesCompanion copyWith({
    Value<String>? profileId,
    Value<String>? scheduleId,
    Value<int>? occurrenceIndex,
    Value<String>? dueDate,
    Value<String?>? transactionId,
    Value<int>? resolvedAt,
    Value<int>? rowid,
  }) {
    return ScheduleOccurrencesCompanion(
      profileId: profileId ?? this.profileId,
      scheduleId: scheduleId ?? this.scheduleId,
      occurrenceIndex: occurrenceIndex ?? this.occurrenceIndex,
      dueDate: dueDate ?? this.dueDate,
      transactionId: transactionId ?? this.transactionId,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (occurrenceIndex.present) {
      map['occurrence_index'] = Variable<int>(occurrenceIndex.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<int>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleOccurrencesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('occurrenceIndex: $occurrenceIndex, ')
          ..write('dueDate: $dueDate, ')
          ..write('transactionId: $transactionId, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final Profiles profiles = Profiles(this);
  late final Categories categories = Categories(this);
  late final Transactions transactions = Transactions(this);
  late final Index transactionsProfileDate = Index(
    'transactions_profile_date',
    'CREATE INDEX transactions_profile_date ON transactions (profile_id, occurred_at)',
  );
  late final Budgets budgets = Budgets(this);
  late final BudgetBuckets budgetBuckets = BudgetBuckets(this);
  late final BudgetCategoryAllocations budgetCategoryAllocations =
      BudgetCategoryAllocations(this);
  late final TransactionSchedules transactionSchedules = TransactionSchedules(
    this,
  );
  late final ScheduleOccurrences scheduleOccurrences = ScheduleOccurrences(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    categories,
    transactions,
    transactionsProfileDate,
    budgets,
    budgetBuckets,
    budgetCategoryAllocations,
    transactionSchedules,
    scheduleOccurrences,
  ];
}

typedef $ProfilesCreateCompanionBuilder = ProfilesCompanion Function({
  required String profileId,
  required String name,
  Value<String> avatarKey,
  required String currencyCode,
  required int currencyScale,
  Value<int> autoSavings,
  Value<String?> autoSavingsSince,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> localRevision,
  Value<int> isSynced,
  Value<int> rowid,
});
typedef $ProfilesUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> profileId,
  Value<String> name,
  Value<String> avatarKey,
  Value<String> currencyCode,
  Value<int> currencyScale,
  Value<int> autoSavings,
  Value<String?> autoSavingsSince,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> localRevision,
  Value<int> isSynced,
  Value<int> rowid,
});

final class $ProfilesReferences
    extends BaseReferences<_$AppDatabase, Profiles, Profile> {
  $ProfilesReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Categories, List<Category>> _categoriesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.categories,
    aliasName: 'profiles__profile_id__categories__profile_id',
  );

  $CategoriesProcessedTableManager get categoriesRefs {
    final manager = $CategoriesTableManager($_db, $_db.categories).filter(
      (f) =>
          f.profileId.profileId.sqlEquals($_itemColumn<String>('profile_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_categoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Transactions, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'profiles__profile_id__transactions__profile_id',
  );

  $TransactionsProcessedTableManager get transactionsRefs {
    final manager = $TransactionsTableManager($_db, $_db.transactions).filter(
      (f) =>
          f.profileId.profileId.sqlEquals($_itemColumn<String>('profile_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Budgets, List<Budget>> _budgetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.budgets,
    aliasName: 'profiles__profile_id__budgets__profile_id',
  );

  $BudgetsProcessedTableManager get budgetsRefs {
    final manager = $BudgetsTableManager($_db, $_db.budgets).filter(
      (f) =>
          f.profileId.profileId.sqlEquals($_itemColumn<String>('profile_id')!),
    );

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<TransactionSchedules, List<TransactionSchedule>>
  _transactionSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionSchedules,
        aliasName: 'profiles__profile_id__transaction_schedules__profile_id',
      );

  $TransactionSchedulesProcessedTableManager get transactionSchedulesRefs {
    final manager =
        $TransactionSchedulesTableManager(
          $_db,
          $_db.transactionSchedules,
        ).filter(
          (f) => f.profileId.profileId.sqlEquals(
            $_itemColumn<String>('profile_id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _transactionSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ProfilesFilterComposer extends Composer<_$AppDatabase, Profiles> {
  $ProfilesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarKey => $composableBuilder(
    column: $table.avatarKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currencyScale => $composableBuilder(
    column: $table.currencyScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoSavings => $composableBuilder(
    column: $table.autoSavings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autoSavingsSince => $composableBuilder(
    column: $table.autoSavingsSince,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> categoriesRefs(
    Expression<bool> Function($CategoriesFilterComposer f) f,
  ) {
    final $CategoriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CategoriesFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($TransactionsFilterComposer f) f,
  ) {
    final $TransactionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TransactionsFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> budgetsRefs(
    Expression<bool> Function($BudgetsFilterComposer f) f,
  ) {
    final $BudgetsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BudgetsFilterComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionSchedulesRefs(
    Expression<bool> Function($TransactionSchedulesFilterComposer f) f,
  ) {
    final $TransactionSchedulesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.transactionSchedules,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TransactionSchedulesFilterComposer(
            $db: $db,
            $table: $db.transactionSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ProfilesOrderingComposer extends Composer<_$AppDatabase, Profiles> {
  $ProfilesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarKey => $composableBuilder(
    column: $table.avatarKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currencyScale => $composableBuilder(
    column: $table.currencyScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoSavings => $composableBuilder(
    column: $table.autoSavings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoSavingsSince => $composableBuilder(
    column: $table.autoSavingsSince,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ProfilesAnnotationComposer extends Composer<_$AppDatabase, Profiles> {
  $ProfilesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarKey =>
      $composableBuilder(column: $table.avatarKey, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currencyScale => $composableBuilder(
    column: $table.currencyScale,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoSavings => $composableBuilder(
    column: $table.autoSavings,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autoSavingsSince => $composableBuilder(
    column: $table.autoSavingsSince,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> categoriesRefs<T extends Object>(
    Expression<T> Function($CategoriesAnnotationComposer a) f,
  ) {
    final $CategoriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CategoriesAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($TransactionsAnnotationComposer a) f,
  ) {
    final $TransactionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TransactionsAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
    Expression<T> Function($BudgetsAnnotationComposer a) f,
  ) {
    final $BudgetsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.budgets,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $BudgetsAnnotationComposer(
            $db: $db,
            $table: $db.budgets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionSchedulesRefs<T extends Object>(
    Expression<T> Function($TransactionSchedulesAnnotationComposer a) f,
  ) {
    final $TransactionSchedulesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.transactionSchedules,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TransactionSchedulesAnnotationComposer(
            $db: $db,
            $table: $db.transactionSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ProfilesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Profiles,
          Profile,
          $ProfilesFilterComposer,
          $ProfilesOrderingComposer,
          $ProfilesAnnotationComposer,
          $ProfilesCreateCompanionBuilder,
          $ProfilesUpdateCompanionBuilder,
          (Profile, $ProfilesReferences),
          Profile,
          PrefetchHooks Function({
            bool categoriesRefs,
            bool transactionsRefs,
            bool budgetsRefs,
            bool transactionSchedulesRefs,
          })
        > {
  $ProfilesTableManager(_$AppDatabase db, Profiles table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ProfilesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ProfilesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ProfilesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> avatarKey = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> currencyScale = const Value.absent(),
                Value<int> autoSavings = const Value.absent(),
                Value<String?> autoSavingsSince = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                profileId: profileId,
                name: name,
                avatarKey: avatarKey,
                currencyCode: currencyCode,
                currencyScale: currencyScale,
                autoSavings: autoSavings,
                autoSavingsSince: autoSavingsSince,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String name,
                Value<String> avatarKey = const Value.absent(),
                required String currencyCode,
                required int currencyScale,
                Value<int> autoSavings = const Value.absent(),
                Value<String?> autoSavingsSince = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                profileId: profileId,
                name: name,
                avatarKey: avatarKey,
                currencyCode: currencyCode,
                currencyScale: currencyScale,
                autoSavings: autoSavings,
                autoSavingsSince: autoSavingsSince,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Profiles, Profile>(table),
                  $ProfilesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoriesRefs = false,
                transactionsRefs = false,
                budgetsRefs = false,
                transactionSchedulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (categoriesRefs) db.categories,
                    if (transactionsRefs) db.transactions,
                    if (budgetsRefs) db.budgets,
                    if (transactionSchedulesRefs) db.transactionSchedules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (categoriesRefs)
                        await $_getPrefetchedData<Profile, Profiles, Category>(
                          currentTable: table,
                          referencedTable: $ProfilesReferences
                              ._categoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ProfilesReferences(db, table, p0).categoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.profileId,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Profile,
                          Profiles,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $ProfilesReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) => $ProfilesReferences(
                            db,
                            table,
                            p0,
                          ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.profileId,
                              ),
                          typedResults: items,
                        ),
                      if (budgetsRefs)
                        await $_getPrefetchedData<Profile, Profiles, Budget>(
                          currentTable: table,
                          referencedTable: $ProfilesReferences
                              ._budgetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ProfilesReferences(db, table, p0).budgetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.profileId,
                              ),
                          typedResults: items,
                        ),
                      if (transactionSchedulesRefs)
                        await $_getPrefetchedData<
                          Profile,
                          Profiles,
                          TransactionSchedule
                        >(
                          currentTable: table,
                          referencedTable: $ProfilesReferences
                              ._transactionSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) => $ProfilesReferences(
                            db,
                            table,
                            p0,
                          ).transactionSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.profileId == item.profileId,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ProfilesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Profiles,
      Profile,
      $ProfilesFilterComposer,
      $ProfilesOrderingComposer,
      $ProfilesAnnotationComposer,
      $ProfilesCreateCompanionBuilder,
      $ProfilesUpdateCompanionBuilder,
      (Profile, $ProfilesReferences),
      Profile,
      PrefetchHooks Function({
        bool categoriesRefs,
        bool transactionsRefs,
        bool budgetsRefs,
        bool transactionSchedulesRefs,
      })
    >;
typedef $CategoriesCreateCompanionBuilder = CategoriesCompanion Function({
  required String profileId,
  required String categoryId,
  required String name,
  required String type,
  Value<String> iconKey,
  Value<int> colorArgb,
  Value<String?> defaultBudgetBucket,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> localRevision,
  Value<int> isSynced,
  Value<int> rowid,
});
typedef $CategoriesUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> profileId,
  Value<String> categoryId,
  Value<String> name,
  Value<String> type,
  Value<String> iconKey,
  Value<int> colorArgb,
  Value<String?> defaultBudgetBucket,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> localRevision,
  Value<int> isSynced,
  Value<int> rowid,
});

final class $CategoriesReferences
    extends BaseReferences<_$AppDatabase, Categories, Category> {
  $CategoriesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Profiles _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('categories__profile_id__profiles__profile_id');

  $ProfilesProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $ProfilesTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.profileId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $CategoriesFilterComposer extends Composer<_$AppDatabase, Categories> {
  $CategoriesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultBudgetBucket => $composableBuilder(
    column: $table.defaultBudgetBucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $ProfilesFilterComposer get profileId {
    final $ProfilesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CategoriesOrderingComposer extends Composer<_$AppDatabase, Categories> {
  $CategoriesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultBudgetBucket => $composableBuilder(
    column: $table.defaultBudgetBucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $ProfilesOrderingComposer get profileId {
    final $ProfilesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CategoriesAnnotationComposer
    extends Composer<_$AppDatabase, Categories> {
  $CategoriesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  GeneratedColumn<String> get defaultBudgetBucket => $composableBuilder(
    column: $table.defaultBudgetBucket,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $ProfilesAnnotationComposer get profileId {
    final $ProfilesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CategoriesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Categories,
          Category,
          $CategoriesFilterComposer,
          $CategoriesOrderingComposer,
          $CategoriesAnnotationComposer,
          $CategoriesCreateCompanionBuilder,
          $CategoriesUpdateCompanionBuilder,
          (Category, $CategoriesReferences),
          Category,
          PrefetchHooks Function({bool profileId})
        > {
  $CategoriesTableManager(_$AppDatabase db, Categories table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CategoriesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CategoriesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CategoriesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
                Value<String?> defaultBudgetBucket = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                profileId: profileId,
                categoryId: categoryId,
                name: name,
                type: type,
                iconKey: iconKey,
                colorArgb: colorArgb,
                defaultBudgetBucket: defaultBudgetBucket,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String categoryId,
                required String name,
                required String type,
                Value<String> iconKey = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
                Value<String?> defaultBudgetBucket = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                profileId: profileId,
                categoryId: categoryId,
                name: name,
                type: type,
                iconKey: iconKey,
                colorArgb: colorArgb,
                defaultBudgetBucket: defaultBudgetBucket,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Categories, Category>(table),
                  $CategoriesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $CategoriesReferences._profileIdTable(
                          db,
                        ),
                        referencedColumn: $CategoriesReferences
                            ._profileIdTable(db)
                            .profileId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $CategoriesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Categories,
      Category,
      $CategoriesFilterComposer,
      $CategoriesOrderingComposer,
      $CategoriesAnnotationComposer,
      $CategoriesCreateCompanionBuilder,
      $CategoriesUpdateCompanionBuilder,
      (Category, $CategoriesReferences),
      Category,
      PrefetchHooks Function({bool profileId})
    >;
typedef $TransactionsCreateCompanionBuilder = TransactionsCompanion Function({
  required String profileId,
  required String transactionId,
  Value<String> notes,
  required int amountMinor,
  required String type,
  Value<String?> savingsMonth,
  required String categoryId,
  required int occurredAt,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> localRevision,
  Value<int> isSynced,
  Value<int> rowid,
});
typedef $TransactionsUpdateCompanionBuilder = TransactionsCompanion Function({
  Value<String> profileId,
  Value<String> transactionId,
  Value<String> notes,
  Value<int> amountMinor,
  Value<String> type,
  Value<String?> savingsMonth,
  Value<String> categoryId,
  Value<int> occurredAt,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> localRevision,
  Value<int> isSynced,
  Value<int> rowid,
});

final class $TransactionsReferences
    extends BaseReferences<_$AppDatabase, Transactions, Transaction> {
  $TransactionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Profiles _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('transactions__profile_id__profiles__profile_id');

  $ProfilesProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $ProfilesTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.profileId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $TransactionsFilterComposer
    extends Composer<_$AppDatabase, Transactions> {
  $TransactionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savingsMonth => $composableBuilder(
    column: $table.savingsMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $ProfilesFilterComposer get profileId {
    final $ProfilesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransactionsOrderingComposer
    extends Composer<_$AppDatabase, Transactions> {
  $TransactionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savingsMonth => $composableBuilder(
    column: $table.savingsMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $ProfilesOrderingComposer get profileId {
    final $ProfilesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransactionsAnnotationComposer
    extends Composer<_$AppDatabase, Transactions> {
  $TransactionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get savingsMonth => $composableBuilder(
    column: $table.savingsMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $ProfilesAnnotationComposer get profileId {
    final $ProfilesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransactionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Transactions,
          Transaction,
          $TransactionsFilterComposer,
          $TransactionsOrderingComposer,
          $TransactionsAnnotationComposer,
          $TransactionsCreateCompanionBuilder,
          $TransactionsUpdateCompanionBuilder,
          (Transaction, $TransactionsReferences),
          Transaction,
          PrefetchHooks Function({bool profileId})
        > {
  $TransactionsTableManager(_$AppDatabase db, Transactions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TransactionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TransactionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TransactionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> savingsMonth = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                profileId: profileId,
                transactionId: transactionId,
                notes: notes,
                amountMinor: amountMinor,
                type: type,
                savingsMonth: savingsMonth,
                categoryId: categoryId,
                occurredAt: occurredAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String transactionId,
                Value<String> notes = const Value.absent(),
                required int amountMinor,
                required String type,
                Value<String?> savingsMonth = const Value.absent(),
                required String categoryId,
                required int occurredAt,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                profileId: profileId,
                transactionId: transactionId,
                notes: notes,
                amountMinor: amountMinor,
                type: type,
                savingsMonth: savingsMonth,
                categoryId: categoryId,
                occurredAt: occurredAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Transactions, Transaction>(table),
                  $TransactionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $TransactionsReferences
                            ._profileIdTable(db),
                        referencedColumn: $TransactionsReferences
                            ._profileIdTable(db)
                            .profileId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $TransactionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Transactions,
      Transaction,
      $TransactionsFilterComposer,
      $TransactionsOrderingComposer,
      $TransactionsAnnotationComposer,
      $TransactionsCreateCompanionBuilder,
      $TransactionsUpdateCompanionBuilder,
      (Transaction, $TransactionsReferences),
      Transaction,
      PrefetchHooks Function({bool profileId})
    >;
typedef $BudgetsCreateCompanionBuilder = BudgetsCompanion Function({
  required String profileId,
  required String budgetId,
  required String name,
  required int periodStart,
  required int periodEnd,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> localRevision,
  Value<int> isSynced,
  Value<int> rowid,
});
typedef $BudgetsUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> profileId,
  Value<String> budgetId,
  Value<String> name,
  Value<int> periodStart,
  Value<int> periodEnd,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> localRevision,
  Value<int> isSynced,
  Value<int> rowid,
});

final class $BudgetsReferences
    extends BaseReferences<_$AppDatabase, Budgets, Budget> {
  $BudgetsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Profiles _profileIdTable(_$AppDatabase db) =>
      db.profiles.createAlias('budgets__profile_id__profiles__profile_id');

  $ProfilesProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $ProfilesTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.profileId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $BudgetsFilterComposer extends Composer<_$AppDatabase, Budgets> {
  $BudgetsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $ProfilesFilterComposer get profileId {
    final $ProfilesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BudgetsOrderingComposer extends Composer<_$AppDatabase, Budgets> {
  $BudgetsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $ProfilesOrderingComposer get profileId {
    final $ProfilesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BudgetsAnnotationComposer extends Composer<_$AppDatabase, Budgets> {
  $BudgetsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get budgetId =>
      $composableBuilder(column: $table.budgetId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $ProfilesAnnotationComposer get profileId {
    final $ProfilesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $BudgetsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Budgets,
          Budget,
          $BudgetsFilterComposer,
          $BudgetsOrderingComposer,
          $BudgetsAnnotationComposer,
          $BudgetsCreateCompanionBuilder,
          $BudgetsUpdateCompanionBuilder,
          (Budget, $BudgetsReferences),
          Budget,
          PrefetchHooks Function({bool profileId})
        > {
  $BudgetsTableManager(_$AppDatabase db, Budgets table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BudgetsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BudgetsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BudgetsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> budgetId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> periodStart = const Value.absent(),
                Value<int> periodEnd = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                profileId: profileId,
                budgetId: budgetId,
                name: name,
                periodStart: periodStart,
                periodEnd: periodEnd,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String budgetId,
                required String name,
                required int periodStart,
                required int periodEnd,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                profileId: profileId,
                budgetId: budgetId,
                name: name,
                periodStart: periodStart,
                periodEnd: periodEnd,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Budgets, Budget>(table),
                  $BudgetsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $BudgetsReferences._profileIdTable(db),
                        referencedColumn: $BudgetsReferences
                            ._profileIdTable(db)
                            .profileId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $BudgetsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Budgets,
      Budget,
      $BudgetsFilterComposer,
      $BudgetsOrderingComposer,
      $BudgetsAnnotationComposer,
      $BudgetsCreateCompanionBuilder,
      $BudgetsUpdateCompanionBuilder,
      (Budget, $BudgetsReferences),
      Budget,
      PrefetchHooks Function({bool profileId})
    >;
typedef $BudgetBucketsCreateCompanionBuilder = BudgetBucketsCompanion Function({
  required String profileId,
  required String budgetId,
  required String bucketId,
  required String name,
  required int allocationBps,
  required int createdAt,
  required int updatedAt,
  Value<int?> deletedAt,
  Value<int> localRevision,
  Value<int> isSynced,
  Value<int> rowid,
});
typedef $BudgetBucketsUpdateCompanionBuilder = BudgetBucketsCompanion Function({
  Value<String> profileId,
  Value<String> budgetId,
  Value<String> bucketId,
  Value<String> name,
  Value<int> allocationBps,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> deletedAt,
  Value<int> localRevision,
  Value<int> isSynced,
  Value<int> rowid,
});

class $BudgetBucketsFilterComposer
    extends Composer<_$AppDatabase, BudgetBuckets> {
  $BudgetBucketsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucketId => $composableBuilder(
    column: $table.bucketId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get allocationBps => $composableBuilder(
    column: $table.allocationBps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $BudgetBucketsOrderingComposer
    extends Composer<_$AppDatabase, BudgetBuckets> {
  $BudgetBucketsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucketId => $composableBuilder(
    column: $table.bucketId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get allocationBps => $composableBuilder(
    column: $table.allocationBps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $BudgetBucketsAnnotationComposer
    extends Composer<_$AppDatabase, BudgetBuckets> {
  $BudgetBucketsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get budgetId =>
      $composableBuilder(column: $table.budgetId, builder: (column) => column);

  GeneratedColumn<String> get bucketId =>
      $composableBuilder(column: $table.bucketId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get allocationBps => $composableBuilder(
    column: $table.allocationBps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $BudgetBucketsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          BudgetBuckets,
          BudgetBucket,
          $BudgetBucketsFilterComposer,
          $BudgetBucketsOrderingComposer,
          $BudgetBucketsAnnotationComposer,
          $BudgetBucketsCreateCompanionBuilder,
          $BudgetBucketsUpdateCompanionBuilder,
          (
            BudgetBucket,
            BaseReferences<_$AppDatabase, BudgetBuckets, BudgetBucket>,
          ),
          BudgetBucket,
          PrefetchHooks Function()
        > {
  $BudgetBucketsTableManager(_$AppDatabase db, BudgetBuckets table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BudgetBucketsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BudgetBucketsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BudgetBucketsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> budgetId = const Value.absent(),
                Value<String> bucketId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> allocationBps = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetBucketsCompanion(
                profileId: profileId,
                budgetId: budgetId,
                bucketId: bucketId,
                name: name,
                allocationBps: allocationBps,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String budgetId,
                required String bucketId,
                required String name,
                required int allocationBps,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetBucketsCompanion.insert(
                profileId: profileId,
                budgetId: budgetId,
                bucketId: bucketId,
                name: name,
                allocationBps: allocationBps,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<BudgetBuckets, BudgetBucket>(table),
                  BaseReferences<_$AppDatabase, BudgetBuckets, BudgetBucket>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BudgetBucketsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      BudgetBuckets,
      BudgetBucket,
      $BudgetBucketsFilterComposer,
      $BudgetBucketsOrderingComposer,
      $BudgetBucketsAnnotationComposer,
      $BudgetBucketsCreateCompanionBuilder,
      $BudgetBucketsUpdateCompanionBuilder,
      (
        BudgetBucket,
        BaseReferences<_$AppDatabase, BudgetBuckets, BudgetBucket>,
      ),
      BudgetBucket,
      PrefetchHooks Function()
    >;
typedef $BudgetCategoryAllocationsCreateCompanionBuilder =
    BudgetCategoryAllocationsCompanion Function({
      required String profileId,
      required String budgetId,
      required String bucketId,
      required String categoryId,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> localRevision,
      Value<int> isSynced,
      Value<int> rowid,
    });
typedef $BudgetCategoryAllocationsUpdateCompanionBuilder =
    BudgetCategoryAllocationsCompanion Function({
      Value<String> profileId,
      Value<String> budgetId,
      Value<String> bucketId,
      Value<String> categoryId,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> localRevision,
      Value<int> isSynced,
      Value<int> rowid,
    });

class $BudgetCategoryAllocationsFilterComposer
    extends Composer<_$AppDatabase, BudgetCategoryAllocations> {
  $BudgetCategoryAllocationsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bucketId => $composableBuilder(
    column: $table.bucketId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $BudgetCategoryAllocationsOrderingComposer
    extends Composer<_$AppDatabase, BudgetCategoryAllocations> {
  $BudgetCategoryAllocationsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bucketId => $composableBuilder(
    column: $table.bucketId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $BudgetCategoryAllocationsAnnotationComposer
    extends Composer<_$AppDatabase, BudgetCategoryAllocations> {
  $BudgetCategoryAllocationsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get budgetId =>
      $composableBuilder(column: $table.budgetId, builder: (column) => column);

  GeneratedColumn<String> get bucketId =>
      $composableBuilder(column: $table.bucketId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $BudgetCategoryAllocationsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          BudgetCategoryAllocations,
          BudgetCategoryAllocation,
          $BudgetCategoryAllocationsFilterComposer,
          $BudgetCategoryAllocationsOrderingComposer,
          $BudgetCategoryAllocationsAnnotationComposer,
          $BudgetCategoryAllocationsCreateCompanionBuilder,
          $BudgetCategoryAllocationsUpdateCompanionBuilder,
          (
            BudgetCategoryAllocation,
            BaseReferences<
              _$AppDatabase,
              BudgetCategoryAllocations,
              BudgetCategoryAllocation
            >,
          ),
          BudgetCategoryAllocation,
          PrefetchHooks Function()
        > {
  $BudgetCategoryAllocationsTableManager(
    _$AppDatabase db,
    BudgetCategoryAllocations table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BudgetCategoryAllocationsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BudgetCategoryAllocationsOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $BudgetCategoryAllocationsAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> budgetId = const Value.absent(),
                Value<String> bucketId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetCategoryAllocationsCompanion(
                profileId: profileId,
                budgetId: budgetId,
                bucketId: bucketId,
                categoryId: categoryId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String budgetId,
                required String bucketId,
                required String categoryId,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetCategoryAllocationsCompanion.insert(
                profileId: profileId,
                budgetId: budgetId,
                bucketId: bucketId,
                categoryId: categoryId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    BudgetCategoryAllocations,
                    BudgetCategoryAllocation
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    BudgetCategoryAllocations,
                    BudgetCategoryAllocation
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BudgetCategoryAllocationsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      BudgetCategoryAllocations,
      BudgetCategoryAllocation,
      $BudgetCategoryAllocationsFilterComposer,
      $BudgetCategoryAllocationsOrderingComposer,
      $BudgetCategoryAllocationsAnnotationComposer,
      $BudgetCategoryAllocationsCreateCompanionBuilder,
      $BudgetCategoryAllocationsUpdateCompanionBuilder,
      (
        BudgetCategoryAllocation,
        BaseReferences<
          _$AppDatabase,
          BudgetCategoryAllocations,
          BudgetCategoryAllocation
        >,
      ),
      BudgetCategoryAllocation,
      PrefetchHooks Function()
    >;
typedef $TransactionSchedulesCreateCompanionBuilder =
    TransactionSchedulesCompanion Function({
      required String profileId,
      required String scheduleId,
      required String name,
      Value<String> notes,
      required int amountMinor,
      required String type,
      required String categoryId,
      required String startDate,
      Value<String?> endDate,
      required String repeatUnit,
      required int repeatInterval,
      required int automatic,
      Value<int> nextIndex,
      Value<int> paused,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<int> localRevision,
      Value<int> isSynced,
      Value<int> rowid,
    });
typedef $TransactionSchedulesUpdateCompanionBuilder =
    TransactionSchedulesCompanion Function({
      Value<String> profileId,
      Value<String> scheduleId,
      Value<String> name,
      Value<String> notes,
      Value<int> amountMinor,
      Value<String> type,
      Value<String> categoryId,
      Value<String> startDate,
      Value<String?> endDate,
      Value<String> repeatUnit,
      Value<int> repeatInterval,
      Value<int> automatic,
      Value<int> nextIndex,
      Value<int> paused,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<int> localRevision,
      Value<int> isSynced,
      Value<int> rowid,
    });

final class $TransactionSchedulesReferences
    extends
        BaseReferences<
          _$AppDatabase,
          TransactionSchedules,
          TransactionSchedule
        > {
  $TransactionSchedulesReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Profiles _profileIdTable(_$AppDatabase db) => db.profiles.createAlias(
    'transaction_schedules__profile_id__profiles__profile_id',
  );

  $ProfilesProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $ProfilesTableManager(
      $_db,
      $_db.profiles,
    ).filter((f) => f.profileId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $TransactionSchedulesFilterComposer
    extends Composer<_$AppDatabase, TransactionSchedules> {
  $TransactionSchedulesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatUnit => $composableBuilder(
    column: $table.repeatUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get automatic => $composableBuilder(
    column: $table.automatic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextIndex => $composableBuilder(
    column: $table.nextIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $ProfilesFilterComposer get profileId {
    final $ProfilesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransactionSchedulesOrderingComposer
    extends Composer<_$AppDatabase, TransactionSchedules> {
  $TransactionSchedulesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatUnit => $composableBuilder(
    column: $table.repeatUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get automatic => $composableBuilder(
    column: $table.automatic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextIndex => $composableBuilder(
    column: $table.nextIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paused => $composableBuilder(
    column: $table.paused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $ProfilesOrderingComposer get profileId {
    final $ProfilesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesOrderingComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransactionSchedulesAnnotationComposer
    extends Composer<_$AppDatabase, TransactionSchedules> {
  $TransactionSchedulesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get repeatUnit => $composableBuilder(
    column: $table.repeatUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatInterval => $composableBuilder(
    column: $table.repeatInterval,
    builder: (column) => column,
  );

  GeneratedColumn<int> get automatic =>
      $composableBuilder(column: $table.automatic, builder: (column) => column);

  GeneratedColumn<int> get nextIndex =>
      $composableBuilder(column: $table.nextIndex, builder: (column) => column);

  GeneratedColumn<int> get paused =>
      $composableBuilder(column: $table.paused, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get localRevision => $composableBuilder(
    column: $table.localRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $ProfilesAnnotationComposer get profileId {
    final $ProfilesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.profileId,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.profileId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProfilesAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransactionSchedulesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          TransactionSchedules,
          TransactionSchedule,
          $TransactionSchedulesFilterComposer,
          $TransactionSchedulesOrderingComposer,
          $TransactionSchedulesAnnotationComposer,
          $TransactionSchedulesCreateCompanionBuilder,
          $TransactionSchedulesUpdateCompanionBuilder,
          (TransactionSchedule, $TransactionSchedulesReferences),
          TransactionSchedule,
          PrefetchHooks Function({bool profileId})
        > {
  $TransactionSchedulesTableManager(
    _$AppDatabase db,
    TransactionSchedules table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TransactionSchedulesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TransactionSchedulesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TransactionSchedulesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> scheduleId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<String> repeatUnit = const Value.absent(),
                Value<int> repeatInterval = const Value.absent(),
                Value<int> automatic = const Value.absent(),
                Value<int> nextIndex = const Value.absent(),
                Value<int> paused = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionSchedulesCompanion(
                profileId: profileId,
                scheduleId: scheduleId,
                name: name,
                notes: notes,
                amountMinor: amountMinor,
                type: type,
                categoryId: categoryId,
                startDate: startDate,
                endDate: endDate,
                repeatUnit: repeatUnit,
                repeatInterval: repeatInterval,
                automatic: automatic,
                nextIndex: nextIndex,
                paused: paused,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String scheduleId,
                required String name,
                Value<String> notes = const Value.absent(),
                required int amountMinor,
                required String type,
                required String categoryId,
                required String startDate,
                Value<String?> endDate = const Value.absent(),
                required String repeatUnit,
                required int repeatInterval,
                required int automatic,
                Value<int> nextIndex = const Value.absent(),
                Value<int> paused = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> localRevision = const Value.absent(),
                Value<int> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionSchedulesCompanion.insert(
                profileId: profileId,
                scheduleId: scheduleId,
                name: name,
                notes: notes,
                amountMinor: amountMinor,
                type: type,
                categoryId: categoryId,
                startDate: startDate,
                endDate: endDate,
                repeatUnit: repeatUnit,
                repeatInterval: repeatInterval,
                automatic: automatic,
                nextIndex: nextIndex,
                paused: paused,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                localRevision: localRevision,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<TransactionSchedules, TransactionSchedule>(table),
                  $TransactionSchedulesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (profileId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.profileId,
                        referencedTable: $TransactionSchedulesReferences
                            ._profileIdTable(db),
                        referencedColumn: $TransactionSchedulesReferences
                            ._profileIdTable(db)
                            .profileId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $TransactionSchedulesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      TransactionSchedules,
      TransactionSchedule,
      $TransactionSchedulesFilterComposer,
      $TransactionSchedulesOrderingComposer,
      $TransactionSchedulesAnnotationComposer,
      $TransactionSchedulesCreateCompanionBuilder,
      $TransactionSchedulesUpdateCompanionBuilder,
      (TransactionSchedule, $TransactionSchedulesReferences),
      TransactionSchedule,
      PrefetchHooks Function({bool profileId})
    >;
typedef $ScheduleOccurrencesCreateCompanionBuilder =
    ScheduleOccurrencesCompanion Function({
      required String profileId,
      required String scheduleId,
      required int occurrenceIndex,
      required String dueDate,
      Value<String?> transactionId,
      required int resolvedAt,
      Value<int> rowid,
    });
typedef $ScheduleOccurrencesUpdateCompanionBuilder =
    ScheduleOccurrencesCompanion Function({
      Value<String> profileId,
      Value<String> scheduleId,
      Value<int> occurrenceIndex,
      Value<String> dueDate,
      Value<String?> transactionId,
      Value<int> resolvedAt,
      Value<int> rowid,
    });

class $ScheduleOccurrencesFilterComposer
    extends Composer<_$AppDatabase, ScheduleOccurrences> {
  $ScheduleOccurrencesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurrenceIndex => $composableBuilder(
    column: $table.occurrenceIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $ScheduleOccurrencesOrderingComposer
    extends Composer<_$AppDatabase, ScheduleOccurrences> {
  $ScheduleOccurrencesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurrenceIndex => $composableBuilder(
    column: $table.occurrenceIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ScheduleOccurrencesAnnotationComposer
    extends Composer<_$AppDatabase, ScheduleOccurrences> {
  $ScheduleOccurrencesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get scheduleId => $composableBuilder(
    column: $table.scheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurrenceIndex => $composableBuilder(
    column: $table.occurrenceIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $ScheduleOccurrencesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          ScheduleOccurrences,
          ScheduleOccurrence,
          $ScheduleOccurrencesFilterComposer,
          $ScheduleOccurrencesOrderingComposer,
          $ScheduleOccurrencesAnnotationComposer,
          $ScheduleOccurrencesCreateCompanionBuilder,
          $ScheduleOccurrencesUpdateCompanionBuilder,
          (
            ScheduleOccurrence,
            BaseReferences<
              _$AppDatabase,
              ScheduleOccurrences,
              ScheduleOccurrence
            >,
          ),
          ScheduleOccurrence,
          PrefetchHooks Function()
        > {
  $ScheduleOccurrencesTableManager(_$AppDatabase db, ScheduleOccurrences table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ScheduleOccurrencesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ScheduleOccurrencesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ScheduleOccurrencesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> profileId = const Value.absent(),
                Value<String> scheduleId = const Value.absent(),
                Value<int> occurrenceIndex = const Value.absent(),
                Value<String> dueDate = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<int> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleOccurrencesCompanion(
                profileId: profileId,
                scheduleId: scheduleId,
                occurrenceIndex: occurrenceIndex,
                dueDate: dueDate,
                transactionId: transactionId,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String profileId,
                required String scheduleId,
                required int occurrenceIndex,
                required String dueDate,
                Value<String?> transactionId = const Value.absent(),
                required int resolvedAt,
                Value<int> rowid = const Value.absent(),
              }) => ScheduleOccurrencesCompanion.insert(
                profileId: profileId,
                scheduleId: scheduleId,
                occurrenceIndex: occurrenceIndex,
                dueDate: dueDate,
                transactionId: transactionId,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<ScheduleOccurrences, ScheduleOccurrence>(table),
                  BaseReferences<
                    _$AppDatabase,
                    ScheduleOccurrences,
                    ScheduleOccurrence
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ScheduleOccurrencesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      ScheduleOccurrences,
      ScheduleOccurrence,
      $ScheduleOccurrencesFilterComposer,
      $ScheduleOccurrencesOrderingComposer,
      $ScheduleOccurrencesAnnotationComposer,
      $ScheduleOccurrencesCreateCompanionBuilder,
      $ScheduleOccurrencesUpdateCompanionBuilder,
      (
        ScheduleOccurrence,
        BaseReferences<_$AppDatabase, ScheduleOccurrences, ScheduleOccurrence>,
      ),
      ScheduleOccurrence,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $ProfilesTableManager get profiles =>
      $ProfilesTableManager(_db, _db.profiles);
  $CategoriesTableManager get categories =>
      $CategoriesTableManager(_db, _db.categories);
  $TransactionsTableManager get transactions =>
      $TransactionsTableManager(_db, _db.transactions);
  $BudgetsTableManager get budgets => $BudgetsTableManager(_db, _db.budgets);
  $BudgetBucketsTableManager get budgetBuckets =>
      $BudgetBucketsTableManager(_db, _db.budgetBuckets);
  $BudgetCategoryAllocationsTableManager get budgetCategoryAllocations =>
      $BudgetCategoryAllocationsTableManager(
        _db,
        _db.budgetCategoryAllocations,
      );
  $TransactionSchedulesTableManager get transactionSchedules =>
      $TransactionSchedulesTableManager(_db, _db.transactionSchedules);
  $ScheduleOccurrencesTableManager get scheduleOccurrences =>
      $ScheduleOccurrencesTableManager(_db, _db.scheduleOccurrences);
}
