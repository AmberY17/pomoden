import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_state.dart';
import '../services/session_engine.dart';

// The engine itself — single instance for the app lifetime
final sessionEngineProvider = Provider<SessionEngine>((ref) {
  final engine = SessionEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

// Live session state — rebuilds any widget that watches it
final sessionStateProvider = StreamProvider<SessionState>((ref) {
  final engine = ref.watch(sessionEngineProvider);
  return engine.stateStream;
});