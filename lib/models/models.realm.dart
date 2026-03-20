// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class SongModel extends _SongModel
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  SongModel(
    Uuid id,
    String title, {
    String? textColor,
    String? key,
    String? artist,
    int? bpm,
    int? length,
    String? notes,
    String? lyrics,
    String? composer,
    String? publisher,
    String? proInfo,
    int sortOrder = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<SongModel>({'sortOrder': 0});
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'textColor', textColor);
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set(this, 'artist', artist);
    RealmObjectBase.set(this, 'bpm', bpm);
    RealmObjectBase.set(this, 'length', length);
    RealmObjectBase.set(this, 'notes', notes);
    RealmObjectBase.set(this, 'lyrics', lyrics);
    RealmObjectBase.set(this, 'composer', composer);
    RealmObjectBase.set(this, 'publisher', publisher);
    RealmObjectBase.set(this, 'proInfo', proInfo);
    RealmObjectBase.set(this, 'sortOrder', sortOrder);
  }

  SongModel._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String? get textColor =>
      RealmObjectBase.get<String>(this, 'textColor') as String?;
  @override
  set textColor(String? value) => RealmObjectBase.set(this, 'textColor', value);

  @override
  String? get key => RealmObjectBase.get<String>(this, 'key') as String?;
  @override
  set key(String? value) => RealmObjectBase.set(this, 'key', value);

  @override
  String? get artist => RealmObjectBase.get<String>(this, 'artist') as String?;
  @override
  set artist(String? value) => RealmObjectBase.set(this, 'artist', value);

  @override
  int? get bpm => RealmObjectBase.get<int>(this, 'bpm') as int?;
  @override
  set bpm(int? value) => RealmObjectBase.set(this, 'bpm', value);

  @override
  int? get length => RealmObjectBase.get<int>(this, 'length') as int?;
  @override
  set length(int? value) => RealmObjectBase.set(this, 'length', value);

  @override
  String? get notes => RealmObjectBase.get<String>(this, 'notes') as String?;
  @override
  set notes(String? value) => RealmObjectBase.set(this, 'notes', value);

  @override
  String? get lyrics => RealmObjectBase.get<String>(this, 'lyrics') as String?;
  @override
  set lyrics(String? value) => RealmObjectBase.set(this, 'lyrics', value);

  @override
  String? get composer =>
      RealmObjectBase.get<String>(this, 'composer') as String?;
  @override
  set composer(String? value) => RealmObjectBase.set(this, 'composer', value);

  @override
  String? get publisher =>
      RealmObjectBase.get<String>(this, 'publisher') as String?;
  @override
  set publisher(String? value) => RealmObjectBase.set(this, 'publisher', value);

  @override
  String? get proInfo =>
      RealmObjectBase.get<String>(this, 'proInfo') as String?;
  @override
  set proInfo(String? value) => RealmObjectBase.set(this, 'proInfo', value);

  @override
  int get sortOrder => RealmObjectBase.get<int>(this, 'sortOrder') as int;
  @override
  set sortOrder(int value) => RealmObjectBase.set(this, 'sortOrder', value);

  @override
  Stream<RealmObjectChanges<SongModel>> get changes =>
      RealmObjectBase.getChanges<SongModel>(this);

  @override
  Stream<RealmObjectChanges<SongModel>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<SongModel>(this, keyPaths);

  @override
  SongModel freeze() => RealmObjectBase.freezeObject<SongModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'title': title.toEJson(),
      'textColor': textColor.toEJson(),
      'key': key.toEJson(),
      'artist': artist.toEJson(),
      'bpm': bpm.toEJson(),
      'length': length.toEJson(),
      'notes': notes.toEJson(),
      'lyrics': lyrics.toEJson(),
      'composer': composer.toEJson(),
      'publisher': publisher.toEJson(),
      'proInfo': proInfo.toEJson(),
      'sortOrder': sortOrder.toEJson(),
    };
  }

  static EJsonValue _toEJson(SongModel value) => value.toEJson();
  static SongModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id, 'title': EJsonValue title} => SongModel(
        fromEJson(id),
        fromEJson(title),
        textColor: fromEJson(ejson['textColor']),
        key: fromEJson(ejson['key']),
        artist: fromEJson(ejson['artist']),
        bpm: fromEJson(ejson['bpm']),
        length: fromEJson(ejson['length']),
        notes: fromEJson(ejson['notes']),
        lyrics: fromEJson(ejson['lyrics']),
        composer: fromEJson(ejson['composer']),
        publisher: fromEJson(ejson['publisher']),
        proInfo: fromEJson(ejson['proInfo']),
        sortOrder: fromEJson(ejson['sortOrder'], defaultValue: 0),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SongModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, SongModel, 'SongModel', [
      SchemaProperty('id', RealmPropertyType.uuid),
      SchemaProperty('title', RealmPropertyType.string),
      SchemaProperty('textColor', RealmPropertyType.string, optional: true),
      SchemaProperty('key', RealmPropertyType.string, optional: true),
      SchemaProperty('artist', RealmPropertyType.string, optional: true),
      SchemaProperty('bpm', RealmPropertyType.int, optional: true),
      SchemaProperty('length', RealmPropertyType.int, optional: true),
      SchemaProperty('notes', RealmPropertyType.string, optional: true),
      SchemaProperty('lyrics', RealmPropertyType.string, optional: true),
      SchemaProperty('composer', RealmPropertyType.string, optional: true),
      SchemaProperty('publisher', RealmPropertyType.string, optional: true),
      SchemaProperty('proInfo', RealmPropertyType.string, optional: true),
      SchemaProperty('sortOrder', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class PlaylistModel extends _PlaylistModel
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  PlaylistModel(
    Uuid id,
    String title, {
    String? artist,
    DateTime? date,
    String? venue,
    String? city,
    bool isLocked = false,
    int sortOrder = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<PlaylistModel>({
        'isLocked': false,
        'sortOrder': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'artist', artist);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'venue', venue);
    RealmObjectBase.set(this, 'city', city);
    RealmObjectBase.set(this, 'isLocked', isLocked);
    RealmObjectBase.set(this, 'sortOrder', sortOrder);
  }

  PlaylistModel._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get title => RealmObjectBase.get<String>(this, 'title') as String;
  @override
  set title(String value) => RealmObjectBase.set(this, 'title', value);

  @override
  String? get artist => RealmObjectBase.get<String>(this, 'artist') as String?;
  @override
  set artist(String? value) => RealmObjectBase.set(this, 'artist', value);

  @override
  DateTime? get date =>
      RealmObjectBase.get<DateTime>(this, 'date') as DateTime?;
  @override
  set date(DateTime? value) => RealmObjectBase.set(this, 'date', value);

  @override
  String? get venue => RealmObjectBase.get<String>(this, 'venue') as String?;
  @override
  set venue(String? value) => RealmObjectBase.set(this, 'venue', value);

  @override
  String? get city => RealmObjectBase.get<String>(this, 'city') as String?;
  @override
  set city(String? value) => RealmObjectBase.set(this, 'city', value);

  @override
  bool get isLocked => RealmObjectBase.get<bool>(this, 'isLocked') as bool;
  @override
  set isLocked(bool value) => RealmObjectBase.set(this, 'isLocked', value);

  @override
  int get sortOrder => RealmObjectBase.get<int>(this, 'sortOrder') as int;
  @override
  set sortOrder(int value) => RealmObjectBase.set(this, 'sortOrder', value);

  @override
  Stream<RealmObjectChanges<PlaylistModel>> get changes =>
      RealmObjectBase.getChanges<PlaylistModel>(this);

  @override
  Stream<RealmObjectChanges<PlaylistModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<PlaylistModel>(this, keyPaths);

  @override
  PlaylistModel freeze() => RealmObjectBase.freezeObject<PlaylistModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'title': title.toEJson(),
      'artist': artist.toEJson(),
      'date': date.toEJson(),
      'venue': venue.toEJson(),
      'city': city.toEJson(),
      'isLocked': isLocked.toEJson(),
      'sortOrder': sortOrder.toEJson(),
    };
  }

  static EJsonValue _toEJson(PlaylistModel value) => value.toEJson();
  static PlaylistModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id, 'title': EJsonValue title} => PlaylistModel(
        fromEJson(id),
        fromEJson(title),
        artist: fromEJson(ejson['artist']),
        date: fromEJson(ejson['date']),
        venue: fromEJson(ejson['venue']),
        city: fromEJson(ejson['city']),
        isLocked: fromEJson(ejson['isLocked'], defaultValue: false),
        sortOrder: fromEJson(ejson['sortOrder'], defaultValue: 0),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PlaylistModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      PlaylistModel,
      'PlaylistModel',
      [
        SchemaProperty('id', RealmPropertyType.uuid),
        SchemaProperty('title', RealmPropertyType.string),
        SchemaProperty('artist', RealmPropertyType.string, optional: true),
        SchemaProperty('date', RealmPropertyType.timestamp, optional: true),
        SchemaProperty('venue', RealmPropertyType.string, optional: true),
        SchemaProperty('city', RealmPropertyType.string, optional: true),
        SchemaProperty('isLocked', RealmPropertyType.bool),
        SchemaProperty('sortOrder', RealmPropertyType.int),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class SetlistItemModel extends _SetlistItemModel
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  SetlistItemModel(
    Uuid id,
    String type,
    Uuid playlistId, {
    SongModel? song,
    String? label,
    String? textColor,
    int sortOrder = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<SetlistItemModel>({
        'sortOrder': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'song', song);
    RealmObjectBase.set(this, 'label', label);
    RealmObjectBase.set(this, 'textColor', textColor);
    RealmObjectBase.set(this, 'sortOrder', sortOrder);
    RealmObjectBase.set(this, 'playlistId', playlistId);
  }

  SetlistItemModel._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get type => RealmObjectBase.get<String>(this, 'type') as String;
  @override
  set type(String value) => RealmObjectBase.set(this, 'type', value);

  @override
  SongModel? get song =>
      RealmObjectBase.get<SongModel>(this, 'song') as SongModel?;
  @override
  set song(covariant SongModel? value) =>
      RealmObjectBase.set(this, 'song', value);

  @override
  String? get label => RealmObjectBase.get<String>(this, 'label') as String?;
  @override
  set label(String? value) => RealmObjectBase.set(this, 'label', value);

  @override
  String? get textColor =>
      RealmObjectBase.get<String>(this, 'textColor') as String?;
  @override
  set textColor(String? value) => RealmObjectBase.set(this, 'textColor', value);

  @override
  int get sortOrder => RealmObjectBase.get<int>(this, 'sortOrder') as int;
  @override
  set sortOrder(int value) => RealmObjectBase.set(this, 'sortOrder', value);

  @override
  Uuid get playlistId => RealmObjectBase.get<Uuid>(this, 'playlistId') as Uuid;
  @override
  set playlistId(Uuid value) => RealmObjectBase.set(this, 'playlistId', value);

  @override
  Stream<RealmObjectChanges<SetlistItemModel>> get changes =>
      RealmObjectBase.getChanges<SetlistItemModel>(this);

  @override
  Stream<RealmObjectChanges<SetlistItemModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<SetlistItemModel>(this, keyPaths);

  @override
  SetlistItemModel freeze() =>
      RealmObjectBase.freezeObject<SetlistItemModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'type': type.toEJson(),
      'song': song.toEJson(),
      'label': label.toEJson(),
      'textColor': textColor.toEJson(),
      'sortOrder': sortOrder.toEJson(),
      'playlistId': playlistId.toEJson(),
    };
  }

  static EJsonValue _toEJson(SetlistItemModel value) => value.toEJson();
  static SetlistItemModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'type': EJsonValue type,
        'playlistId': EJsonValue playlistId,
      } =>
        SetlistItemModel(
          fromEJson(id),
          fromEJson(type),
          fromEJson(playlistId),
          song: fromEJson(ejson['song']),
          label: fromEJson(ejson['label']),
          textColor: fromEJson(ejson['textColor']),
          sortOrder: fromEJson(ejson['sortOrder'], defaultValue: 0),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SetlistItemModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      SetlistItemModel,
      'SetlistItemModel',
      [
        SchemaProperty('id', RealmPropertyType.uuid),
        SchemaProperty('type', RealmPropertyType.string),
        SchemaProperty(
          'song',
          RealmPropertyType.object,
          optional: true,
          linkTarget: 'SongModel',
        ),
        SchemaProperty('label', RealmPropertyType.string, optional: true),
        SchemaProperty('textColor', RealmPropertyType.string, optional: true),
        SchemaProperty('sortOrder', RealmPropertyType.int),
        SchemaProperty('playlistId', RealmPropertyType.uuid),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class FolderModel extends _FolderModel
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  FolderModel(Uuid id, String name, String folderType, {int sortOrder = 0}) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<FolderModel>({'sortOrder': 0});
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'folderType', folderType);
    RealmObjectBase.set(this, 'sortOrder', sortOrder);
  }

  FolderModel._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get folderType =>
      RealmObjectBase.get<String>(this, 'folderType') as String;
  @override
  set folderType(String value) =>
      RealmObjectBase.set(this, 'folderType', value);

  @override
  int get sortOrder => RealmObjectBase.get<int>(this, 'sortOrder') as int;
  @override
  set sortOrder(int value) => RealmObjectBase.set(this, 'sortOrder', value);

  @override
  Stream<RealmObjectChanges<FolderModel>> get changes =>
      RealmObjectBase.getChanges<FolderModel>(this);

  @override
  Stream<RealmObjectChanges<FolderModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<FolderModel>(this, keyPaths);

  @override
  FolderModel freeze() => RealmObjectBase.freezeObject<FolderModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'folderType': folderType.toEJson(),
      'sortOrder': sortOrder.toEJson(),
    };
  }

  static EJsonValue _toEJson(FolderModel value) => value.toEJson();
  static FolderModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'folderType': EJsonValue folderType,
      } =>
        FolderModel(
          fromEJson(id),
          fromEJson(name),
          fromEJson(folderType),
          sortOrder: fromEJson(ejson['sortOrder'], defaultValue: 0),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(FolderModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      FolderModel,
      'FolderModel',
      [
        SchemaProperty('id', RealmPropertyType.uuid),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty('folderType', RealmPropertyType.string),
        SchemaProperty('sortOrder', RealmPropertyType.int),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ProProfileModel extends _ProProfileModel
    with RealmEntity, RealmObjectBase, RealmObject {
  ProProfileModel(
    Uuid id,
    String name, {
    String? composer,
    String? publisher,
    String? proOrg,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'composer', composer);
    RealmObjectBase.set(this, 'publisher', publisher);
    RealmObjectBase.set(this, 'proOrg', proOrg);
  }

  ProProfileModel._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get composer =>
      RealmObjectBase.get<String>(this, 'composer') as String?;
  @override
  set composer(String? value) => RealmObjectBase.set(this, 'composer', value);

  @override
  String? get publisher =>
      RealmObjectBase.get<String>(this, 'publisher') as String?;
  @override
  set publisher(String? value) => RealmObjectBase.set(this, 'publisher', value);

  @override
  String? get proOrg => RealmObjectBase.get<String>(this, 'proOrg') as String?;
  @override
  set proOrg(String? value) => RealmObjectBase.set(this, 'proOrg', value);

  @override
  Stream<RealmObjectChanges<ProProfileModel>> get changes =>
      RealmObjectBase.getChanges<ProProfileModel>(this);

  @override
  Stream<RealmObjectChanges<ProProfileModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<ProProfileModel>(this, keyPaths);

  @override
  ProProfileModel freeze() =>
      RealmObjectBase.freezeObject<ProProfileModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'composer': composer.toEJson(),
      'publisher': publisher.toEJson(),
      'proOrg': proOrg.toEJson(),
    };
  }

  static EJsonValue _toEJson(ProProfileModel value) => value.toEJson();
  static ProProfileModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id, 'name': EJsonValue name} => ProProfileModel(
        fromEJson(id),
        fromEJson(name),
        composer: fromEJson(ejson['composer']),
        publisher: fromEJson(ejson['publisher']),
        proOrg: fromEJson(ejson['proOrg']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ProProfileModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      ProProfileModel,
      'ProProfileModel',
      [
        SchemaProperty('id', RealmPropertyType.uuid),
        SchemaProperty('name', RealmPropertyType.string),
        SchemaProperty('composer', RealmPropertyType.string, optional: true),
        SchemaProperty('publisher', RealmPropertyType.string, optional: true),
        SchemaProperty('proOrg', RealmPropertyType.string, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class AppSettingsModel extends _AppSettingsModel
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  AppSettingsModel(
    Uuid id, {
    bool dateFormatDMY = false,
    bool clock24h = false,
    String pdfPaperSize = 'letter',
    bool pdfShowNumbers = true,
    String pdfAlignment = 'left',
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<AppSettingsModel>({
        'dateFormatDMY': false,
        'clock24h': false,
        'pdfPaperSize': 'letter',
        'pdfShowNumbers': true,
        'pdfAlignment': 'left',
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'dateFormatDMY', dateFormatDMY);
    RealmObjectBase.set(this, 'clock24h', clock24h);
    RealmObjectBase.set(this, 'pdfPaperSize', pdfPaperSize);
    RealmObjectBase.set(this, 'pdfShowNumbers', pdfShowNumbers);
    RealmObjectBase.set(this, 'pdfAlignment', pdfAlignment);
  }

  AppSettingsModel._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  bool get dateFormatDMY =>
      RealmObjectBase.get<bool>(this, 'dateFormatDMY') as bool;
  @override
  set dateFormatDMY(bool value) =>
      RealmObjectBase.set(this, 'dateFormatDMY', value);

  @override
  bool get clock24h => RealmObjectBase.get<bool>(this, 'clock24h') as bool;
  @override
  set clock24h(bool value) => RealmObjectBase.set(this, 'clock24h', value);

  @override
  String get pdfPaperSize =>
      RealmObjectBase.get<String>(this, 'pdfPaperSize') as String;
  @override
  set pdfPaperSize(String value) =>
      RealmObjectBase.set(this, 'pdfPaperSize', value);

  @override
  bool get pdfShowNumbers =>
      RealmObjectBase.get<bool>(this, 'pdfShowNumbers') as bool;
  @override
  set pdfShowNumbers(bool value) =>
      RealmObjectBase.set(this, 'pdfShowNumbers', value);

  @override
  String get pdfAlignment =>
      RealmObjectBase.get<String>(this, 'pdfAlignment') as String;
  @override
  set pdfAlignment(String value) =>
      RealmObjectBase.set(this, 'pdfAlignment', value);

  @override
  Stream<RealmObjectChanges<AppSettingsModel>> get changes =>
      RealmObjectBase.getChanges<AppSettingsModel>(this);

  @override
  Stream<RealmObjectChanges<AppSettingsModel>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<AppSettingsModel>(this, keyPaths);

  @override
  AppSettingsModel freeze() =>
      RealmObjectBase.freezeObject<AppSettingsModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'dateFormatDMY': dateFormatDMY.toEJson(),
      'clock24h': clock24h.toEJson(),
      'pdfPaperSize': pdfPaperSize.toEJson(),
      'pdfShowNumbers': pdfShowNumbers.toEJson(),
      'pdfAlignment': pdfAlignment.toEJson(),
    };
  }

  static EJsonValue _toEJson(AppSettingsModel value) => value.toEJson();
  static AppSettingsModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => AppSettingsModel(
        fromEJson(id),
        dateFormatDMY: fromEJson(ejson['dateFormatDMY'], defaultValue: false),
        clock24h: fromEJson(ejson['clock24h'], defaultValue: false),
        pdfPaperSize: fromEJson(ejson['pdfPaperSize'], defaultValue: 'letter'),
        pdfShowNumbers: fromEJson(ejson['pdfShowNumbers'], defaultValue: true),
        pdfAlignment: fromEJson(ejson['pdfAlignment'], defaultValue: 'left'),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AppSettingsModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      AppSettingsModel,
      'AppSettingsModel',
      [
        SchemaProperty('id', RealmPropertyType.uuid),
        SchemaProperty('dateFormatDMY', RealmPropertyType.bool),
        SchemaProperty('clock24h', RealmPropertyType.bool),
        SchemaProperty('pdfPaperSize', RealmPropertyType.string),
        SchemaProperty('pdfShowNumbers', RealmPropertyType.bool),
        SchemaProperty('pdfAlignment', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
