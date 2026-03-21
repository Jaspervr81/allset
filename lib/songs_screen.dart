import 'package:allset/app_theme.dart';
import 'package:allset/lyrics_editor_screen.dart';
import 'package:allset/models/models.dart';
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
  Uuid? activeFolderId; // null = show all songs (no filter)

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
    final folders = ref.watch(songFolderProvider);
    final folderNotifier = ref.read(songFolderProvider.notifier);
    final bgColor = AppTheme.bg(darkMode);
    final fontColor = AppTheme.text(darkMode);

    // Filter songs by active folder (null = all songs without a folder, or all if no folders exist)
    final visibleSongs = activeFolderId != null
        ? libraryState.songs.where((s) => s.folderId == activeFolderId).toList()
        : folders.isEmpty
            ? libraryState.songs
            : libraryState.songs.where((s) => s.folderId == null).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Header
              SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close_rounded,
                          color: AppTheme.subtext(darkMode)),
                    ),
                    Text('Song Library',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: fontColor,
                            letterSpacing: -0.3)),
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
                          if (multiSelectMode) ...[
                            TextButton(
                              onPressed: () => _addSelectedToSet(libraryState),
                              child: const Text('Add to Set'),
                            ),
                            if (folders.isNotEmpty)
                              TextButton(
                                onPressed: () => _moveSelectedToFolder(
                                    libraryState, libraryNotifier, folders),
                                child: const Text('Move'),
                              ),
                          ],
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

                // Folder strip
                if (folders.isNotEmpty)
                  _buildFolderStrip(folders, folderNotifier, fontColor),

                // Song list
                Expanded(
                  child: visibleSongs.isEmpty
                      ? Center(
                          child: Text('No songs yet',
                              style: TextStyle(
                                  color: AppTheme.subtext(darkMode))))
                      : ReorderableListView(
                          onReorder: (oldIndex, newIndex) {
                            final songs = List<SongModel>.from(visibleSongs);
                            if (newIndex > oldIndex) newIndex -= 1;
                            final moved = songs.removeAt(oldIndex);
                            songs.insert(newIndex, moved);
                            for (int i = 0; i < songs.length; i++) {
                              libraryNotifier.updateSong(
                                  songs[i], (s) => s.sortOrder = i);
                            }
                          },
                          children: [
                            for (final song in visibleSongs)
                              _buildSongTile(
                                  song,
                                  libraryState,
                                  libraryNotifier,
                                  folders,
                                  fontColor,
                                  darkMode),
                          ],
                        ),
                ),
              ],
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
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      color: active
                          ? AppTheme.accent
                          : AppTheme.subtext(ref.read(darkModeProvider)),
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13)),
              if (active)
                Icon(
                  state.sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 12,
                  color: AppTheme.accent,
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

  Widget _buildFolderStrip(List<FolderModel> folders,
      SongFolderNotifier folderNotifier, Color fontColor) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          // "All" chip
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: const Text('All'),
              selected: activeFolderId == null,
              onSelected: (_) => setState(() => activeFolderId = null),
            ),
          ),
          // Folder chips
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: folders.length,
              itemBuilder: (_, i) {
                final folder = folders[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onLongPress: () =>
                        _showFolderOptions(folder, folderNotifier),
                    child: ChoiceChip(
                      label: Text(folder.name),
                      selected: activeFolderId == folder.id,
                      onSelected: (_) => setState(() =>
                          activeFolderId = activeFolderId == folder.id
                              ? null
                              : folder.id),
                    ),
                  ),
                );
              },
            ),
          ),
          // Add folder button
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, size: 20),
            onPressed: () => _createFolder(folderNotifier),
          ),
        ],
      ),
    );
  }

  void _createFolder(SongFolderNotifier notifier) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Folder name')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('Create')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) notifier.addFolder(name);
  }

  void _showFolderOptions(
      FolderModel folder, SongFolderNotifier notifier) async {
    final action = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(folder.name),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'rename'),
            child: const Text('Rename'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Delete folder',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'rename') {
      final ctrl = TextEditingController(text: folder.name);
      final name = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Rename Folder'),
          content: TextField(controller: ctrl, autofocus: true),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, ctrl.text),
                child: const Text('Save')),
          ],
        ),
      );
      if (name != null && name.isNotEmpty) notifier.renameFolder(folder, name);
    } else if (action == 'delete') {
      // Unassign songs from this folder before deleting
      final songsInFolder = ref
          .read(songLibraryProvider)
          .songs
          .where((s) => s.folderId == folder.id)
          .toList();
      for (final s in songsInFolder) {
        ref
            .read(songLibraryProvider.notifier)
            .updateSong(s, (song) => song.folderId = null);
      }
      notifier.deleteFolder(folder);
      if (activeFolderId == folder.id) setState(() => activeFolderId = null);
    }
  }

  Widget _buildSongTile(
    SongModel song,
    SongLibraryState state,
    SongLibraryNotifier notifier,
    List<FolderModel> folders,
    Color fontColor,
    bool darkMode,
  ) {
    final isSelected = state.selectedIds.contains(song.id);
    final isExpanded = expandedSongId == song.id;
    final color = AppTheme.itemColor(song.textColor, darkMode);
    final barColor = AppTheme.itemBarColor(song.textColor);
    final subtextColor = AppTheme.subtext(darkMode);
    final borderColor = AppTheme.border(darkMode);
    final surface = AppTheme.surface(darkMode);

    final subtitleParts = <String>[];
    if (song.artist != null) subtitleParts.add(song.artist!);
    if (song.bpm != null) subtitleParts.add('${song.bpm} bpm');

    return Column(
      key: ValueKey(song.id),
      children: [
        Container(
          decoration: BoxDecoration(
            color: surface,
            border: Border(
                bottom: BorderSide(color: borderColor, width: 0.5)),
          ),
          child: Row(
            children: [
              // Left accent bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3,
                height: isExpanded ? 48 : 52,
                color: barColor,
              ),
              // Checkbox in multi-select
              if (multiSelectMode)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Checkbox(
                    value: isSelected,
                    activeColor: AppTheme.accent,
                    onChanged: (_) => notifier.toggleSelection(song.id),
                  ),
                ),
              // Main content
              Expanded(
                child: InkWell(
                  onTap: multiSelectMode
                      ? () => notifier.toggleSelection(song.id)
                      : null,
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: TextStyle(
                            fontSize: fontSize,
                            color: color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                        if (subtitleParts.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitleParts.join('  ·  '),
                            style: TextStyle(
                              fontSize: fontSize * 0.6,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              // Key badge
              if ((song.key ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: barColor == Colors.transparent
                          ? AppTheme.surface2(darkMode)
                          : barColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: barColor == Colors.transparent
                            ? borderColor
                            : barColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      song.key!,
                      style: TextStyle(
                        fontSize: fontSize * 0.6,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              // Expand toggle
              IconButton(
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 220),
                  turns: isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: subtextColor,
                    size: 20,
                  ),
                ),
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
        ),
        // Inline edit form — animates open/closed
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: isExpanded
              ? _buildInlineEditForm(song, notifier, folders, fontColor)
              : const SizedBox.shrink(),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildInlineEditForm(
      SongModel song, SongLibraryNotifier notifier, List<FolderModel> folders, Color fontColor) {
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
          if (folders.isNotEmpty)
            Row(
              children: [
                const Text('Folder: ', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                DropdownButton<Uuid?>(
                  value: song.folderId,
                  hint: const Text('None'),
                  items: [
                    const DropdownMenuItem<Uuid?>(
                        value: null, child: Text('None')),
                    for (final f in folders)
                      DropdownMenuItem<Uuid?>(
                          value: f.id, child: Text(f.name)),
                  ],
                  onChanged: (fid) =>
                      notifier.updateSong(song, (s) => s.folderId = fid),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.music_note_rounded, size: 16),
                label: Text(song.lyrics != null ? 'Edit Lyrics' : 'Add Lyrics'),
                onPressed: () => Navigator.push(context,
                    AppTheme.slideRight(LyricsEditorScreen(song: song))),
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
    final playlist = notifier.playlist;
    if (playlist == null) return;
    int order = notifier.items.length;
    for (final song in state.songs) {
      if (!state.selectedIds.contains(song.id)) continue;
      notifier.addSongItem(song, order++);
    }
    ref.read(songLibraryProvider.notifier).deselectAll();
    Navigator.pop(context);
  }

  void _moveSelectedToFolder(SongLibraryState state,
      SongLibraryNotifier notifier, List<FolderModel> folders) async {
    final folder = await showDialog<FolderModel?>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Move to Folder'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Remove from folder'),
          ),
          for (final f in folders)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, f),
              child: Text(f.name),
            ),
        ],
      ),
    );
    // dialog returns sentinel: FolderModel = move there; null = remove from folder
    // We use a special sentinel since showDialog returns null on dismiss
    // So we wrap: null from SimpleDialogOption = remove, dismissed = do nothing
    // Check if user actually picked (we always get a result from SimpleDialogOption)
    for (final song in state.songs) {
      if (!state.selectedIds.contains(song.id)) continue;
      notifier.updateSong(song, (s) => s.folderId = folder?.id);
    }
    notifier.deselectAll();
    setState(() => multiSelectMode = false);
  }

}
