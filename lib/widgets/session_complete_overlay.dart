import 'package:flutter/material.dart';
import '../services/session_engine.dart';
import '../theme/app_theme.dart';

class SessionCompleteOverlay extends StatelessWidget {
  final SessionEngine engine;
  const SessionCompleteOverlay({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Session complete!',
                  style: tt.headlineMedium?.copyWith(color: AppColors.teal)),
              const SizedBox(height: 8),
              Text('Great work today.',
                  style: tt.bodyLarge?.copyWith(color: Colors.grey.shade500)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: engine.abandonSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}