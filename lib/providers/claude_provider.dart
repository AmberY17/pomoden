import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/claude_service.dart';
import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// Loads the API key and creates ClaudeService — null if no key saved
final claudeServiceProvider = FutureProvider<ClaudeService?>((ref) async {
  final settings = ref.watch(settingsServiceProvider);
  final key = await settings.getClaudeApiKey();
  if (key == null || key.isEmpty) return null;
  return ClaudeService(apiKey: key);
});
