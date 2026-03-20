import 'package:allset/lyrics_editor_screen.dart';
import 'package:allset/models/song_model.dart';
import 'package:allset/providers/dark_mode_provider.dart';
import 'package:allset/providers/setlist_providers.dart';
import 'package:allset/providers/song_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

class SongsScreen extends ConsumerStatefulWidget {
  const SongsScreen({super.key});

  @override
  ConsumerState<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends ConsumerState<SongsScreen> {
  double fontSize = 20;
  bool multiSelectMode = false;
  Uuid? expandedSongId;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _keyCtrl = TextEditingController();
  final TextEditingController _artistCtrl = TextEditingController();
  final TextEditingController _bpmCtrl = TextEditingController();
  final TextEditingController _lengthCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  // Edit controllers for inline editing
  final TextEditingController _editTitleCtrl = TextEditingController();
  final TextEditingController _editKeyCtrl = TextEditingController();
  final TextEditingController _editArtistCtrl = TextEditingController();
  final TextEditingController _editBpmCtrl = TextEditingController();
  final TextEditingController _editLengthCtrl = TextEditingController();
  final TextEditingController _editNotesCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _keyCtrl.dispose();
    _artistCtrl.dispose();
    _bpmCtrl.dispose();
    _lengthCtrl.dispose();
    _notesCtrl.dispose();
    _editTitleCtrl.dispose();
    _editKeyCtrl.dispose();
    _editArtistCtrl.dispose();
    _editBpmCtrl.dispose();
    _editLengthCtrl.dispose();
    _editNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(darkModeProvider);
    final libraryState = ref.watch(songLibraryProvider);
    final libraryNotifier = ref.read(songLibraryProvider.notifier);
    final bgColor = darkMode ? Colors.black : Colors.white;
    final fontColor = darkMode ? Colors.white : Colors.black;

    return Scaffold(
      body: Container(
        color: bgColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Header
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                      Text('Song Library',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: fontColor)),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() =>
                                  multiSelectMode = !multiSelectMode);
                              if (!multiSelectMode) {
                                libraryNotifier.deselectAll();
                              }
                            },
                            child: Text(multiSelectMode ? 'Done' : 'Select'),
                          ),
                          if (multiSelectMode)
                            TextButton(
                              onPressed: () => _addSelectedToSet(libraryState),
                              child: const Text('Add to Set'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // New song form
                _buildNewSongForm(darkMode),
                const SizedBox(height: 8),

                // Sort bar
                _buildSortBar(libraryNotifier, fontColor),
                const Divider(),

                // Song list
                Expanded(
                  child: libraryState.songs.isEmpty
                      ? Center(
                          child: Text('No songs yet',
                              style: TextStyle(color: fontColor)))
                      : ReorderableListView(
                          onReorder: (oldIndex, newIndex) {
                            // Update sort order in Realm
                            final songs =
                                List<SongModel>.from(libraryState.songs);
                            if (newIndex > oldIndex) newIndex -= 1;
                            final moved = songs.removeAt(oldIndex);
                            songs.insert(newIndex, moved);
                            // Write sort orders
                            final realm = ref.read(
                                // We need Realm here — access via provider
                                // but SongLibraryNotifier exposes updateSong
                                // so we'll do a batch update
                                songLibraryProvider.notifier);
                            for (int i = 0; i < songs.length; i++) {
                              realm.updateSong(songs[i],
                                  (s) => s.sortOrder = i);
                            }
                          },
                          children: [
                            for (final song in libraryState.songs)
                              _buildSongTile(
                                  song,
                                  libraryState,
                                  libraryNotifier,
                                  fontColor,
                                  darkMode),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewSongForm(bool darkMode) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'New Song', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _keyCtrl,
                decoration: const InputDecoration(
                    labelText: 'Key', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _artistCtrl,
                decoration: const InputDecoration(
                    labelText: 'Artist', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _bpmCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'BPM', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _lengthCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: '0:00', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                    labelText: 'Notes', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _saveSong,
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortBar(SongLibraryNotifier notifier, Color fontColor) {
    final state = ref.read(songLibraryProvider);
    Widget header(String label, SongSortField field) {
      final active = state.sortField == field;
      return InkWell(
        onTap: () => notifier.setSort(field),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      color: active ? Colors.deepPurple : fontColor,
                      fontWeight:
                          active ? FontWeight.bold : FontWeight.normal)),
              if (active)
                Icon(
                  state.sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 14,
                  color: Colors.deepPurple,
                ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        header('Name', SongSortField.name),
        header('Key', SongSortField.key),
        header('BPM', SongSortField.bpm),
        header('Artist', SongSortField.artist),
      ],
    );
  }

  Widget _buildSongTile(
    SongModel song,
    SongLibraryState state,
    SongLibraryNotifier notifier,
    Color fontColor,
    bool darkMode,
  ) {
    final isSelected = state.selectedIds.contains(song.id);
    final isExpanded = expandedSongId == song.id;
    final color = _songColor(song.textColor, darkMode);

    return Column(
      key: ValueKey(song.id),
      children: [
        ListTile(
          leading: multiSelectMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (_) => notifier.toggleSelection(song.id),
                )
              : null,
          title: Text(song.title,
              style: TextStyle(
                  fontSize: fontSize,
                  color: color,
                  fontWeight: FontWeight.bold)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(song.key ?? '',
                  style: TextStyle(fontSize: fontSize, color: color)),
              IconButton(
                icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    if (isExpanded) {
                      expandedSongId = null;
                    } else {
                      expandedSongId = song.id;
                      _editTitleCtrl.text = song.title;
                      _editKeyCtrl.text = song.key ?? '';
                      _editArtistCtrl.text = song.artist ?? '';
                      _editBpmCtrl.text = song.bpm?.toString() ?? '';
                      _editLengthCtrl.text = song.length?.toString() ?? '';
                      _editNotesCtrl.text = song.notes ?? '';
                    }
                  });
                },
              ),
            ],
          ),
          subtitle: Row(
            children: [
              if (song.artist != null)
                Text(song.artist!,
                    style: TextStyle(
                        fontSize: fontSize * 0.7,
                        color: color,
                        fontWeight: FontWeight.w100)),
              const SizedBox(width: 16),
              if (song.bpm != null)
                Text('${song.bpm}',
                    style: TextStyle(
                        fontSize: fontSize * 0.7,
                        color: color,
                        fontWeight: FontWeight.w100)),
            ],
          ),
          onTap: multiSelectMode
              ? () => notifier.toggleSelection(song.id)
              : null,
        ),
        if (isExpanded) _buildInlineEditForm(song, notifier, fontColor),
      ],
    );
  }

  Widget _buildInlineEditForm(
      SongModel song, SongLibraryNotifier notifier, Color fontColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _editTitleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _editKeyCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Key', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _editArtistCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Artist', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _editBpmCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'BPM', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _editLengthCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Length', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _editNotesCtrl,
            decoration: const InputDecoration(
                labelText: 'Notes', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.music_note),
                label: Text(song.lyrics != null ? 'Edit Lyrics' : 'Add Lyrics'),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => LyricsEditorScreen(song: song))),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      notifier.updateSong(song, (s) {
                        s.title = _editTitleCtrl.text;
                        s.key = _editKeyCtrl.text.isNotEmpty
                            ? _editKeyCtrl.text
                            : null;
                        s.artist = _editArtistCtrl.text.isNotEmpty
                            ? _editArtistCtrl.text
                            : null;
                        s.bpm = _editBpmCtrl.text.isNotEmpty
                            ? int.tryParse(_editBpmCtrl.text)
                            : null;
                        s.length = _editLengthCtrl.text.isNotEmpty
                            ? int.tryParse(_editLengthCtrl.text)
                            : null;
                        s.notes = _editNotesCtrl.text.isNotEmpty
                            ? _editNotesCtrl.text
                            : null;
                      });
                      setState(() => expandedSongId = null);
                    },
                    child: const Text('Save'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete song?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        notifier.deleteSong(song);
                        setState(() => expandedSongId = null);
                      }
                    },
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveSong() {
    if (_titleCtrl.text.isEmpty) return;
    final song = SongModel(
      Uuid.v4(),
      _titleCtrl.text,
      key: _keyCtrl.text.isNotEmpty ? _keyCtrl.text : null,
      artist: _artistCtrl.text.isNotEmpty ? _artistCtrl.text : null,
      bpm: _bpmCtrl.text.isNotEmpty ? int.tryParse(_bpmCtrl.text) : null,
      length:
          _lengthCtrl.text.isNotEmpty ? int.tryParse(_lengthCtrl.text) : null,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      textColor: '',
      sortOrder: ref.read(songLibraryProvider).songs.length,
    );
    ref.read(songLibraryProvider.notifier).addSong(song);
    _titleCtrl.clear();
    _keyCtrl.clear();
    _artistCtrl.clear();
    _bpmCtrl.clear();
    _lengthCtrl.clear();
    _notesCtrl.clear();
  }

  void _addSelectedToSet(SongLibraryState state) {
    final notifier = ref.read(currentSetlistProvider.notifier);
    final playlist = ref.read(currentSetlistProvider);
    if (playlist == null) return;
    int order = notifier.items.length;
    for (final song in state.songs) {
      if (!state.selectedIds.contains(song.id)) continue;
      notifier.addSongItem(song, order++);
    }
    ref.read(songLibraryProvider.notifier).deselectAll();
    Navigator.pop(context);
  }

  Color _songColor(String? textColor, bool darkMode) {
    switch (textColor) {
      case 'purple':
        return Colors.purpleAccent;
      case 'red':
        return Colors.redAccent;
      case 'orange':
        return Colors.orangeAccent;
      default:
        return darkMode ? Colors.white : Colors.black;
    }
  }
}
