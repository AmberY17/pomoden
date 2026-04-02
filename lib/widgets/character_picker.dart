import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../providers/character_usage_provider.dart';
import '../shared/session_label.dart';
import '../theme/app_theme.dart';

class CharacterPicker extends ConsumerWidget {
  const CharacterPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(characterUsageProvider);
    final usageNotifier = ref.read(characterUsageProvider.notifier);
    final selected = ref.watch(characterSelectionProvider);
    final selectionNotifier = ref.read(characterSelectionProvider.notifier);
    final characters = CharacterPresets.all;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SessionLabel('Study pals'),
            Text(
              '${selected.length}/4',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected.length == 4
                    ? AppColors.accent
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (usage.isEmpty)
          const SizedBox(
            height: 80,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: characters.length,
            itemBuilder: (context, i) {
              final character = characters[i];
              final exhausted = usageNotifier.isExhausted(character);
              final isSelected = selected.contains(character.id);
              final atMax = selected.length >= 4 && !isSelected;

              return CharacterPickerCard(
                character: character,
                isSelected: isSelected,
                isExhausted: exhausted,
                sessionsRemaining: usageNotifier.remaining(character),
                canSelect: !exhausted && !atMax,
                onTap: exhausted || atMax
                    ? null
                    : () => selectionNotifier.toggle(character.id),
              );
            },
          ),
      ],
    );
  }
}

class CharacterPickerCard extends StatelessWidget {
  final Character character;
  final bool isSelected;
  final bool isExhausted;
  final int sessionsRemaining;
  final bool canSelect;
  final VoidCallback? onTap;

  const CharacterPickerCard({
    super.key,
    required this.character,
    required this.isSelected,
    required this.isExhausted,
    required this.sessionsRemaining,
    required this.canSelect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.accentLight : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: (isExhausted || (!canSelect && !isSelected)) ? 0.45 : 1.0,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(11)),
                  child: Image.asset(
                    character.assetPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        CharacterPickerPlaceholder(name: character.name),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        character.name,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2C2C),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _StatusPill(
                      isExhausted: isExhausted,
                      sessionsRemaining: sessionsRemaining,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CharacterPickerPlaceholder extends StatelessWidget {
  final String name;
  const CharacterPickerPlaceholder({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentLight,
      child: Center(
        child: Text(
          name[0],
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isExhausted;
  final int sessionsRemaining;
  const _StatusPill({required this.isExhausted, required this.sessionsRemaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isExhausted ? Colors.grey.shade300 : AppColors.accentLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isExhausted ? 'Resting' : '$sessionsRemaining',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: isExhausted ? Colors.grey.shade600 : AppColors.accent,
        ),
      ),
    );
  }
}
