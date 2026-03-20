import 'package:realm/realm.dart';
part 'models.realm.dart';

// ── Song ──────────────────────────────────────────────────────────────────────
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
  String? lyrics;
  String? composer;
  String? publisher;
  String? proInfo;
  int sortOrder = 0;
}

// ── Playlist ──────────────────────────────────────────────────────────────────
@RealmModel()
class _PlaylistModel {
  late Uuid id;
  late String title;
  String? artist;
  DateTime? date;
  String? venue;
  String? city;
  bool isLocked = false;
  int sortOrder = 0;
}

// ── SetlistItem ───────────────────────────────────────────────────────────────
@RealmModel()
class _SetlistItemModel {
  late Uuid id;
  late String type; // 'song', 'break', 'note'
  _SongModel? song;
  String? label;
  String? textColor;
  int sortOrder = 0;
  late Uuid playlistId;
}

// ── Folder ────────────────────────────────────────────────────────────────────
@RealmModel()
class _FolderModel {
  late Uuid id;
  late String name;
  late String folderType; // 'songs' or 'setlists'
  int sortOrder = 0;
}

// ── Pro Profile ───────────────────────────────────────────────────────────────
@RealmModel()
class _ProProfileModel {
  late Uuid id;
  late String name;
  String? composer;
  String? publisher;
  String? proOrg;
}

// ── App Settings (singleton) ──────────────────────────────────────────────────
@RealmModel()
class _AppSettingsModel {
  late Uuid id;
  bool dateFormatDMY = false;
  bool clock24h = false;
  String pdfPaperSize = 'letter';
  bool pdfShowNumbers = true;
  String pdfAlignment = 'left';
}
