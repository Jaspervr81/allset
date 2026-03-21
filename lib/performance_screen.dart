import 'dart:async';
import 'package:allset/app_theme.dart';
import 'package:allset/providers/app_settings_provider.dart';
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

class _PerformanceScreenState extends ConsumerState<PerformanceScreen>
    with TickerProviderStateMixin {
  late Timer _clockTimer;
  Timer? _metronomeTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  DateTime _now = DateTime.now();
  int _currentIndex = 0;
  bool _showLyrics = false;
  bool _metronomeRunning = false;
  bool _metronomeBeat = false;
  bool _showFullscreen = false;
  bool _goingForward = true;
  CurrentSetlistNotifier? _setlistNotifier;

  // Metronome pulse animation
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() => _now = DateTime.now()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setlistNotifier = ref.read(currentSetlistProvider.notifier);
      _setlistNotifier!.lock(true);
    });

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _metronomeTimer?.cancel();
    _audioPlayer.dispose();
    _pulseCtrl.dispose();
    // Defer provider write outside tree finalization
    Future.microtask(() => _setlistNotifier?.lock(false));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(currentSetlistProvider.notifier);
    final items = notifier.items.where((i) => i.type == 'song').toList();

    final currentItem = (items.isNotEmpty && _currentIndex < items.length)
        ? items[_currentIndex]
        : null;
    final currentSong = currentItem?.song;

    final clockStr = settings.clock24h
        ? DateFormat('HH:mm').format(_now)
        : DateFormat('h:mm').format(_now);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Top bar ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white54, size: 22),
                      ),
                      Text(
                        clockStr,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Progress dots ─────────────────────────
                if (items.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 16),
                          for (int i = 0; i < items.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              width: i == _currentIndex ? 22 : 6,
                              height: 6,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: i == _currentIndex
                                    ? AppTheme.accent
                                    : Colors.white24,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),

                // ── Song display ──────────────────────────
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        setState(() => _showFullscreen = true),
                    onHorizontalDragEnd: (d) {
                      if (d.primaryVelocity == null) return;
                      if (d.primaryVelocity! < -300 &&
                          _currentIndex < items.length - 1) {
                        setState(() {
                          _goingForward = true;
                          _currentIndex++;
                          _showLyrics = false;
                          _stopMetronome();
                        });
                      } else if (d.primaryVelocity! > 300 &&
                          _currentIndex > 0) {
                        setState(() {
                          _goingForward = false;
                          _currentIndex--;
                          _showLyrics = false;
                          _stopMetronome();
                        });
                      }
                    },
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutQuart,
                        switchOutCurve: Curves.easeInQuart,
                        transitionBuilder: (child, anim) {
                          final slideIn = Tween<Offset>(
                            begin: Offset(_goingForward ? 0.12 : -0.12, 0),
                            end: Offset.zero,
                          ).animate(anim);
                          return FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                                position: slideIn, child: child),
                          );
                        },
                        child: currentSong != null
                            ? _SongDisplay(
                                key: ValueKey(currentSong.id),
                                song: currentSong,
                                index: _currentIndex,
                                total: items.length,
                              )
                            : Center(
                                key: const ValueKey('empty'),
                                child: Text(
                                  items.isEmpty
                                      ? 'No songs in setlist'
                                      : 'End of set',
                                  style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                // ── Lyrics panel — slides up ───────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height:
                      (_showLyrics && currentSong?.lyrics != null) ? 200 : 0,
                  child: ClipRect(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        border: const Border(
                            top: BorderSide(
                                color: Colors.white10, width: 0.5)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Text(
                          currentSong?.lyrics ?? '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Controls ──────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Prev
                      _navBtn(
                        Icons.skip_previous_rounded,
                        _currentIndex > 0,
                        () => setState(() {
                          _goingForward = false;
                          _currentIndex--;
                          _showLyrics = false;
                          _stopMetronome();
                        }),
                      ),

                      // Metronome
                      if (currentSong?.bpm != null)
                        GestureDetector(
                          onTap: _toggleMetronome,
                          child: ScaleTransition(
                            scale: _pulseAnim,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _metronomeBeat
                                    ? Colors.white
                                    : (_metronomeRunning
                                        ? AppTheme.accent
                                        : Colors.white12),
                                boxShadow: _metronomeRunning
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.accent
                                              .withValues(alpha: 0.5),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                _metronomeRunning
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: _metronomeBeat
                                    ? Colors.black
                                    : Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),

                      // Lyrics toggle
                      if (currentSong?.lyrics != null)
                        _controlBtn(
                          Icons.lyrics_rounded,
                          _showLyrics
                              ? AppTheme.accent
                              : Colors.white38,
                          () => setState(
                              () => _showLyrics = !_showLyrics),
                        ),

                      // Next
                      _navBtn(
                        Icons.skip_next_rounded,
                        _currentIndex < items.length - 1,
                        () => setState(() {
                          _goingForward = true;
                          _currentIndex++;
                          _showLyrics = false;
                          _stopMetronome();
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Fullscreen overlay ─────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showFullscreen && currentSong != null
                  ? GestureDetector(
                      key: const ValueKey('fullscreen'),
                      onTap: () =>
                          setState(() => _showFullscreen = false),
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              currentSong.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 72,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                letterSpacing: -2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('hidden')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.2,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _controlBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  void _toggleMetronome() {
    final notifier = ref.read(currentSetlistProvider.notifier);
    final items =
        notifier.items.where((i) => i.type == 'song').toList();
    if (_currentIndex >= items.length) return;
    final bpm = items[_currentIndex].song?.bpm;
    if (bpm == null) return;

    if (_metronomeRunning) {
      _stopMetronome();
    } else {
      final interval =
          Duration(milliseconds: (60000 / bpm).round());
      setState(() => _metronomeRunning = true);
      _metronomeTimer = Timer.periodic(interval, (_) {
        if (!mounted) return;
        _tick();
      });
    }
  }

  void _tick() {
    setState(() => _metronomeBeat = true);
    _pulseCtrl.forward(from: 0);
    HapticFeedback.lightImpact();
    _audioPlayer.play(AssetSource('sounds/tick.wav'),
        volume: 1.0, mode: PlayerMode.lowLatency);
    Future.delayed(const Duration(milliseconds: 100), () {
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

/// Stateless song display widget — enables AnimatedSwitcher to work
class _SongDisplay extends StatelessWidget {
  final dynamic song;
  final int index;
  final int total;

  const _SongDisplay({
    super.key,
    required this.song,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (song.key != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentSoft,
                borderRadius: BorderRadius.circular(10),
                border:
                    Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
              ),
              child: Text(
                song.key!,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            song.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              height: 1.05,
            ),
          ),
          if (song.artist != null) ...[
            const SizedBox(height: 12),
            Text(
              song.artist!,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          if (song.bpm != null) ...[
            const SizedBox(height: 8),
            Text(
              '${song.bpm} bpm',
              style: const TextStyle(
                color: Colors.white24,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
