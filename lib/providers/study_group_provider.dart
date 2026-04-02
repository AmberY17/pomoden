import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_group.dart';

class StudyGroupNotifier extends StateNotifier<List<StudyGroup>> {
  static const _key = 'pomoden_groups';
  SharedPreferences? _prefs;

  StudyGroupNotifier() : super([]);

  void init(SharedPreferences prefs) {
    _prefs = prefs;
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List;
      state = list
          .map((e) => StudyGroup.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      state = [];
    }
  }

  Future<void> create(String name, List<String> characterIds) async {
    if (characterIds.isEmpty) return;
    final group = StudyGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      characterIds: List.from(characterIds),
    );
    state = [...state, group];
    await _persist();
  }

  Future<void> delete(String id) async {
    state = state.where((g) => g.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    await _prefs?.setString(
      _key,
      jsonEncode(state.map((g) => g.toJson()).toList()),
    );
  }
}

final studyGroupProvider =
    StateNotifierProvider<StudyGroupNotifier, List<StudyGroup>>((ref) {
  final notifier = StudyGroupNotifier();
  SharedPreferences.getInstance().then(notifier.init);
  return notifier;
});
