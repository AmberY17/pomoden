import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/session_state.dart';
import '../theme/app_theme.dart';
import 'message_bubble.dart';

class CharacterCard extends StatefulWidget {
  final Character character;
  final SessionState state;

  const CharacterCard({
    super.key,
    required this.character,
    required this.state,
  });

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _bobAnimation = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _moodColor(CharacterMood mood) => switch (mood) {
    CharacterMood.focused => AppColors.accent,
    CharacterMood.chatting => AppColors.teal,
    CharacterMood.reacting => AppColors.coral,
    CharacterMood.stretching => AppColors.amber,
    CharacterMood.celebrating => AppColors.teal,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final isOnBreak = widget.state.isOnBreak;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Card background + image fills entire cell
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  if (isOnBreak)
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.20),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Card background
                    Container(color: const Color(0xFFFAF8F3)),

                    // Character image
                    AnimatedBuilder(
                      animation: _bobAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _bobAnimation.value),
                        child: child,
                      ),
                      child: Image.asset(
                        widget.character.assetPath,
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                        errorBuilder: (_, __, ___) =>
                            _CharacterPlaceholder(name: widget.character.name),
                      ),
                    ),

                    // Bottom vignette
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Name tag — top left
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: _moodColor(widget.character.mood),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              widget.character.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Message bubble — bottom of card
                    if (widget.character.currentMessage != null)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: MessageBubble(
                          message: widget.character.currentMessage!,
                        ),
                      ),

                    // Typing indicator — bottom of card
                    if (widget.character.isTyping)
                      const Positioned(
                        bottom: 12,
                        left: 12,
                        child: TypingIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CharacterPlaceholder extends StatelessWidget {
  final String name;
  const _CharacterPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          name[0],
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
