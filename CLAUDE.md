# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on macOS (primary platform)
flutter run -d macos

# Build
flutter build macos --debug
flutter build macos --release

# Analyze
flutter analyze lib/

# Add a dependency
flutter pub add <package>
flutter pub get
```

There are no tests yet.

## What this is

**Pomoden** (Pomodoro + Den) — a macOS desktop study companion app. Users study alongside 1–4 virtual animal characters that react during breaks via the Claude API. Characters have monthly session limits as the monetisation mechanism.

**Stack:** Flutter/Dart · Riverpod (state) · Claude API (AI messages) · SharedPreferences (usage persistence) · `window_manager` (frameless macOS window, fixed 1100×750)

## Architecture

### State flow

```
SessionEngine (Stream) → sessionStateProvider → HomeScreen
                                                  ├── SetupScreen   (phase: idle)
                                                  └── SessionScreen (phase: active)
```

`SessionEngine` is a plain Dart class with a broadcast `StreamController`. It owns the pomodoro state machine and ticks on a 1-second `Timer`. Everything else reacts to its stream.

`CharacterNotifier` is a Riverpod `StateNotifier<List<Character>>` that holds **only the session's selected characters** (empty outside a session). It listens to session state changes via `HomeScreen.initState → updateMoodsForSession()`, handles break message prefetching, and mood/message updates.

### Session lifecycle

1. User selects characters in `SetupScreen` (`characterSelectionProvider`)
2. "Start session" calls:
   - `CharacterNotifier.initForSession(ids)` — filters `CharacterPresets.all` to selected subset
   - `CharacterUsageNotifier.increment(id)` — persists usage to SharedPreferences for each character
   - `SessionEngine.startSession(config)` — starts the timer stream
3. `HomeScreen` detects non-idle state → renders `SessionScreen`
4. Session completes → `SessionCompleteOverlay` → `engine.abandonSession()` → back to idle

### Phase state machine (SessionEngine)

`studying → breaking → transition → studying` (repeats per block)  
Last block: `studying → sessionEnd`  
Manual: `any active → interrupted → resume → studying`

### Providers

| Provider | Type | Purpose |
|---|---|---|
| `sessionEngineProvider` | `Provider` | Single `SessionEngine` instance |
| `sessionStateProvider` | `StreamProvider` | Live `SessionState` from engine stream |
| `characterProvider` | `StateNotifierProvider` | Characters in the current session |
| `characterUsageProvider` | `StateNotifierProvider<Map<String,int>>` | Monthly session counts, persisted in SharedPreferences |
| `characterSelectionProvider` | `StateNotifierProvider<List<String>>` | Selected character IDs for the next session (max 4) |
| `claudeServiceProvider` | `FutureProvider` | `ClaudeService?` — null if no API key saved |
| `settingsServiceProvider` | `Provider` | Reads/writes API key from `getApplicationSupportDirectory()` |

### AI message pipeline

`BreakMessageService` picks a random speaker → calls `ClaudeService.generateBreakMessage()` → appends to session conversation history (capped at 6 messages). Pre-fetches the next break message in the final 15 seconds of a study block to eliminate latency. Falls back silently to pre-written lines on API failure.

### Character system

All 15 characters are defined as `const` in `CharacterPresets` (`lib/models/character.dart`). Each has `monthlySessionLimit`, `relationships` (map of character ID → relationship description injected into Claude prompts), `personality`, and `voiceDescription`. Monthly usage resets on the 1st of each month via `CharacterUsageNotifier`.

### Key conventions (keep reading below for build status / TODO)

- **File organisation:** split files that grow past ~150 lines; picker/card widgets go in `lib/widgets/`, not screens
- **Colours/theme:** use `AppColors` constants from `lib/theme/app_theme.dart`; use `.withValues(alpha:)` not the deprecated `.withOpacity()`
- **Logging:** use `debugPrint`, never `print`
- **Session durations** in the current build are in seconds (not minutes) for fast testing — PRD values are in minutes

## Build status & TODO

### Phase 1 — in active development

| Status | Feature | Notes |
|---|---|---|
| ✅ | Pomodoro session engine | 5-phase state machine |
| ✅ | Session setup screen | blocks, durations, subject |
| ✅ | Character room UI | 1/2/2×2 grid, dark background, phase-aware colours |
| ✅ | Bob animation | Flutter transform loop |
| ✅ | Mood dot system | phase-aware colours |
| ✅ | AI break messages | Claude API, in-character, 20-word cap, 6-message history |
| ✅ | API failure fallback | silent chat-only fallback |
| ✅ | Settings screen | API key stored in app support directory |
| ✅ | All 15 characters | `CharacterPresets` in `lib/models/character.dart` |
| ✅ | Character session limit system | `CharacterUsageNotifier`, SharedPreferences, monthly reset |
| ✅ | Character picker | setup screen, 3-col grid, exhausted/at-max states |
| 🔄 | Inter-character banter | `relationships` map exists on `Character` model but not yet injected into Claude prompt in `ClaudeService` |
| ⬜ | Session interruption UX | lid close / lock screen — `SessionPhase.interrupted` exists but no automatic detection |
| ⬜ | Early exit reactions | personality-based reactions when user stops mid-session |
| ⬜ | Session config presets | save + reuse named configs |
| ⬜ | Ambient sound engine | no audio deps yet |
| ⬜ | Backend (Node.js + Supabase) | currently direct API key; proxy + auth + Stripe needed |
| ⬜ | Wake everyone up unlock | $2.99 Stripe one-time purchase to reset all character limits |
| ⬜ | Character images (7 missing) | mochi, quill, bramble, pebble, boba, ziggy, cosmo — placeholder letter shown |

### Phase 2

| Status | Feature |
|---|---|
| ⬜ | ElevenLabs TTS + location profiles (home/library/cafe) |
| ⬜ | Character creator |
| ⬜ | Saved squads |
| ⬜ | Camera — face presence (MediaPipe, Dart Isolate) |
| ⬜ | AI video animations via Kling/Runway |

### Phase 3

| Status | Feature |
|---|---|
| ⬜ | Gaze / attention detection |
| ⬜ | Phone detection (YOLOv8-nano on-device) |
| ⬜ | Real-time distraction reactions |
| ⬜ | Headphone auto-override |
