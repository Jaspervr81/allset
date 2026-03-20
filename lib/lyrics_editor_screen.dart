import 'package:allset/models/song_model.dart';
import 'package:allset/providers/dark_mode_provider.dart';
import 'package:allset/providers/song_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LyricsEditorScreen extends ConsumerStatefulWidget {
  final SongModel song;
  const LyricsEditorScreen({required this.song, super.key});

  @override
  ConsumerState<LyricsEditorScreen> createState() => _LyricsEditorScreenState();
}

class _LyricsEditorScreenState extends ConsumerState<LyricsEditorScreen> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.song.lyrics ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(darkModeProvider);
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
                    Text(widget.song.title,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: fontColor)),
                    TextButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _ctrl,
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(color: fontColor, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Enter lyrics...',
                      hintStyle: TextStyle(color: fontColor.withValues(alpha: 0.4)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    ref.read(songLibraryProvider.notifier).updateSong(
        widget.song, (s) => s.lyrics = _ctrl.text.isEmpty ? null : _ctrl.text);
    Navigator.pop(context);
  }
}
