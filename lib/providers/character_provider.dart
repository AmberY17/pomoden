import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../models/session_state.dart';
import '../providers/claude_provider.dart';
import '../services/break_message_service.dart';

class CharacterNotifier extends StateNotifier<List<Character>> {
  CharacterNotifier() : super([]);

  BreakMessageService? _breakService;
  SessionPhase? _lastPhase;
  Timer? _messageTimer;
  Future<({Character character, String message})?>? _prefetchFuture;
  bool _prefetchTriggered = false;
  int _breakGeneration = 0;

  void setBreakService(BreakMessageService? service) {
    _breakService = service;
  }

  void initForSession(List<String> characterIds) {
    state = CharacterPresets.all
        .where((c) => characterIds.contains(c.id))
        .toList();
    _lastPhase = null;
    _prefetchTriggered = false;
    _prefetchFuture = null;
    _breakGeneration++;
  }

  Future<void> updateMoodsForSession(SessionState session) async {
    // Update moods
    state = state.map((character) {
      final newMood = character.moodForPhase(
        session.phase,
        session.activeSignal,
      );
      return character.copyWith(mood: newMood);
    }).toList();

    // Pre-fetch break message in last 15s of study (skip on last block)
    if (session.isStudying &&
        !session.isLastBlock &&
        !_prefetchTriggered &&
        session.timeRemaining.inSeconds <= 15 &&
        _breakService != null) {
      _prefetchTriggered = true;
      _prefetchFuture = _breakService!.generateBreakMessage(
        characters: state,
        session: session,
      );
    }

    // Detect phase transitions
    final phaseChanged = _lastPhase != session.phase;
    _lastPhase = session.phase;

    // Trigger break message when entering break phase
    if (phaseChanged && session.phase == SessionPhase.breaking) {
      _scheduleBreakMessage(session);
    }

    // Trigger distraction reaction
    if (session.activeSignal != DistractionSignal.none && session.isStudying) {
      _triggerDistractionReaction(session);
    }

    // Clear messages when leaving break (transition or study)
    if (phaseChanged &&
        (session.phase == SessionPhase.studying ||
            session.phase == SessionPhase.transition)) {
      clearAllMessages();
      _prefetchTriggered = false;
      _prefetchFuture = null;
      _breakGeneration++;
    }
  }

  void _scheduleBreakMessage(SessionState session) {
    _messageTimer?.cancel();
    if (_breakService == null) return;

    final characters = List<Character>.from(state);
    if (characters.isEmpty) return;

    final generation = ++_breakGeneration;

    // Show typing indicator immediately
    final speakerIndex = DateTime.now().millisecond % characters.length;
    _setTyping(characters[speakerIndex].id, true);

    // Use prefetched future if available, otherwise fetch now
    final future = _prefetchFuture ??
        _breakService!.generateBreakMessage(characters: state, session: session);
    _prefetchFuture = null;

    future.then((result) {
      if (_breakGeneration != generation) return; // phase changed — discard
      if (result != null) {
        _setTyping(result.character.id, false);
        setCharacterMessage(result.character.id, result.message);
        _messageTimer = Timer(const Duration(seconds: 12), clearAllMessages);
      } else {
        _clearAllTyping();
      }
    });
  }

  Future<void> _triggerDistractionReaction(SessionState session) async {
    if (_breakService == null) return;

    final result = await _breakService!.generateDistractionReaction(
      characters: state,
      session: session,
    );

    if (result != null) {
      setCharacterMessage(result.character.id, result.message);
      Timer(const Duration(seconds: 8), () {
        clearMessage(result.character.id);
      });
    }
  }

  void _setTyping(String characterId, bool isTyping) {
    state = state.map((c) {
      if (c.id == characterId) return c.copyWith(isTyping: isTyping);
      return c;
    }).toList();
  }

  void _clearAllTyping() {
    state = state.map((c) => c.copyWith(isTyping: false)).toList();
  }

  void setCharacterTyping(String characterId, bool isTyping) {
    _setTyping(characterId, isTyping);
  }

  void setCharacterMessage(String characterId, String? message) {
    state = state.map((c) {
      if (c.id == characterId) {
        return c.copyWith(currentMessage: message, isTyping: false);
      }
      return c;
    }).toList();
  }

  void clearMessage(String characterId) {
    state = state.map((c) {
      if (c.id == characterId) return c.copyWith(clearCurrentMessage: true);
      return c;
    }).toList();
  }

  void clearAllMessages() {
    state = state
        .map((c) => c.copyWith(clearCurrentMessage: true, isTyping: false))
        .toList();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }
}

final characterProvider =
    StateNotifierProvider<CharacterNotifier, List<Character>>((ref) {
      final notifier = CharacterNotifier();

      // Wire up break service — read initial value in case provider is already resolved
      ref.read(claudeServiceProvider).whenData((claude) {
        if (claude != null) {
          notifier.setBreakService(BreakMessageService(claude: claude));
        }
      });

      // Also listen for changes (key saved/removed while app is running)
      ref.listen(claudeServiceProvider, (_, next) {
        next.whenData((claude) {
          if (claude != null) {
            notifier.setBreakService(BreakMessageService(claude: claude));
          } else {
            notifier.setBreakService(null);
          }
        });
      });

      return notifier;
    });
