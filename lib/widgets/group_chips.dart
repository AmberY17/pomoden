import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_group.dart';
import '../providers/character_usage_provider.dart';
import '../providers/study_group_provider.dart';
import '../screens/groups_screen.dart';
import '../theme/app_theme.dart';

class GroupChips extends ConsumerWidget {
  const GroupChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(studyGroupProvider);
    final selected = ref.watch(characterSelectionProvider);

    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Saved groups',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white54,
                letterSpacing: 0.3,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroupsScreen()),
              ),
              child: const Text(
                'Manage',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final group = groups[i];
              final isActive = group.matches(selected);
              return _GroupChip(
                group: group,
                isActive: isActive,
                onTap: () => _applyGroup(ref, group.characterIds),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _applyGroup(WidgetRef ref, List<String> characterIds) {
    final notifier = ref.read(characterSelectionProvider.notifier);
    notifier.clearAll();
    for (final id in characterIds) {
      notifier.toggle(id);
    }
  }
}

class _GroupChip extends StatelessWidget {
  final StudyGroup group;
  final bool isActive;
  final VoidCallback onTap;

  const _GroupChip({
    required this.group,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.borderDark,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          group.name,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.accent : Colors.white70,
          ),
        ),
      ),
    );
  }
}
