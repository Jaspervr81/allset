import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:allset/models/models.dart';
import 'package:allset/providers/realm_provider.dart';

// --- Active setlist (current in MainScreen) ---

class CurrentSetlistNotifier extends StateNotifier<PlaylistModel?> {
  final Realm _realm;

  CurrentSetlistNotifier(this._realm) : super(null) {
    _loadOrCreate();
  }

  void _loadOrCreate() {
    final all = _realm.all<PlaylistModel>();
    if (all.isEmpty) {
      final pl = PlaylistModel(Uuid.v4(), '');
      _realm.write(() => _realm.add(pl));
      state = pl;
    } else {
      state = all.first;
    }
  }

  void load(PlaylistModel pl) => state = pl;

  void updateMeta(void Function(PlaylistModel) updates) {
    if (state == null) return;
    _realm.write(() => updates(state!));
    state = state; // trigger rebuild
  }

  void lock(bool locked) {
    if (state == null) return;
    _realm.write(() => state!.isLocked = locked);
    state = state;
  }

  List<SetlistItemModel> get items {
    if (state == null) return [];
    return _realm
        .all<SetlistItemModel>()
        .where((i) => i.playlistId == state!.id)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void addItem(SetlistItemModel item) {
    _realm.write(() => _realm.add(item));
    state = state;
  }

  void removeItem(SetlistItemModel item) {
    _realm.write(() => _realm.delete(item));
    state = state;
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
    state = state;
  }

  void deleteColorItems(String color) {
    final toDelete = items.where((i) => i.textColor == color).toList();
    _realm.write(() {
      for (final item in toDelete) {
        _realm.delete(item);
      }
    });
    state = state;
  }

  void clearAll() {
    final toDelete = items;
    _realm.write(() {
      for (final item in toDelete) {
        _realm.delete(item);
      }
    });
    state = state;
  }

  void setItemColor(SetlistItemModel item, String color) {
    _realm.write(() => item.textColor = color);
    state = state;
  }

  void addSongItem(SongModel song, int order) {
    if (state == null) return;
    final item = SetlistItemModel(
      Uuid.v4(),
      'song',
      state!.id,
      sortOrder: order,
    );
    _realm.write(() {
      _realm.add(item);
      item.song = song;
    });
    state = state;
  }
}

final currentSetlistProvider =
    StateNotifierProvider<CurrentSetlistNotifier, PlaylistModel?>((ref) {
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
}

final setlistLibraryProvider =
    StateNotifierProvider<SetlistLibraryNotifier, List<PlaylistModel>>((ref) {
  final realm = ref.watch(realmProvider);
  return SetlistLibraryNotifier(realm);
});
