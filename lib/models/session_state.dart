enum SessionPhase {
  idle,
  studying,
  transition,
  breaking,
  sessionEnd,
  interrupted,
}

enum DistractionSignal {
  none,
  glanceAway,
  faceAbsent,
  phoneDetected,
  prolongedAbsence,
}

class SessionConfig {
  final int totalBlocks;
  final Duration studyDuration;
  final Duration breakDuration;
  final Duration transitionDuration;
  final int longBreakAfterBlocks;
  final Duration longBreakDuration;
  final String subject;

  const SessionConfig({
    this.totalBlocks = 4,
    this.studyDuration = const Duration(seconds: 10),
    this.breakDuration = const Duration(seconds: 10),
    this.transitionDuration = const Duration(seconds: 10),
    this.longBreakAfterBlocks = 4,
    this.longBreakDuration = const Duration(seconds: 10),
    this.subject = '',
  });

  SessionConfig copyWith({
    int? totalBlocks,
    Duration? studyDuration,
    Duration? breakDuration,
    Duration? transitionDuration,
    int? longBreakAfterBlocks,
    Duration? longBreakDuration,
    String? subject,
  }) {
    return SessionConfig(
      totalBlocks: totalBlocks ?? this.totalBlocks,
      studyDuration: studyDuration ?? this.studyDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      longBreakAfterBlocks: longBreakAfterBlocks ?? this.longBreakAfterBlocks,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      subject: subject ?? this.subject,
    );
  }

  Duration get totalDuration {
    final studyTotal = studyDuration * totalBlocks;
    final breakTotal = breakDuration * (totalBlocks - 1);
    final transitionTotal = transitionDuration * (totalBlocks - 1) * 2;
    return studyTotal + breakTotal + transitionTotal;
  }
}

class SessionState {
  final SessionPhase phase;
  final SessionConfig config;
  final int currentBlock;
  final Duration timeRemaining;
  final Duration totalElapsed;
  final DistractionSignal activeSignal;
  final DateTime? interruptedAt;
  final bool isCameraEnabled;

  const SessionState({
    this.phase = SessionPhase.idle,
    this.config = const SessionConfig(),
    this.currentBlock = 1,
    this.timeRemaining = Duration.zero,
    this.totalElapsed = Duration.zero,
    this.activeSignal = DistractionSignal.none,
    this.interruptedAt,
    this.isCameraEnabled = false,
  });

  bool get isActive =>
      phase == SessionPhase.studying ||
      phase == SessionPhase.transition ||
      phase == SessionPhase.breaking;

  bool get isOnBreak => phase == SessionPhase.breaking;
  bool get isStudying => phase == SessionPhase.studying;
  bool get isIdle => phase == SessionPhase.idle;
  bool get isComplete => phase == SessionPhase.sessionEnd;
  bool get isInterrupted => phase == SessionPhase.interrupted;

  bool get isLastBlock => currentBlock == config.totalBlocks;

  double get blockProgress {
    if (phase != SessionPhase.studying) return 0;
    final total = config.studyDuration.inSeconds;
    final elapsed = total - timeRemaining.inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  double get overallProgress {
    final total = config.totalDuration.inSeconds;
    if (total == 0) return 0;
    return (totalElapsed.inSeconds / total).clamp(0.0, 1.0);
  }

  SessionState copyWith({
    SessionPhase? phase,
    SessionConfig? config,
    int? currentBlock,
    Duration? timeRemaining,
    Duration? totalElapsed,
    DistractionSignal? activeSignal,
    DateTime? interruptedAt,
    bool? isCameraEnabled,
  }) {
    return SessionState(
      phase: phase ?? this.phase,
      config: config ?? this.config,
      currentBlock: currentBlock ?? this.currentBlock,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      totalElapsed: totalElapsed ?? this.totalElapsed,
      activeSignal: activeSignal ?? this.activeSignal,
      interruptedAt: interruptedAt ?? this.interruptedAt,
      isCameraEnabled: isCameraEnabled ?? this.isCameraEnabled,
    );
  }

  @override
  String toString() {
    return 'SessionState(phase: $phase, block: $currentBlock/${config.totalBlocks}, '
        'remaining: ${timeRemaining.inSeconds}s, signal: $activeSignal)';
  }
}