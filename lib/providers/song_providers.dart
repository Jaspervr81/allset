import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:allset/models/models.dart';
import 'package:allset/providers/realm_provider.dart';

enum SongSortField { name, key, bpm, artist }

class SongLibraryState {
  final List<SongModel> songs;
  final SongSortField sortField;
  final bool sortAscending;
  final Set<Uuid> selectedIds;

  const SongLibraryState({
    this.songs = const [],
    this.sortField = SongSortField.name,
    this.sortAscending = true,
    this.selectedIds = const {},
  });

  SongLibraryState copyWith({
    List<SongModel>? songs,
    SongSortField? sortField,
    bool? sortAscending,
    Set<Uuid>? selectedIds,
  }) =>
      SongLibraryState(
        songs: songs ?? this.songs,
        sortField: sortField ?? this.sortField,
        sortAscending: sortAscending ?? this.sortAscending,
        selectedIds: selectedIds ?? this.selectedIds,
      );
}

class SongLibraryNotifier extends StateNotifier<SongLibraryState> {
  final Realm _realm;

  SongLibraryNotifier(this._realm) : super(const SongLibraryState()) {
    _load();
  }

  void _load() {
    final songs = _realm.all<SongModel>().toList();
    state = state.copyWith(songs: _sorted(songs));
  }

  List<SongModel> _sorted(List<SongModel> songs) {
    final list = List<SongModel>.from(songs);
    list.sort((a, b) {
      int cmp;
      switch (state.sortField) {
        case SongSortField.name:
          cmp = (a.title).compareTo(b.title);
          break;
        case SongSortField.key:
          cmp = (a.key ?? '').compareTo(b.key ?? '');
          break;
        case SongSortField.bpm:
          cmp = (a.bpm ?? 0).compareTo(b.bpm ?? 0);
          break;
        case SongSortField.artist:
          cmp = (a.artist ?? '').compareTo(b.artist ?? '');
          break;
      }
      return state.sortAscending ? cmp : -cmp;
    });
    return list;
  }

  void setSort(SongSortField field) {
    final ascending =
        state.sortField == field ? !state.sortAscending : true;
    state = state.copyWith(sortField: field, sortAscending: ascending);
    state = state.copyWith(songs: _sorted(state.songs));
  }

  void toggleSelection(Uuid id) {
    final ids = Set<Uuid>.from(state.selectedIds);
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    state = state.copyWith(selectedIds: ids);
  }

  void selectAll() {
    state = state.copyWith(
        selectedIds: state.songs.map((s) => s.id).toSet());
  }

  void deselectAll() {
    state = state.copyWith(selectedIds: {});
  }

  void addSong(SongModel song) {
    _realm.write(() => _realm.add(song));
    _load();
  }

  void updateSong(SongModel song, void Function(SongModel) updates) {
    _realm.write(() => updates(song));
    _load();
  }

  void deleteSong(SongModel song) {
    _realm.write(() => _realm.delete(song));
    _load();
  }

  void refresh() => _load();
}

final songLibraryProvider =
    StateNotifierProvider<SongLibraryNotifier, SongLibraryState>((ref) {
  final realm = ref.watch(realmProvider);
  return SongLibraryNotifier(realm);
});

// ── Folder provider (songs) ─────────────────────────────────────────────────

class SongFolderNotifier extends StateNotifier<List<FolderModel>> {
  final Realm _realm;

  SongFolderNotifier(this._realm) : super([]) {
    _load();
  }

  void _load() {
    final folders = _realm
        .all<FolderModel>()
        .where((f) => f.folderType == 'songs')
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    state = folders;
  }

  void addFolder(String name) {
    final f = FolderModel(Uuid.v4(), name, 'songs', sortOrder: state.length);
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

  void reorder(int oldIndex, int newIndex) {
    final list = List<FolderModel>.from(state);
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
}

final songFolderProvider =
    StateNotifierProvider<SongFolderNotifier, List<FolderModel>>((ref) {
  final realm = ref.watch(realmProvider);
  return SongFolderNotifier(realm);
});
