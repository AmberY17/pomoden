import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';

// ── Usage tracking ────────────────────────────────────────

class CharacterUsageNotifier extends StateNotifier<Map<String, int>> {
  static const _prefix = 'pomoden_usage_';
  static const _resetKey = 'pomoden_usage_reset';

  SharedPreferences? _prefs;

  CharacterUsageNotifier() : super({});

  void init(SharedPreferences prefs) {
    _prefs = prefs;
    _checkMonthlyReset(prefs);
    state = {
      for (final c in CharacterPresets.all)
        c.id: prefs.getInt('$_prefix${c.id}') ?? 0,
    };
  }

  void _checkMonthlyReset(SharedPreferences prefs) {
    final stored = prefs.getString(_resetKey);
    final now = DateTime.now();
    if (stored == null) {
      prefs.setString(_resetKey, _nextReset(now).toIso8601String());
      return;
    }
    if (now.isAfter(DateTime.parse(stored))) {
      for (final c in CharacterPresets.all) {
        prefs.remove('$_prefix${c.id}');
      }
      prefs.setString(_resetKey, _nextReset(now).toIso8601String());
    }
  }

  DateTime _nextReset(DateTime from) => DateTime(from.year, from.month + 1, 1);

  bool isExhausted(Character character) =>
      (state[character.id] ?? 0) >= character.monthlySessionLimit;

  int remaining(Character character) =>
      (character.monthlySessionLimit - (state[character.id] ?? 0))
          .clamp(0, character.monthlySessionLimit);

  Future<void> increment(String characterId) async {
    if (_prefs == null) return;
    final newCount = (state[characterId] ?? 0) + 1;
    await _prefs!.setInt('$_prefix$characterId', newCount);
    state = {...state, characterId: newCount};
  }

  Future<void> resetAll() async {
    if (_prefs == null) return;
    for (final c in CharacterPresets.all) {
      await _prefs!.remove('$_prefix${c.id}');
    }
    state = {for (final c in CharacterPresets.all) c.id: 0};
  }
}

final _sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((_) => SharedPreferences.getInstance());

final characterUsageProvider =
    StateNotifierProvider<CharacterUsageNotifier, Map<String, int>>((ref) {
  final notifier = CharacterUsageNotifier();
  ref.read(_sharedPreferencesProvider).whenData(notifier.init);
  ref.listen(_sharedPreferencesProvider, (_, next) {
    next.whenData(notifier.init);
  });
  return notifier;
});

// ── Character selection ───────────────────────────────────

class CharacterSelectionNotifier extends StateNotifier<List<String>> {
  CharacterSelectionNotifier() : super([]);

  static const _max = 4;

  void toggle(String id) {
    if (state.contains(id)) {
      state = state.where((x) => x != id).toList();
    } else if (state.length < _max) {
      state = [...state, id];
    }
  }

  void clearAll() => state = [];
}

final characterSelectionProvider =
    StateNotifierProvider<CharacterSelectionNotifier, List<String>>(
        (_) => CharacterSelectionNotifier());
