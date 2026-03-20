import 'package:allset/models/song_model.dart';
import 'package:allset/providers/dark_mode_provider.dart';
import 'package:allset/providers/setlist_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:intl/intl.dart';

class SetlistLibraryScreen extends ConsumerWidget {
  const SetlistLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    final setlists = ref.watch(setlistLibraryProvider);
    final notifier = ref.read(setlistLibraryProvider.notifier);
    final bgColor = darkMode ? Colors.black : Colors.white;
    final fontColor = darkMode ? Colors.white : Colors.black;

    return Scaffold(
      body: Container(
        color: bgColor,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    Text('Setlists',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: fontColor)),
                    IconButton(
                      onPressed: () => _createNew(context, ref, notifier),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: setlists.isEmpty
                    ? Center(
                        child: Text('No setlists yet',
                            style: TextStyle(color: fontColor)))
                    : ReorderableListView(
                        onReorder: notifier.reorder,
                        children: [
                          for (final pl in setlists)
                            _SetlistTile(
                              key: ValueKey(pl.id),
                              playlist: pl,
                              darkMode: darkMode,
                              onTap: () {
                                ref
                                    .read(currentSetlistProvider.notifier)
                                    .load(pl);
                                Navigator.pop(context);
                              },
                              onDelete: () => _confirmDelete(
                                  context, ref, notifier, pl),
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

  void _createNew(BuildContext context, WidgetRef ref,
      SetlistLibraryNotifier notifier) {
    final pl = PlaylistModel(Uuid.v4(), '',
        sortOrder: ref.read(setlistLibraryProvider).length);
    notifier.add(pl);
    ref.read(currentSetlistProvider.notifier).load(pl);
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref,
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
}

class _SetlistTile extends ConsumerWidget {
  final PlaylistModel playlist;
  final bool darkMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SetlistTile({
    super.key,
    required this.playlist,
    required this.darkMode,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontColor = darkMode ? Colors.white : Colors.black;
    final label = _label();
    final sub = _subtitle();

    return ListTile(
      title: Text(label,
          style: TextStyle(color: fontColor, fontWeight: FontWeight.bold)),
      subtitle: sub.isNotEmpty
          ? Text(sub, style: TextStyle(color: fontColor.withValues(alpha: 0.6)))
          : null,
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
    );
  }

  String _label() {
    if (playlist.title.isNotEmpty) return playlist.title;
    if (playlist.artist != null && playlist.artist!.isNotEmpty) {
      return playlist.artist!;
    }
    if (playlist.date != null) {
      return DateFormat('M/d/y').format(playlist.date!);
    }
    return DateFormat('M/d/y').format(DateTime.now());
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
      parts.add(DateFormat('M/d/y').format(playlist.date!));
    }
    return parts.join(' · ');
  }
}
