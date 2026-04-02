import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SettingsService {
  static const _claudeKeyFileName = 'claude_api_key.txt';

  Future<File> get _keyFile async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/$_claudeKeyFileName');
  }

  Future<void> saveClaudeApiKey(String key) async {
    final file = await _keyFile;
    await file.writeAsString(key);
  }

  Future<String?> getClaudeApiKey() async {
    final file = await _keyFile;
    if (!file.existsSync()) return null;
    final key = await file.readAsString();
    return key.isEmpty ? null : key;
  }

  Future<void> deleteClaudeApiKey() async {
    final file = await _keyFile;
    if (file.existsSync()) await file.delete();
  }

  Future<bool> hasClaudeApiKey() async {
    final key = await getClaudeApiKey();
    return key != null && key.isNotEmpty;
  }
}
