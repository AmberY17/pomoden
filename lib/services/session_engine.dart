import 'dart:async';
import '../models/session_state.dart';

class SessionEngine {
  final _stateController = StreamController<SessionState>.broadcast();
  Stream<SessionState> get stateStream => _stateController.stream;

  SessionState _state = const SessionState();
  SessionState get currentState => _state;

  Timer? _ticker;
  Timer? _distractionCooldown;
  bool _reactionOnCooldown = false;

  SessionEngine() {
    _emit();
  }

  // ── Public API ──────────────────────────────────────────

  void startSession(SessionConfig config) {
    _cancelTicker();
    _state = SessionState(
      phase: SessionPhase.studying,
      config: config,
      currentBlock: 1,
      timeRemaining: config.studyDuration,
    );
    _emit();
    _startTicker();
  }

  void pauseSession() {
    if (!_state.isActive) return;
    _cancelTicker();
    _state = _state.copyWith(
      phase: SessionPhase.interrupted,
      interruptedAt: DateTime.now(),
    );
    _emit();
  }

  void resumeSession() {
    if (!_state.isInterrupted) return;
    _state = _state.copyWith(
      phase: _previousPhase(),
      interruptedAt: null,
    );
    _emit();
    _startTicker();
  }

  void endSession() {
    _cancelTicker();
    _state = _state.copyWith(phase: SessionPhase.sessionEnd);
    _emit();
  }

  void abandonSession() {
    _cancelTicker();
    _state = const SessionState();
    _emit();
  }

  void reportDistraction(DistractionSignal signal) {
    if (_reactionOnCooldown) return;
    if (!_state.isStudying) return;
    if (signal == DistractionSignal.none) return;

    _state = _state.copyWith(activeSignal: signal);
    _emit();

    // Start cooldown — 90 seconds between voiced reactions
    _reactionOnCooldown = true;
    _distractionCooldown?.cancel();
    _distractionCooldown = Timer(const Duration(seconds: 90), () {
      _reactionOnCooldown = false;
      _clearSignal();
    });
  }

  void clearDistraction() => _clearSignal();

  void dispose() {
    _cancelTicker();
    _distractionCooldown?.cancel();
    _stateController.close();
  }

  // ── Private ─────────────────────────────────────────────

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _cancelTicker() => _ticker?.cancel();

  void _tick() {
    if (!_state.isActive) return;

    final newRemaining = _state.timeRemaining - const Duration(seconds: 1);
    final newElapsed = _state.totalElapsed + const Duration(seconds: 1);

    if (newRemaining <= Duration.zero) {
      _handlePhaseEnd();
    } else {
      _state = _state.copyWith(
        timeRemaining: newRemaining,
        totalElapsed: newElapsed,
      );
      _emit();
    }
  }

  void _handlePhaseEnd() {
    switch (_state.phase) {
      case SessionPhase.studying:
        if (_state.isLastBlock) {
          // All blocks done — session complete
          _cancelTicker();
          _state = _state.copyWith(phase: SessionPhase.sessionEnd);
        } else {
          // Move to break
          final isLongBreak = _state.currentBlock %
              _state.config.longBreakAfterBlocks == 0;
          final breakDur = isLongBreak
              ? _state.config.longBreakDuration
              : _state.config.breakDuration;
          _state = _state.copyWith(
            phase: SessionPhase.breaking,
            timeRemaining: breakDur,
          );
        }
        break;

      case SessionPhase.breaking:
        // Transition before next study block
        _state = _state.copyWith(
          phase: SessionPhase.transition,
          timeRemaining: _state.config.transitionDuration,
        );
        break;

      case SessionPhase.transition:
        // Back to studying — next block
        _state = _state.copyWith(
          phase: SessionPhase.studying,
          currentBlock: _state.currentBlock + 1,
          timeRemaining: _state.config.studyDuration,
        );
        break;

      default:
        break;
    }
    _emit();
  }

  SessionPhase _previousPhase() {
    // Best guess at what phase was active before interrupt
    // In a real app you'd store this — good enough for now
    return SessionPhase.studying;
  }

  void _clearSignal() {
    _state = _state.copyWith(activeSignal: DistractionSignal.none);
    _emit();
  }

  void _emit() => _stateController.add(_state);
}