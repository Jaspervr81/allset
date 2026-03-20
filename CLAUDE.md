# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Analyze / lint
flutter analyze

# Run tests
flutter test

# Regenerate Realm models (required when song_model.dart is modified)
flutter pub run build_runner build

# Release builds
flutter build apk    # Android
flutter build ios    # iOS
```

## Architecture

**AllSet** is a Flutter (Dart) setlist management app for musicians. It uses Material Design 3.

### Screens & Navigation
Uses basic `Navigator.push()` / `MaterialPageRoute` — no router package.

- `main_screen.dart` — Home screen, displays and manages the current setlist
- `songs_screen.dart` — Song library; create and view songs
- `performance_screen.dart` — Live performance view (WIP placeholder)

### State Management
Stateful widgets only — no Provider, Riverpod, Bloc, etc. Each screen manages its own state via `setState()`.

### Data Layer
- **Realm** (`realm: ^20.0.0`) for persistent storage of songs and playlists
- Models defined in `lib/models/song_model.dart` using `@RealmModel()` annotations on private classes (`_SongModel`, `_PlaylistModel`)
- `lib/models/song_model.realm.dart` is **generated code** — do not edit manually; regenerate with `build_runner` after model changes
- **shared_preferences** stores user settings (dark mode toggle)

### Key Models
- `SongModel` — title (required), artist, key, bpm, length (seconds), notes, textColor (for UI color coding: 'purple'/'red'/'orange')
- `PlaylistModel` — name (required), artist, date, venue, city, songs (List\<SongModel\>)

### Settings
`lib/settings.dart` — `Settings` class wraps SharedPreferences for dark mode persistence. Instantiated per-screen.
