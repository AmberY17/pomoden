import 'package:flutter/material.dart';

class SessionLabel extends StatelessWidget {
  final String text;
  const SessionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w500),
      );
}