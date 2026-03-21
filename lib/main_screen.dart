import 'package:allset/models/models.dart';
import 'package:allset/performance_screen.dart';
import 'package:allset/providers/app_settings_provider.dart';
import 'package:allset/providers/dark_mode_provider.dart';
import 'package:allset/providers/realm_provider.dart';
import 'package:allset/providers/setlist_providers.dart';
import 'package:allset/services/export_service.dart';
import 'package:allset/setlist_library_screen.dart';
import 'package:allset/settings_screen.dart';
import 'package:allset/songs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  double fontSize = 30;
  bool showEditBar = false;
  bool showTileParameters = false;

  bool showKey = true;
  bool showArtist = true;
  bool showBpm = true;
  bool showLength = false;
  bool showNotes = false;

  bool isPurpleSelected = false;
  bool isRedSelected = false;
  bool isOrangeSelected = false;
  String selectedColor = '';

  // Title cycling: title → artist → date → venue → city
  int _titleCycleIndex = 0;
  static const List<String> _titleCycleFields = [
    'title', 'artist', 'date', 'venue', 'city'
  ];

  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(darkModeProvider);
    ref.watch(currentSetlistProvider); // watch version counter for rebuilds
    final notifier = ref.read(currentSetlistProvider.notifier);
    final playlist = notifier.playlist;
    final items = notifier.items;

    final Color fontColor = darkMode ? Colors.white : Colors.black;
    final Color bgColor = darkMode ? Colors.black : Colors.white;

    return Scaffold(
      body: Container(
        color: bgColor,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top bar
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      icon: const Icon(Icons.menu),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _titleCycleIndex =
                            (_titleCycleIndex + 1) % _titleCycleFields.length;
                      }),
                      onLongPress: () => _editSetlistMeta(playlist, notifier),
                      child: Text(
                        _getHeaderLabel(playlist),
                        style: TextStyle(fontSize: 20, color: fontColor),
                      ),
                    ),
                    Row(
                      children: [
                        if (playlist != null)
                          IconButton(
                            onPressed: () =>
                                notifier.lock(!playlist.isLocked),
                            icon: Icon(playlist.isLocked
                                ? Icons.lock
                                : Icons.lock_open),
                          ),
                        IconButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SetlistLibraryScreen())),
                          icon: const Icon(Icons.list),
                        ),
                        IconButton(
                          onPressed: () => _goToSongLibrary(),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Setlist
              Expanded(
                child: Stack(
                  children: [
                    ReorderableListView(
                      onReorder: playlist?.isLocked == true
                          ? (int o, int n) {}
                          : (oldIndex, newIndex) =>
                              notifier.reorder(oldIndex, newIndex),
                      children: [
                        for (final item in items)
                          _buildItemTile(
                              item, fontColor, playlist?.isLocked ?? false),
                      ],
                    ),

                    // Song details toggle bar
                    if (showTileParameters)
                      Positioned(
                        bottom: 0,
                        child: _buildTileParametersBar(),
                      ),

                    // Edit bar
                    if (showEditBar)
                      Positioned(
                        bottom: 0,
                        child: _buildEditBar(context, notifier,
                            playlist?.isLocked ?? false, items),
                      ),
                  ],
                ),
              ),

              // Bottom toolbar
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () => _showExportSheet(playlist, notifier),
                        icon: const Icon(Icons.exit_to_app),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () =>
                            ref.read(darkModeProvider.notifier).toggle(),
                        icon: const Icon(Icons.brightness_5),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        onPressed: () => setState(() {
                          showEditBar = false;
                          showTileParameters = !showTileParameters;
                        }),
                        icon: const Icon(Icons.remove_red_eye_rounded),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Slider(
                        min: 20,
                        max: 40,
                        value: fontSize,
                        onChanged: (value) => setState(() => fontSize = value),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextButton(
                        onPressed: () => setState(() {
                          showTileParameters = false;
                          showEditBar = !showEditBar;
                        }),
                        child: const Text('Edit'),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.teal,
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PerformanceScreen())),
                        child: Text('Go',
                            style:
                                TextStyle(color: fontColor, fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemTile(
      SetlistItemModel item, Color fontColor, bool isLocked) {
    final color = _itemColor(item.textColor);
    Widget tile;

    if (item.type == 'break') {
      tile = ListTile(
        key: ValueKey(item.id),
        tileColor: color.withValues(alpha: 0.15),
        title: Text(
          item.label ?? '— BREAK —',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: fontSize * 0.8,
              color: color,
              fontStyle: FontStyle.italic),
        ),
        onTap: isLocked
            ? null
            : () => _onItemTap(item),
      );
    } else if (item.type == 'note') {
      tile = ListTile(
        key: ValueKey(item.id),
        tileColor: color.withValues(alpha: 0.1),
        title: Text(
          item.label ?? '',
          style: TextStyle(
              fontSize: fontSize * 0.75,
              color: color,
              fontStyle: FontStyle.italic),
        ),
        onTap: isLocked ? null : () => _onItemTap(item),
      );
    } else {
      final song = item.song;
      final subtitleParts = <String>[];
      if (showArtist && song?.artist != null) subtitleParts.add(song!.artist!);
      if (showBpm && song?.bpm != null) subtitleParts.add('${song!.bpm} bpm');
      if (showLength && song?.length != null) subtitleParts.add(_formatLength(song!.length!));

      tile = ListTile(
        key: ValueKey(item.id),
        onTap: isLocked ? null : () => _onItemTap(item),
        title: Text(
          song?.title ?? '',
          style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: FontWeight.bold),
        ),
        trailing: showKey && (song?.key ?? '').isNotEmpty
            ? Text(
                song!.key!,
                style: TextStyle(
                    fontSize: fontSize, color: color, fontWeight: FontWeight.bold),
              )
            : null,
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitleParts.isNotEmpty)
              Text(
                subtitleParts.join('  ·  '),
                style: TextStyle(
                    fontSize: fontSize * 0.6,
                    color: color,
                    fontWeight: FontWeight.w100),
              ),
            if (showNotes && song?.notes != null)
              Text(
                song!.notes!,
                style: TextStyle(
                    fontSize: fontSize * 0.55,
                    color: color.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      );
    }

    if (isLocked) return tile;

    return Dismissible(
      key: ValueKey('dismiss_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Remove item?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Remove')),
            ],
          ),
        );
      },
      onDismissed: (_) =>
          ref.read(currentSetlistProvider.notifier).removeItem(item),
      child: tile,
    );
  }

  void _onItemTap(SetlistItemModel item) {
    if (selectedColor.isEmpty) return;
    ref
        .read(currentSetlistProvider.notifier)
        .setItemColor(item, selectedColor);
  }

  Color _itemColor(String? textColor) {
    final darkMode = ref.read(darkModeProvider);
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

  String _getHeaderLabel(PlaylistModel? pl) {
    if (pl == null) return 'Setlist';
    switch (_titleCycleFields[_titleCycleIndex]) {
      case 'title':
        return pl.title.isEmpty ? 'Setlist' : pl.title;
      case 'artist':
        return pl.artist ?? 'Setlist';
      case 'date':
        if (pl.date == null) return 'Setlist';
        final dmy = ref.read(appSettingsProvider).dateFormatDMY;
        return dmy
            ? '${pl.date!.day}/${pl.date!.month}/${pl.date!.year}'
            : '${pl.date!.month}/${pl.date!.day}/${pl.date!.year}';
      case 'venue':
        return pl.venue ?? 'Setlist';
      case 'city':
        return pl.city ?? 'Setlist';
      default:
        return 'Setlist';
    }
  }

  Widget _buildTileParametersBar() {
    Widget toggle(String label, bool value, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: value ? Colors.deepPurple : Colors.grey[600],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      color: Colors.grey[800],
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          toggle('KEY', showKey, () => setState(() => showKey = !showKey)),
          toggle('ARTIST', showArtist, () => setState(() => showArtist = !showArtist)),
          toggle('BPM', showBpm, () => setState(() => showBpm = !showBpm)),
          toggle('LENGTH', showLength, () => setState(() => showLength = !showLength)),
          toggle('NOTES', showNotes, () => setState(() => showNotes = !showNotes)),
        ],
      ),
    );
  }

  Widget _buildEditBar(BuildContext context, CurrentSetlistNotifier notifier,
      bool isLocked, List<SetlistItemModel> items) {
    if (isLocked) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        color: Colors.grey[700],
        child: const Center(
          child: Text('Setlist is locked',
              style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Purple
          _colorButton(
            color: Colors.deepPurpleAccent,
            selectedColor: Colors.deepPurple[200]!,
            isSelected: isPurpleSelected,
            onTap: () => setState(() {
              isPurpleSelected = !isPurpleSelected;
              isRedSelected = isOrangeSelected = false;
              selectedColor = isPurpleSelected ? 'purple' : '';
            }),
          ),
          // Red
          _colorButton(
            color: Colors.redAccent,
            selectedColor: Colors.red[200]!,
            isSelected: isRedSelected,
            onTap: () => setState(() {
              isRedSelected = !isRedSelected;
              isPurpleSelected = isOrangeSelected = false;
              selectedColor = isRedSelected ? 'red' : '';
            }),
          ),
          // Orange
          _colorButton(
            color: Colors.deepOrangeAccent,
            selectedColor: Colors.deepOrange[200]!,
            isSelected: isOrangeSelected,
            onTap: () => setState(() {
              isOrangeSelected = !isOrangeSelected;
              isPurpleSelected = isRedSelected = false;
              selectedColor = isOrangeSelected ? 'orange' : '';
            }),
          ),
          // Break
          TextButton(
            onPressed: () => _addBreak(notifier, items),
            style: TextButton.styleFrom(backgroundColor: Colors.grey[600]),
            child: const Text('BREAK', style: TextStyle(color: Colors.white)),
          ),
          // Quick note
          TextButton(
            onPressed: () => _addQuickNote(notifier, items),
            style: TextButton.styleFrom(backgroundColor: Colors.grey[600]),
            child: const Text('NOTE', style: TextStyle(color: Colors.white)),
          ),
          // Trash — delete by color or confirm clear all
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () => _handleTrash(notifier),
              icon: const Icon(Icons.delete),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorButton({
    required Color color,
    required Color selectedColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? selectedColor : color,
          border: Border.all(color: color, width: 3),
        ),
      ),
    );
  }

  void _addBreak(
      CurrentSetlistNotifier notifier, List<SetlistItemModel> items) {
    final playlistId = ref.read(currentSetlistProvider.notifier).playlist!.id;
    final item = SetlistItemModel(
      Uuid.v4(),
      'break',
      playlistId,
      sortOrder: items.length,
    );
    notifier.addItem(item);
  }

  void _addQuickNote(
      CurrentSetlistNotifier notifier, List<SetlistItemModel> items) async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Note'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Note text'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('Add')),
        ],
      ),
    );
    if (text != null && text.isNotEmpty) {
      final playlistId = ref.read(currentSetlistProvider.notifier).playlist!.id;
      final item = SetlistItemModel(
        Uuid.v4(),
        'note',
        playlistId,
        label: text,
        sortOrder: items.length,
      );
      notifier.addItem(item);
    }
  }

  void _handleTrash(CurrentSetlistNotifier notifier) async {
    if (selectedColor.isNotEmpty) {
      notifier.deleteColorItems(selectedColor);
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Clear entire setlist?'),
          content: const Text('This will remove all items.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Clear')),
          ],
        ),
      );
      if (confirmed == true) notifier.clearAll();
    }
  }

  void _showExportSheet(
      PlaylistModel? playlist, CurrentSetlistNotifier notifier) {
    if (playlist == null) return;
    final items = notifier.items;
    final settings = ref.read(appSettingsProvider);
    final realm = ref.read(realmProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share as text'),
              onTap: () {
                Navigator.pop(context);
                ExportService.instance
                    .shareSetlistAsText(playlist, items);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('Print / Save PDF'),
              onTap: () {
                Navigator.pop(context);
                ExportService.instance
                    .printSetlistPdf(playlist, items, settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Email backup (full library)'),
              onTap: () {
                Navigator.pop(context);
                ExportService.instance.exportBackupJson(realm);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editSetlistMeta(
      PlaylistModel? playlist, CurrentSetlistNotifier notifier) async {
    if (playlist == null) return;
    final titleCtrl = TextEditingController(text: playlist.title);
    final artistCtrl = TextEditingController(text: playlist.artist ?? '');
    final venueCtrl = TextEditingController(text: playlist.venue ?? '');
    final cityCtrl = TextEditingController(text: playlist.city ?? '');
    DateTime? selectedDate = playlist.date;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Setlist'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Title')),
                TextField(
                    controller: artistCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Artist')),
                TextField(
                    controller: venueCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Venue')),
                TextField(
                    controller: cityCtrl,
                    decoration:
                        const InputDecoration(labelText: 'City')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(selectedDate != null
                        ? '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}'
                        : 'No date'),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                notifier.updateMeta((pl) {
                  pl.title = titleCtrl.text;
                  pl.artist = artistCtrl.text.isNotEmpty
                      ? artistCtrl.text
                      : null;
                  pl.venue =
                      venueCtrl.text.isNotEmpty ? venueCtrl.text : null;
                  pl.city =
                      cityCtrl.text.isNotEmpty ? cityCtrl.text : null;
                  pl.date = selectedDate;
                });
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    titleCtrl.dispose();
    artistCtrl.dispose();
    venueCtrl.dispose();
    cityCtrl.dispose();
  }

  String _formatLength(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _goToSongLibrary() {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => const SongsScreen()));
  }
}
