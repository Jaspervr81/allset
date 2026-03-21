import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:allset/models/models.dart';
import 'package:allset/providers/realm_provider.dart';

// --- Active setlist (current in MainScreen) ---
// State is a version counter — increments on every write to force UI rebuilds.
// (Riverpod skips rebuilds when the state reference is the same object.)

class CurrentSetlistNotifier extends StateNotifier<int> {
  final Realm _realm;
  PlaylistModel? _playlist;

  CurrentSetlistNotifier(this._realm) : super(0) {
    _loadOrCreate();
  }

  PlaylistModel? get playlist => _playlist;

  void _loadOrCreate() {
    final all = _realm.all<PlaylistModel>();
    if (all.isEmpty) {
      final pl = PlaylistModel(Uuid.v4(), '');
      _realm.write(() => _realm.add(pl));
      _playlist = pl;
    } else {
      _playlist = all.first;
    }
    state++;
  }

  void load(PlaylistModel pl) {
    _playlist = pl;
    state++;
  }

  void updateMeta(void Function(PlaylistModel) updates) {
    if (_playlist == null) return;
    _realm.write(() => updates(_playlist!));
    state++;
  }

  void lock(bool locked) {
    if (_playlist == null) return;
    _realm.write(() => _playlist!.isLocked = locked);
    state++;
  }

  List<SetlistItemModel> get items {
    if (_playlist == null) return [];
    return _realm
        .all<SetlistItemModel>()
        .where((i) => i.playlistId == _playlist!.id)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void addItem(SetlistItemModel item) {
    _realm.write(() => _realm.add(item));
    state++;
  }

  void removeItem(SetlistItemModel item) {
    _realm.write(() => _realm.delete(item));
    state++;
  }

  void reorder(int oldIndex, int newIndex) {
    final list = items;
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    _realm.write(() {
      for (int i = 0; i < list.length; i++) {
        list[i].sortOrder = i;
      }
    });
    state++;
  }

  void deleteColorItems(String color) {
    final toDelete = items.where((i) => i.textColor == color).toList();
    _realm.write(() {
      for (final item in toDelete) {
        _realm.delete(item);
      }
    });
    state++;
  }

  void clearAll() {
    final toDelete = items;
    _realm.write(() {
      for (final item in toDelete) {
        _realm.delete(item);
      }
    });
    state++;
  }

  void setItemColor(SetlistItemModel item, String color) {
    _realm.write(() => item.textColor = color);
    state++;
  }

  void addSongItem(SongModel song, int order) {
    if (_playlist == null) return;
    final item = SetlistItemModel(
      Uuid.v4(),
      'song',
      _playlist!.id,
      sortOrder: order,
    );
    _realm.write(() {
      _realm.add(item);
      item.song = song;
    });
    state++;
  }
}

final currentSetlistProvider =
    StateNotifierProvider<CurrentSetlistNotifier, int>((ref) {
  final realm = ref.watch(realmProvider);
  return CurrentSetlistNotifier(realm);
});

// --- Setlist library ---

class SetlistLibraryNotifier extends StateNotifier<List<PlaylistModel>> {
  final Realm _realm;

  SetlistLibraryNotifier(this._realm) : super([]) {
    _load();
  }

  void _load() {
    final all = _realm.all<PlaylistModel>().toList();
    all.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    state = all;
  }

  void add(PlaylistModel pl) {
    _realm.write(() => _realm.add(pl));
    _load();
  }

  void delete(PlaylistModel pl) {
    _realm.write(() => _realm.delete(pl));
    _load();
  }

  void reorder(int oldIndex, int newIndex) {
    final list = List<PlaylistModel>.from(state);
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    _realm.write(() {
      for (int i = 0; i < list.length; i++) {
        list[i].sortOrder = i;
      }
    });
    state = list;
  }

  void refresh() => _load();

  void setFolder(PlaylistModel pl, Uuid? folderId) {
    _realm.write(() => pl.folderId = folderId);
    _load();
  }

  void clearFolderAssignments(Uuid folderId) {
    final toUpdate = state.where((pl) => pl.folderId == folderId).toList();
    _realm.write(() {
      for (final pl in toUpdate) {
        pl.folderId = null;
      }
    });
    _load();
  }
}

final setlistLibraryProvider =
    StateNotifierProvider<SetlistLibraryNotifier, List<PlaylistModel>>((ref) {
  final realm = ref.watch(realmProvider);
  return SetlistLibraryNotifier(realm);
});

// ── Folder provider (setlists) ───────────────────────────────────────────────

class SetlistFolderNotifier extends StateNotifier<List<FolderModel>> {
  final Realm _realm;

  SetlistFolderNotifier(this._realm) : super([]) {
    _load();
  }

  void _load() {
    final folders = _realm
        .all<FolderModel>()
        .where((f) => f.folderType == 'setlists')
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    state = folders;
  }

  void addFolder(String name) {
    final f = FolderModel(Uuid.v4(), name, 'setlists', sortOrder: state.length);
    _realm.write(() => _realm.add(f));
    _load();
  }

  void deleteFolder(FolderModel folder) {
    _realm.write(() => _realm.delete(folder));
    _load();
  }

  void renameFolder(FolderModel folder, String name) {
    _realm.write(() => folder.name = name);
    _load();
  }
}

final setlistFolderProvider =
    StateNotifierProvider<SetlistFolderNotifier, List<FolderModel>>((ref) {
  final realm = ref.watch(realmProvider);
  return SetlistFolderNotifier(realm);
});
