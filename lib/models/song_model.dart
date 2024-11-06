import 'dart:io';
import 'package:realm/realm.dart';
part 'song_model.realm.dart';

@RealmModel()
class _SongModel {
  late Uuid id;
  late String title;
  String? textColor;
  String? key;
  String? artist;
  int? bpm;
  int? length;
  String? notes;
}

@RealmModel()
class _PlaylistModel {
  late Uuid id;
  late String name;
  String? artist;
  DateTime? date;
  String? venue;
  String? city;
  late List<_SongModel> songs;
}

class TestSongModel {
  Uuid id = Uuid.v4();
  String title = 'testing the waters';
  String key = 'Fm';
  String artist = 'Beatles';
  int bpm = 135;
  int length = 185;
  String notes = 'this is a nice song about stuff and things';
}