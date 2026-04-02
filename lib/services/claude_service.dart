import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/character.dart';
import '../models/session_state.dart';

class ClaudeService {
  final Dio _dio;
  final String apiKey;

  static const _model = 'claude-sonnet-4-5';
  static const _maxTokens = 80;
  static const _baseUrl = 'https://api.anthropic.com/v1/messages';

  ClaudeService({required this.apiKey})
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
      );

  // ── Break message ─────────────────────────────────────

  Future<String?> generateBreakMessage({
    required Character speaker,
    required List<Character> allCharacters,
    required SessionState session,
    required List<Map<String, String>> conversationHistory,
  }) async {
    final others = allCharacters.where((c) => c.id != speaker.id).toList();
    final otherCharacters = others.map((c) => '${c.name} (${c.species})').join(', ');

    final presentIds = others.map((c) => c.id).toSet();
    final relationshipLines = speaker.relationships.entries
        .where((e) => presentIds.contains(e.key))
        .map((e) {
          final relChar = others.firstWhere((c) => c.id == e.key);
          return '  - ${relChar.name}: ${e.value}';
        })
        .join('\n');

    final systemPrompt =
        '''
You are ${speaker.name}, a ${speaker.species} study companion.

Personality: ${speaker.personality}
Voice: ${speaker.voiceDescription}

Current situation:
- Session phase: Break time
- Block ${session.currentBlock} of ${session.config.totalBlocks} just completed
- Subject being studied: ${session.config.subject.isEmpty ? 'not specified' : session.config.subject}
- Other study pals present: ${otherCharacters.isEmpty ? 'none' : otherCharacters}
${relationshipLines.isEmpty ? '' : '- Your relationships with those present:\n$relationshipLines\n'}- Total study time so far: ${session.totalElapsed.inMinutes} minutes

Rules:
- Stay completely in character at all times
- Keep your message to ONE sentence only — maximum 20 words
- No action emotes like *adjusts spectacles* — just speak naturally
- Be warm and conversational
- React to the session context
- Let your relationships shape how you address others — address them by name occasionally
- Never mention being an AI
''';

    final messages = [
      ...conversationHistory,
      {'role': 'user', 'content': 'Send a break message to the group.'},
    ];

    try {
      final response = await _dio.post(
        '',
        data: jsonEncode({
          'model': _model,
          'max_tokens': _maxTokens,
          'system': systemPrompt,
          'messages': messages,
        }),
      );

      final content = response.data['content'] as List;
      if (content.isEmpty) return null;
      return content[0]['text'] as String?;
    } on DioException catch (e) {
      debugPrint('Claude API error: ${e.response?.data ?? e.message}');
      return null;
    }
  }

  // ── Distraction reaction ──────────────────────────────

  Future<String?> generateDistractionReaction({
    required Character speaker,
    required SessionState session,
    required DistractionSignal signal,
  }) async {
    final signalDescription = switch (signal) {
      DistractionSignal.phoneDetected =>
        'You can see the user is looking at their phone instead of studying.',
      DistractionSignal.faceAbsent =>
        'The user has been away from their desk for a while.',
      DistractionSignal.prolongedAbsence =>
        'The user has been gone for a long time.',
      DistractionSignal.glanceAway =>
        'The user keeps glancing away from their work.',
      _ => 'The user seems distracted.',
    };

    final systemPrompt =
        '''
You are ${speaker.name}, a ${speaker.species} study companion.

Personality: ${speaker.personality}
Voice: ${speaker.voiceDescription}

Current situation:
- Session phase: Studying (block ${session.currentBlock} of ${session.config.totalBlocks})
- Subject: ${session.config.subject.isEmpty ? 'not specified' : session.config.subject}
- $signalDescription

Rules:
- Stay completely in character
- - React to the distraction in ONE sentence, maximum 12 words
- Be true to your personality — strict characters are firm, chill ones are gentle
- Keep it short and punchy
- Never mention being an AI
''';

    try {
      final response = await _dio.post(
        '',
        data: jsonEncode({
          'model': _model,
          'max_tokens': 80,
          'system': systemPrompt,
          'messages': [
            {'role': 'user', 'content': 'React to this distraction.'},
          ],
        }),
      );

      final content = response.data['content'] as List;
      if (content.isEmpty) return null;
      return content[0]['text'] as String?;
    } on DioException catch (e) {
      debugPrint('Claude API error: ${e.response?.data ?? e.message}');
      return null;
    }
  }
}
