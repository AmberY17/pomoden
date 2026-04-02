import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/character_provider.dart';
import '../providers/session_provider.dart';
import 'setup_screen.dart';
import 'session_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(sessionStateProvider, (_, next) {
      next.whenData((session) {
        ref.read(characterProvider.notifier).updateMoodsForSession(session);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionStateProvider);

    return Scaffold(
      body: sessionAsync.when(
        data: (state) => state.isIdle
            ? const SetupScreen()
            : SessionScreen(state: state),
        loading: () => const SetupScreen(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}