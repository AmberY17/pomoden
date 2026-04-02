import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/session_state.dart';
import 'character_card.dart';

class CharacterRoom extends StatelessWidget {
  final List<Character> characters;
  final SessionState state;

  const CharacterRoom({
    super.key,
    required this.characters,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final bgColor = switch (state.phase) {
      SessionPhase.studying => const Color(0xFF14180E),
      SessionPhase.breaking => const Color(0xFF0D1A09),
      SessionPhase.transition => const Color(0xFF1E1A0C),
      _ => const Color(0xFF14180E),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: size.width,
      height: size.height,
      color: bgColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
          child: characters.isEmpty
              ? const Center(
                  child: Text(
                    'No characters',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : _CharacterGrid(characters: characters, state: state),
        ),
      ),
    );
  }
}

class _CharacterGrid extends StatelessWidget {
  final List<Character> characters;
  final SessionState state;
  const _CharacterGrid({required this.characters, required this.state});

  @override
  Widget build(BuildContext context) {
    final count = characters.length;

    // 1 character — full screen
    if (count == 1) {
      return CharacterCard(character: characters[0], state: state);
    }

    // 2 characters — side by side
    if (count == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CharacterCard(character: characters[0], state: state),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: CharacterCard(character: characters[1], state: state),
            ),
          ),
        ],
      );
    }

    // 3-4 characters — 2x2 grid using Column + Rows
    // This avoids GridView sizing issues entirely
    final rows = <Widget>[];
    for (var i = 0; i < count; i += 2) {
      final rowChildren = <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: CharacterCard(character: characters[i], state: state),
          ),
        ),
      ];

      if (i + 1 < count) {
        rowChildren.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: CharacterCard(character: characters[i + 1], state: state),
            ),
          ),
        );
      } else {
        // Odd character — empty space on right
        rowChildren.add(const Expanded(child: SizedBox.shrink()));
      }

      rows.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: i + 2 < count ? 12 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowChildren,
            ),
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}
