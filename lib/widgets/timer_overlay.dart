import 'package:flutter/material.dart';
import '../models/session_state.dart';
import '../theme/app_theme.dart';
import 'phase_chip.dart';

class TimerOverlay extends StatelessWidget {
  final SessionState state;
  const TimerOverlay({super.key, required this.state});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _phaseColor(SessionPhase phase) => switch (phase) {
    SessionPhase.studying => AppColors.accent,
    SessionPhase.breaking => AppColors.teal,
    SessionPhase.transition => AppColors.amber,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = _phaseColor(state.phase);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhaseChip(state.phase),
          const SizedBox(width: 16),
          Text(
            _formatDuration(state.timeRemaining),
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${state.currentBlock}/${state.config.totalBlocks}',
            style: tt.bodyMedium?.copyWith(color: Colors.white38),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state.blockProgress,
                minHeight: 5,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
