import 'dart:async';
import 'package:allset/providers/app_settings_provider.dart';
import 'package:allset/providers/dark_mode_provider.dart';
import 'package:allset/providers/setlist_providers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});

  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  late Timer _clockTimer;
  Timer? _metronomeTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  DateTime _now = DateTime.now();
  int _currentIndex = 0;
  bool _showLyrics = false;
  bool _metronomeRunning = false;
  bool _metronomeBeat = false;
  bool _showFullscreen = false;
  CurrentSetlistNotifier? _setlistNotifier;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setlistNotifier = ref.read(currentSetlistProvider.notifier);
      _setlistNotifier!.lock(true);
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _metronomeTimer?.cancel();
    _audioPlayer.dispose();
    _setlistNotifier?.lock(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(darkModeProvider);
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(currentSetlistProvider.notifier);
    final items = notifier.items.where((i) => i.type == 'song').toList();

    final bgColor = darkMode ? Colors.black : Colors.grey[900]!;

    final currentItem =
        items.isNotEmpty && _currentIndex < items.length
            ? items[_currentIndex]
            : null;
    final currentSong = currentItem?.song;

    final clockStr = settings.clock24h
        ? DateFormat('HH:mm:ss').format(_now)
        : DateFormat('h:mm:ss a').format(_now);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      Text(clockStr,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 18)),
                    ],
                  ),
                ),

                // Current song display
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showFullscreen = true),
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity == null) return;
                      if (details.primaryVelocity! < -300 &&
                          _currentIndex < items.length - 1) {
                        setState(() {
                          _currentIndex++;
                          _showLyrics = false;
                          _stopMetronome();
                        });
                      } else if (details.primaryVelocity! > 300 &&
                          _currentIndex > 0) {
                        setState(() {
                          _currentIndex--;
                          _showLyrics = false;
                          _stopMetronome();
                        });
                      }
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentSong != null) ...[
                            Text(
                              currentSong.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            if (currentSong.key != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(currentSong.key!,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 28)),
                              ),
                            if (currentSong.artist != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(currentSong.artist!,
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 22)),
                              ),
                          ] else
                            Text(
                              items.isEmpty ? 'No songs in setlist' : 'End of set',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 32),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Lyrics panel
                if (_showLyrics && currentSong?.lyrics != null)
                  Container(
                    height: 200,
                    color: Colors.black54,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(
                        currentSong!.lyrics!,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                // Controls
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: _currentIndex > 0
                            ? () => setState(() {
                                  _currentIndex--;
                                  _showLyrics = false;
                                  _stopMetronome();
                                })
                            : null,
                        icon: const Icon(Icons.skip_previous,
                            color: Colors.white, size: 40),
                      ),
                      if (currentSong?.bpm != null)
                        GestureDetector(
                          onTap: _toggleMetronome,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 80),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _metronomeBeat
                                  ? Colors.white
                                  : (_metronomeRunning
                                      ? Colors.teal
                                      : Colors.grey[700]!),
                            ),
                            child: Icon(
                              _metronomeRunning ? Icons.pause : Icons.play_arrow,
                              color: _metronomeBeat ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      if (currentSong?.lyrics != null)
                        IconButton(
                          onPressed: () =>
                              setState(() => _showLyrics = !_showLyrics),
                          icon: Icon(Icons.lyrics,
                              color: _showLyrics ? Colors.teal : Colors.white,
                              size: 32),
                        ),
                      IconButton(
                        onPressed: _currentIndex < items.length - 1
                            ? () => setState(() {
                                  _currentIndex++;
                                  _showLyrics = false;
                                  _stopMetronome();
                                })
                            : null,
                        icon: const Icon(Icons.skip_next,
                            color: Colors.white, size: 40),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Fullscreen overlay
            if (_showFullscreen && currentSong != null)
              GestureDetector(
                onTap: () => setState(() => _showFullscreen = false),
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      currentSong.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _toggleMetronome() {
    final notifier = ref.read(currentSetlistProvider.notifier);
    final items = notifier.items.where((i) => i.type == 'song').toList();
    if (_currentIndex >= items.length) return;
    final bpm = items[_currentIndex].song?.bpm;
    if (bpm == null) return;

    if (_metronomeRunning) {
      _stopMetronome();
    } else {
      final interval = Duration(milliseconds: (60000 / bpm).round());
      setState(() => _metronomeRunning = true);
      _metronomeTimer = Timer.periodic(interval, (_) {
        if (!mounted) return;
        _tick();
      });
    }
  }

  void _tick() {
    setState(() => _metronomeBeat = true);
    HapticFeedback.lightImpact();
    _audioPlayer.play(AssetSource('sounds/tick.wav'),
        volume: 1.0, mode: PlayerMode.lowLatency);
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) setState(() => _metronomeBeat = false);
    });
  }

  void _stopMetronome() {
    _metronomeTimer?.cancel();
    setState(() {
      _metronomeRunning = false;
      _metronomeBeat = false;
    });
  }
}
