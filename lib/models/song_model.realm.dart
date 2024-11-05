// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class SongModel extends _SongModel
    with RealmEntity, RealmObjectBase, RealmObject {
  SongModel(
    Uuid id,
    String title, {
    String? textColor,
    String? key,
    String? artist,
    int? bpm,
    int? length,
    String? notes,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'textColor', textColor);
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set(this, 'artist', artist);
    RealmObjectBase.set(this, 'bpm', bpm);
    RealmObjectBase.set(this, 'length', length);
    RealmObjectBase.set(this, 'notes', notes);
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
    };
  }

  static EJsonValue _toEJson(SongModel value) => value.toEJson();
  static SongModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'title': EJsonValue title,
      } =>
        SongModel(
          fromEJson(id),
          fromEJson(title),
          textColor: fromEJson(ejson['textColor']),
          key: fromEJson(ejson['key']),
          artist: fromEJson(ejson['artist']),
          bpm: fromEJson(ejson['bpm']),
          length: fromEJson(ejson['length']),
          notes: fromEJson(ejson['notes']),
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
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class PlaylistModel extends _PlaylistModel
    with RealmEntity, RealmObjectBase, RealmObject {
  PlaylistModel(
    Uuid id,
    String name, {
    String? artist,
    DateTime? date,
    String? venue,
    String? city,
    Iterable<SongModel> songs = const [],
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'artist', artist);
    RealmObjectBase.set(this, 'date', date);
    RealmObjectBase.set(this, 'venue', venue);
    RealmObjectBase.set(this, 'city', city);
    RealmObjectBase.set<RealmList<SongModel>>(
        this, 'songs', RealmList<SongModel>(songs));
  }

  PlaylistModel._();

  @override
  Uuid get id => RealmObjectBase.get<Uuid>(this, 'id') as Uuid;
  @override
  set id(Uuid value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

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
  RealmList<SongModel> get songs =>
      RealmObjectBase.get<SongModel>(this, 'songs') as RealmList<SongModel>;
  @override
  set songs(covariant RealmList<SongModel> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<PlaylistModel>> get changes =>
      RealmObjectBase.getChanges<PlaylistModel>(this);

  @override
  Stream<RealmObjectChanges<PlaylistModel>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<PlaylistModel>(this, keyPaths);

  @override
  PlaylistModel freeze() => RealmObjectBase.freezeObject<PlaylistModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'artist': artist.toEJson(),
      'date': date.toEJson(),
      'venue': venue.toEJson(),
      'city': city.toEJson(),
      'songs': songs.toEJson(),
    };
  }

  static EJsonValue _toEJson(PlaylistModel value) => value.toEJson();
  static PlaylistModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
      } =>
        PlaylistModel(
          fromEJson(id),
          fromEJson(name),
          artist: fromEJson(ejson['artist']),
          date: fromEJson(ejson['date']),
          venue: fromEJson(ejson['venue']),
          city: fromEJson(ejson['city']),
          songs: fromEJson(ejson['songs']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PlaylistModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, PlaylistModel, 'PlaylistModel', [
      SchemaProperty('id', RealmPropertyType.uuid),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('artist', RealmPropertyType.string, optional: true),
      SchemaProperty('date', RealmPropertyType.timestamp, optional: true),
      SchemaProperty('venue', RealmPropertyType.string, optional: true),
      SchemaProperty('city', RealmPropertyType.string, optional: true),
      SchemaProperty('songs', RealmPropertyType.object,
          linkTarget: 'SongModel', collectionType: RealmCollectionType.list),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
