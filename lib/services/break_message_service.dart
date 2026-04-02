import 'dart:math';
import '../models/character.dart';
import '../models/session_state.dart';
import '../services/claude_service.dart';

class BreakMessageService {
  final ClaudeService _claude;
  final _random = Random();

  // Conversation history within the current session
  final List<Map<String, String>> _history = [];

  BreakMessageService({required ClaudeService claude}) : _claude = claude;

  void clearHistory() => _history.clear();

  Future<({Character character, String message})?> generateBreakMessage({
    required List<Character> characters,
    required SessionState session,
  }) async {
    if (characters.isEmpty) return null;

    // Pick a random character to speak
    final speaker = characters[_random.nextInt(characters.length)];

    final message = await _claude.generateBreakMessage(
      speaker: speaker,
      allCharacters: characters,
      session: session,
      conversationHistory: List.from(_history),
    );

    if (message == null) return null;

    // Add to history for conversational continuity
    _history.add({'role': 'assistant', 'content': '${speaker.name}: $message'});

    // Keep history manageable — last 6 messages only
    if (_history.length > 6) {
      _history.removeRange(0, _history.length - 6);
    }

    return (character: speaker, message: message);
  }

  Future<({Character character, String message})?> generateDistractionReaction({
    required List<Character> characters,
    required SessionState session,
  }) async {
    if (characters.isEmpty) return null;

    // Pick character most suited to the reaction
    // Dash reacts first if present (most intense), otherwise random
    final dash = characters.where((c) => c.id == 'dash').firstOrNull;
    final speaker = dash ?? characters[_random.nextInt(characters.length)];

    final message = await _claude.generateDistractionReaction(
      speaker: speaker,
      session: session,
      signal: session.activeSignal,
    );

    if (message == null) return null;
    return (character: speaker, message: message);
  }
}
