import 'package:flutter/material.dart';
import '../models/session_state.dart';
import '../services/session_engine.dart';
import '../theme/app_theme.dart';

class TopBar extends StatelessWidget {
  final SessionState state;
  final SessionEngine engine;

  const TopBar({super.key, required this.state, required this.engine});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Subject label
          if (state.config.subject.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Text(
                state.config.subject,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            )
          else
            const SizedBox.shrink(),

          // Controls
          Row(
            children: [
              _TopBarBtn(
                icon: state.isInterrupted ? Icons.play_arrow : Icons.pause,
                onTap: state.isInterrupted
                    ? engine.resumeSession
                    : engine.pauseSession,
              ),
              const SizedBox(width: 8),
              _TopBarBtn(
                icon: Icons.stop,
                onTap: engine.endSession,
                destructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;

  const _TopBarBtn({
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.coral : Colors.white70;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
