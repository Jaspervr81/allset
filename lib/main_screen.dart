import 'package:allset/app_theme.dart';
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

class _MainScreenState extends ConsumerState<MainScreen>
    with TickerProviderStateMixin {
  double fontSize = 28;
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

  int _titleCycleIndex = 0;
  static const List<String> _titleCycleFields = [
    'title', 'artist', 'date', 'venue', 'city'
  ];

  @override
  Widget build(BuildContext context) {
    final dark = ref.watch(darkModeProvider);
    ref.watch(currentSetlistProvider);
    final notifier = ref.read(currentSetlistProvider.notifier);
    final playlist = notifier.playlist;
    final items = notifier.items;
    final locked = playlist?.isLocked ?? false;

    final bg = AppTheme.bg(dark);
    final surface = AppTheme.surface(dark);
    final textColor = AppTheme.text(dark);
    final subtextColor = AppTheme.subtext(dark);
    final borderColor = AppTheme.border(dark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: surface,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  _iconBtn(
                    Icons.settings_outlined,
                    textColor,
                    () => Navigator.push(
                        context, AppTheme.slideUp(const SettingsScreen())),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() {
                        _titleCycleIndex =
                            (_titleCycleIndex + 1) % _titleCycleFields.length;
                      }),
                      onLongPress: () =>
                          _editSetlistMeta(playlist, notifier),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          _getHeaderLabel(playlist),
                          key: ValueKey(
                              '${_titleCycleIndex}_${playlist?.id}'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (playlist != null)
                    _iconBtn(
                      locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                      locked ? AppTheme.accent : subtextColor,
                      () => notifier.lock(!locked),
                    ),
                  _iconBtn(
                    Icons.queue_music_rounded,
                    textColor,
                    () => Navigator.push(context,
                        AppTheme.slideUp(const SetlistLibraryScreen())),
                  ),
                  _iconBtn(
                    Icons.add_rounded,
                    textColor,
                    _goToSongLibrary,
                  ),
                ],
              ),
            ),

            // ── Setlist ──────────────────────────────────────
            Expanded(
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.queue_music_rounded,
                                  size: 64,
                                  color: subtextColor.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              Text('Tap + to add songs',
                                  style: TextStyle(
                                      color: subtextColor,
                                      fontSize: 16)),
                            ],
                          ),
                        )
                      : ReorderableListView(
                          padding: const EdgeInsets.only(bottom: 4),
                          onReorder: locked
                              ? (int o, int n) {}
                              : (o, n) => notifier.reorder(o, n),
                          children: [
                            for (final item in items)
                              _buildItemTile(item, dark, locked),
                          ],
                        ),

                  // Params panel — slides up from bottom
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    bottom: showTileParameters ? 0 : -56,
                    left: 0,
                    right: 0,
                    child: _buildParamsBar(dark, surface, borderColor),
                  ),

                  // Edit panel — slides up from bottom
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    bottom: showEditBar ? 0 : -64,
                    left: 0,
                    right: 0,
                    child: _buildEditBar(notifier, locked, items, dark,
                        surface, borderColor, textColor),
                  ),
                ],
              ),
            ),

            // ── Bottom toolbar ───────────────────────────────
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: surface,
                border: Border(
                    top: BorderSide(color: borderColor, width: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  _iconBtn(Icons.ios_share_rounded, subtextColor,
                      () => _showExportSheet(playlist, notifier)),
                  _iconBtn(
                    dark
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    subtextColor,
                    () => ref.read(darkModeProvider.notifier).toggle(),
                  ),
                  _iconBtn(
                    Icons.tune_rounded,
                    showTileParameters ? AppTheme.accent : subtextColor,
                    () => setState(() {
                      showEditBar = false;
                      showTileParameters = !showTileParameters;
                    }),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7),
                        trackHeight: 2,
                        activeTrackColor: AppTheme.accent,
                        inactiveTrackColor:
                            AppTheme.border(dark),
                        thumbColor: AppTheme.accent,
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        min: 20,
                        max: 40,
                        value: fontSize,
                        onChanged: (v) => setState(() => fontSize = v),
                      ),
                    ),
                  ),
                  _textBtn(
                    'Edit',
                    showEditBar ? AppTheme.accent : subtextColor,
                    () => setState(() {
                      showTileParameters = false;
                      showEditBar = !showEditBar;
                    }),
                  ),
                  const SizedBox(width: 6),
                  // Go button
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        AppTheme.fade(const PerformanceScreen())),
                    child: Container(
                      width: 52,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C5CFC), Color(0xFF9E82FF)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'GO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Item tile ─────────────────────────────────────────────
  Widget _buildItemTile(SetlistItemModel item, bool dark, bool locked) {
    final color = AppTheme.itemColor(item.textColor, dark);
    final barColor = AppTheme.itemBarColor(item.textColor);
    final surface = AppTheme.surface(dark);
    final subtextColor = AppTheme.subtext(dark);
    final borderColor = AppTheme.border(dark);

    Widget content;

    if (item.type == 'break') {
      content = AnimatedContainer(
        key: ValueKey(item.id),
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: barColor.withValues(alpha: 0.08),
          border: Border(
            bottom: BorderSide(color: borderColor, width: 0.5),
            left: BorderSide(color: barColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  item.label ?? '— BREAK —',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize * 0.7,
                    color: color.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (item.type == 'note') {
      content = AnimatedContainer(
        key: ValueKey(item.id),
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.surface2(dark),
          border: Border(
            bottom: BorderSide(color: borderColor, width: 0.5),
            left: BorderSide(color: barColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Icon(Icons.sticky_note_2_outlined,
                  size: 14, color: subtextColor),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
                child: Text(
                  item.label ?? '',
                  style: TextStyle(
                    fontSize: fontSize * 0.65,
                    color: subtextColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      final song = item.song;
      final subtitleParts = <String>[];
      if (showArtist && song?.artist != null) subtitleParts.add(song!.artist!);
      if (showBpm && song?.bpm != null) {
        subtitleParts.add('${song!.bpm} bpm');
      }
      if (showLength && song?.length != null) {
        subtitleParts.add(_formatLength(song!.length!));
      }

      content = AnimatedContainer(
        key: ValueKey(item.id),
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: surface,
          border: Border(
            bottom: BorderSide(color: borderColor, width: 0.5),
            left: BorderSide(color: barColor, width: 3),
          ),
        ),
        child: InkWell(
          onTap: locked ? null : () => _onItemTap(item),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        song?.title ?? '',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: color,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (subtitleParts.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitleParts.join('  ·  '),
                          style: TextStyle(
                            fontSize: fontSize * 0.52,
                            color: subtextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                      if (showNotes && song?.notes != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          song!.notes!,
                          style: TextStyle(
                            fontSize: fontSize * 0.5,
                            color: subtextColor.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (showKey && (song?.key ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: barColor == Colors.transparent
                          ? AppTheme.surface2(dark)
                          : barColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: barColor == Colors.transparent
                            ? AppTheme.border(dark)
                            : barColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      song!.key!,
                      style: TextStyle(
                        fontSize: fontSize * 0.62,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (locked) return content;

    return Dismissible(
      key: ValueKey('d_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Color(0xFFFF4444)],
          ),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => _confirmDialog('Remove item?', 'Remove'),
        );
      },
      onDismissed: (_) =>
          ref.read(currentSetlistProvider.notifier).removeItem(item),
      child: content,
    );
  }

  // ── Params bar ────────────────────────────────────────────
  Widget _buildParamsBar(
      bool dark, Color surface, Color borderColor) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.5 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _chip('KEY', showKey, () => setState(() => showKey = !showKey)),
          _chip('ARTIST', showArtist,
              () => setState(() => showArtist = !showArtist)),
          _chip('BPM', showBpm,
              () => setState(() => showBpm = !showBpm)),
          _chip('LENGTH', showLength,
              () => setState(() => showLength = !showLength)),
          _chip('NOTES', showNotes,
              () => setState(() => showNotes = !showNotes)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.accentSoft
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppTheme.accent : AppTheme.border(false),
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppTheme.accent : AppTheme.subtext(false),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Edit bar ──────────────────────────────────────────────
  Widget _buildEditBar(
      CurrentSetlistNotifier notifier,
      bool locked,
      List<SetlistItemModel> items,
      bool dark,
      Color surface,
      Color borderColor,
      Color textColor) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.5 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: locked
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_rounded,
                      size: 16, color: AppTheme.subtext(dark)),
                  const SizedBox(width: 8),
                  Text('Setlist is locked',
                      style: TextStyle(
                          color: AppTheme.subtext(dark), fontSize: 14)),
                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _colorDot(
                  const Color(0xFFAA88FF),
                  isPurpleSelected,
                  () => setState(() {
                    isPurpleSelected = !isPurpleSelected;
                    isRedSelected = isOrangeSelected = false;
                    selectedColor = isPurpleSelected ? 'purple' : '';
                  }),
                ),
                _colorDot(
                  const Color(0xFFFF6B6B),
                  isRedSelected,
                  () => setState(() {
                    isRedSelected = !isRedSelected;
                    isPurpleSelected = isOrangeSelected = false;
                    selectedColor = isRedSelected ? 'red' : '';
                  }),
                ),
                _colorDot(
                  const Color(0xFFFFAA55),
                  isOrangeSelected,
                  () => setState(() {
                    isOrangeSelected = !isOrangeSelected;
                    isPurpleSelected = isRedSelected = false;
                    selectedColor = isOrangeSelected ? 'orange' : '';
                  }),
                ),
                _editPill('BREAK', () => _addBreak(notifier, items)),
                _editPill('NOTE', () => _addQuickNote(notifier, items)),
                GestureDetector(
                  onTap: () => _handleTrash(notifier),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.surface2(dark),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: Color(0xFFFF6B6B)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _colorDot(Color color, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        width: selected ? 34 : 28,
        height: selected ? 34 : 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          // Keep boxShadow list consistent (same length) to avoid lerp bug
          boxShadow: [
            BoxShadow(
              color: selected
                  ? color.withValues(alpha: 0.5)
                  : color.withValues(alpha: 0),
              blurRadius: 10,
            ),
          ],
          border: Border.all(
            color: selected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
        ),
      ),
    );
  }

  Widget _editPill(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface2(ref.read(darkModeProvider)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border(ref.read(darkModeProvider))),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppTheme.text(ref.read(darkModeProvider)),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22, color: color),
      splashRadius: 20,
    );
  }

  Widget _textBtn(String label, Color color, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(40, 36),
      ),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _confirmDialog(String title, String confirmLabel) {
    return AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF4444)),
            child: Text(confirmLabel)),
      ],
    );
  }

  void _onItemTap(SetlistItemModel item) {
    if (selectedColor.isEmpty) return;
    ref.read(currentSetlistProvider.notifier).setItemColor(item, selectedColor);
  }

  String _getHeaderLabel(PlaylistModel? pl) {
    if (pl == null) return 'Setlist';
    switch (_titleCycleFields[_titleCycleIndex]) {
      case 'title':
        return pl.title.isEmpty ? 'Setlist' : pl.title;
      case 'artist':
        return (pl.artist?.isNotEmpty == true) ? pl.artist! : 'Setlist';
      case 'date':
        if (pl.date == null) return 'Setlist';
        final dmy = ref.read(appSettingsProvider).dateFormatDMY;
        return dmy
            ? '${pl.date!.day}/${pl.date!.month}/${pl.date!.year}'
            : '${pl.date!.month}/${pl.date!.day}/${pl.date!.year}';
      case 'venue':
        return (pl.venue?.isNotEmpty == true) ? pl.venue! : 'Setlist';
      case 'city':
        return (pl.city?.isNotEmpty == true) ? pl.city! : 'Setlist';
      default:
        return 'Setlist';
    }
  }

  void _addBreak(
      CurrentSetlistNotifier notifier, List<SetlistItemModel> items) {
    final playlistId = notifier.playlist!.id;
    notifier.addItem(SetlistItemModel(
      Uuid.v4(), 'break', playlistId,
      sortOrder: items.length,
    ));
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
          FilledButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('Add')),
        ],
      ),
    );
    if (text != null && text.isNotEmpty) {
      final playlistId = notifier.playlist!.id;
      notifier.addItem(SetlistItemModel(
        Uuid.v4(), 'note', playlistId,
        label: text, sortOrder: items.length,
      ));
    }
  }

  void _handleTrash(CurrentSetlistNotifier notifier) async {
    if (selectedColor.isNotEmpty) {
      notifier.deleteColorItems(selectedColor);
    } else {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => _confirmDialog('Clear entire setlist?', 'Clear'),
      );
      if (ok == true) notifier.clearAll();
    }
  }

  void _showExportSheet(
      PlaylistModel? playlist, CurrentSetlistNotifier notifier) {
    if (playlist == null) return;
    final items = notifier.items;
    final settings = ref.read(appSettingsProvider);
    final realm = ref.read(realmProvider);
    final dark = ref.read(darkModeProvider);
    final surface = AppTheme.surface(dark);
    final textColor = AppTheme.text(dark);

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.border(dark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _sheetTile(Icons.text_snippet_outlined, 'Share as text',
                  textColor, () {
                Navigator.pop(context);
                ExportService.instance.shareSetlistAsText(playlist, items);
              }),
              _sheetTile(Icons.picture_as_pdf_outlined, 'Print / Save PDF',
                  textColor, () {
                Navigator.pop(context);
                ExportService.instance
                    .printSetlistPdf(playlist, items, settings);
              }),
              _sheetTile(Icons.cloud_upload_outlined, 'Backup full library',
                  textColor, () {
                Navigator.pop(context);
                ExportService.instance.exportBackupJson(realm);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetTile(
      IconData icon, String title, Color textColor, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.accentSoft,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.accent, size: 18),
      ),
      title: Text(title,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.w500, fontSize: 15)),
      onTap: onTap,
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
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Edit Setlist'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 10),
                TextField(
                    controller: artistCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Artist')),
                const SizedBox(height: 10),
                TextField(
                    controller: venueCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Venue')),
                const SizedBox(height: 10),
                TextField(
                    controller: cityCtrl,
                    decoration:
                        const InputDecoration(labelText: 'City')),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      selectedDate != null
                          ? '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}'
                          : 'No date set',
                      style: TextStyle(
                          color: AppTheme.subtext(
                              ref.read(darkModeProvider))),
                    ),
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
                          setSt(() => selectedDate = picked);
                        }
                      },
                      child: const Text('Pick date'),
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
            FilledButton(
              onPressed: () {
                notifier.updateMeta((pl) {
                  pl.title = titleCtrl.text;
                  pl.artist =
                      artistCtrl.text.isNotEmpty ? artistCtrl.text : null;
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
    Navigator.push(
        context, AppTheme.slideUp(const SongsScreen()));
  }
}
