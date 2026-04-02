import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xF0181410),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: Color(0xFFF5F0E8),
          height: 1.45,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xF0181410),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        '• • •',
        style: TextStyle(
          fontSize: 11,
          color: Color(0x4DF5F0E8),
          letterSpacing: 3,
        ),
      ),
    );
  }
}
