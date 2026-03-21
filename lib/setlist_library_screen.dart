import 'package:allset/app_theme.dart';
import 'package:allset/models/models.dart';
import 'package:allset/providers/app_settings_provider.dart';
import 'package:allset/providers/dark_mode_provider.dart';
import 'package:allset/providers/setlist_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:intl/intl.dart';

class SetlistLibraryScreen extends ConsumerStatefulWidget {
  const SetlistLibraryScreen({super.key});

  @override
  ConsumerState<SetlistLibraryScreen> createState() =>
      _SetlistLibraryScreenState();
}

class _SetlistLibraryScreenState extends ConsumerState<SetlistLibraryScreen> {
  Uuid? activeFolderId;

  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(darkModeProvider);
    final setlists = ref.watch(setlistLibraryProvider);
    final notifier = ref.read(setlistLibraryProvider.notifier);
    final folders = ref.watch(setlistFolderProvider);
    final folderNotifier = ref.read(setlistFolderProvider.notifier);
    final dateFormatDMY = ref.watch(appSettingsProvider).dateFormatDMY;
    final bgColor = AppTheme.bg(darkMode);
    final fontColor = AppTheme.text(darkMode);

    final visibleSetlists = activeFolderId != null
        ? setlists.where((pl) => pl.folderId == activeFolderId).toList()
        : folders.isEmpty
            ? setlists
            : setlists.where((pl) => pl.folderId == null).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.surface(darkMode),
                border: Border(
                    bottom: BorderSide(
                        color: AppTheme.border(darkMode), width: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded,
                        color: AppTheme.subtext(darkMode)),
                  ),
                  Text('Setlists',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: fontColor,
                          letterSpacing: -0.3)),
                  IconButton(
                    onPressed: () => _createNew(notifier),
                    icon: Icon(Icons.add_rounded, color: AppTheme.accent),
                  ),
                ],
              ),
            ),

              // Folder strip
              if (folders.isNotEmpty)
                _buildFolderStrip(folders, folderNotifier, fontColor),

              // Setlist list
              Expanded(
                child: visibleSetlists.isEmpty
                    ? Center(
                        child: Text('No setlists yet',
                            style: TextStyle(color: fontColor)))
                    : ReorderableListView(
                        onReorder: notifier.reorder,
                        children: [
                          for (final pl in visibleSetlists)
                            _SetlistTile(
                              key: ValueKey(pl.id),
                              playlist: pl,
                              darkMode: darkMode,
                              folders: folders,
                              dateFormatDMY: dateFormatDMY,
                              onTap: () {
                                ref
                                    .read(currentSetlistProvider.notifier)
                                    .load(pl);
                                Navigator.pop(context);
                              },
                              onDelete: () =>
                                  _confirmDelete(notifier, pl),
                              onMoveToFolder: folders.isEmpty
                                  ? null
                                  : () => _moveToFolder(pl, folders),
                            ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderStrip(List<FolderModel> folders,
      SetlistFolderNotifier folderNotifier, Color fontColor) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: const Text('All'),
              selected: activeFolderId == null,
              onSelected: (_) => setState(() => activeFolderId = null),
            ),
          ),
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
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, size: 20),
            onPressed: () => _createFolder(folderNotifier),
          ),
        ],
      ),
    );
  }

  void _createNew(SetlistLibraryNotifier notifier) {
    final pl = PlaylistModel(Uuid.v4(), '',
        sortOrder: ref.read(setlistLibraryProvider).length);
    notifier.add(pl);
    if (activeFolderId != null) {
      notifier.setFolder(pl, activeFolderId);
    }
    ref.read(currentSetlistProvider.notifier).load(pl);
    Navigator.pop(context);
  }

  void _confirmDelete(
      SetlistLibraryNotifier notifier, PlaylistModel pl) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete setlist?'),
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
    if (confirmed == true) notifier.delete(pl);
  }

  void _createFolder(SetlistFolderNotifier notifier) async {
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
      FolderModel folder, SetlistFolderNotifier notifier) async {
    final action = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(folder.name),
        children: [
          SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'rename'),
              child: const Text('Rename')),
          SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: const Text('Delete folder',
                  style: TextStyle(color: Colors.red))),
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
      ref.read(setlistLibraryProvider.notifier).clearFolderAssignments(folder.id);
      notifier.deleteFolder(folder);
      if (activeFolderId == folder.id) setState(() => activeFolderId = null);
    }
  }

  void _moveToFolder(PlaylistModel pl, List<FolderModel> folders) async {
    final folder = await showDialog<FolderModel?>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Move to Folder'),
        children: [
          SimpleDialogOption(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Remove from folder')),
          for (final f in folders)
            SimpleDialogOption(
                onPressed: () => Navigator.pop(context, f),
                child: Text(f.name)),
        ],
      ),
    );
    ref.read(setlistLibraryProvider.notifier).setFolder(pl, folder?.id);
  }
}

class _SetlistTile extends ConsumerWidget {
  final PlaylistModel playlist;
  final bool darkMode;
  final List<FolderModel> folders;
  final bool dateFormatDMY;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onMoveToFolder;

  const _SetlistTile({
    super.key,
    required this.playlist,
    required this.darkMode,
    required this.folders,
    required this.dateFormatDMY,
    required this.onTap,
    required this.onDelete,
    this.onMoveToFolder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = AppTheme.text(darkMode);
    final subtextColor = AppTheme.subtext(darkMode);
    final borderColor = AppTheme.border(darkMode);
    final surface = AppTheme.surface(darkMode);
    final label = _label();
    final sub = _subtitle();

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(width: 3, height: 60, color: AppTheme.accent.withValues(alpha: 0.3)),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: -0.3)),
                    if (sub.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(sub,
                          style:
                              TextStyle(color: subtextColor, fontSize: 13)),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (onMoveToFolder != null)
            IconButton(
              icon: Icon(Icons.drive_file_move_outlined,
                  size: 18, color: subtextColor),
              onPressed: onMoveToFolder,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFFF6B6B), size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      dateFormatDMY ? DateFormat('d/M/y').format(dt) : DateFormat('M/d/y').format(dt);

  String _label() {
    if (playlist.title.isNotEmpty) return playlist.title;
    if (playlist.artist != null && playlist.artist!.isNotEmpty) {
      return playlist.artist!;
    }
    if (playlist.date != null) return _formatDate(playlist.date!);
    return _formatDate(DateTime.now());
  }

  String _subtitle() {
    final parts = <String>[];
    if (playlist.venue != null && playlist.venue!.isNotEmpty) {
      parts.add(playlist.venue!);
    }
    if (playlist.city != null && playlist.city!.isNotEmpty) {
      parts.add(playlist.city!);
    }
    if (playlist.date != null) {
      parts.add(_formatDate(playlist.date!));
    }
    return parts.join(' · ');
  }
}
