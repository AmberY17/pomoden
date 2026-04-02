import 'package:flutter/material.dart';
import '../models/session_state.dart';
import '../theme/app_theme.dart';

class PhaseChip extends StatelessWidget {
  final SessionPhase phase;
  const PhaseChip(this.phase, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (phase) {
      SessionPhase.studying    => ('Studying', AppColors.accentLight, AppColors.accent),
      SessionPhase.breaking    => ('Break', AppColors.tealLight, AppColors.teal),
      SessionPhase.transition  => ('Transition', AppColors.amberLight, AppColors.amber),
      SessionPhase.sessionEnd  => ('Complete', AppColors.tealLight, AppColors.teal),
      SessionPhase.interrupted => ('Paused', const Color(0xFFF1EFE8), const Color(0xFF888780)),
      _                        => ('Idle', const Color(0xFFF1EFE8), const Color(0xFF888780)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}