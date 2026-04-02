import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_state.dart';
import '../theme/app_theme.dart';
import '../widgets/stepper_row.dart';
import '../shared/session_label.dart';
import 'character_select_screen.dart';
import 'settings_screen.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int blocks = 4;
  int studySeconds = 10;
  int breakSeconds = 10;
  final subjectController = TextEditingController();

  @override
  void dispose() {
    subjectController.dispose();
    super.dispose();
  }

  void _goNext(BuildContext context) {
    final config = SessionConfig(
      totalBlocks: blocks,
      studyDuration: Duration(seconds: studySeconds),
      breakDuration: Duration(seconds: breakSeconds),
      subject: subjectController.text.trim(),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CharacterSelectScreen(config: config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final totalSecs = (studySeconds * blocks) + (breakSeconds * (blocks - 1));

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 40),
          child: Center(
            child: SizedBox(
              width: 480,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pomoden',
                      style: tt.displayLarge?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Set up your session',
                      style: tt.bodyLarge
                          ?.copyWith(color: Colors.grey.shade500)),
                  const SizedBox(height: 40),

                  const SessionLabel('What are you studying?'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Linear algebra, History essay...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  const SessionLabel('Pomodoro blocks'),
                  const SizedBox(height: 8),
                  StepperRow(
                    value: blocks,
                    min: 1,
                    max: 8,
                    onChanged: (v) => setState(() => blocks = v),
                    suffix: 'blocks',
                  ),
                  const SizedBox(height: 20),

                  const SessionLabel('Study block duration'),
                  const SizedBox(height: 8),
                  StepperRow(
                    value: studySeconds,
                    min: 10,
                    max: 90,
                    step: 10,
                    onChanged: (v) => setState(() => studySeconds = v),
                    suffix: 'sec',
                  ),
                  const SizedBox(height: 20),

                  const SessionLabel('Break duration'),
                  const SizedBox(height: 8),
                  StepperRow(
                    value: breakSeconds,
                    min: 10,
                    max: 90,
                    step: 10,
                    onChanged: (v) => setState(() => breakSeconds = v),
                    suffix: 'sec',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total session: ~${totalSecs}s',
                    style: tt.bodyMedium
                        ?.copyWith(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _goNext(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Next →',
                        style: tt.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: Colors.grey.shade400,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ),
      ],
    );
  }
}
