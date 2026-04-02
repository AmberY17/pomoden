import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_state.dart';
import '../providers/character_provider.dart';
import '../providers/session_provider.dart';
import '../widgets/character_room.dart';
import '../widgets/timer_overlay.dart';
import '../widgets/top_bar.dart';
import '../widgets/session_complete_overlay.dart';

class SessionScreen extends ConsumerWidget {
  final SessionState state;
  const SessionScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(characterProvider);
    final engine = ref.read(sessionEngineProvider);

    return Stack(
      children: [
        CharacterRoom(characters: characters, state: state),
        Positioned(
          top: 0, left: 0, right: 0,
          child: TopBar(state: state, engine: engine),
        ),
        Positioned(
          bottom: 32, left: 0, right: 0,
          child: Center(child: TimerOverlay(state: state)),
        ),
        if (state.isComplete)
          SessionCompleteOverlay(engine: engine),
      ],
    );
  }
}