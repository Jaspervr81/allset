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
