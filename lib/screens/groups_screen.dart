import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../models/study_group.dart';
import '../providers/study_group_provider.dart';
import '../theme/app_theme.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(studyGroupProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      body: Column(
        children: [
          _GroupsHeader(),
          Expanded(
            child: groups.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _GroupTile(
                      group: groups[i],
                      onDelete: () => ref
                          .read(studyGroupProvider.notifier)
                          .delete(groups[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _GroupsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 44, bottom: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            const Text(
              'Manage groups',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final StudyGroup group;
  final VoidCallback onDelete;

  const _GroupTile({required this.group, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final characterNames = group.characterIds
        .map((id) {
          final match = CharacterPresets.all
              .where((c) => c.id == id)
              .firstOrNull;
          return match?.name ?? id;
        })
        .join(', ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  characterNames,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text(
          'Delete "${group.name}"?',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_outlined, size: 48, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'No saved groups yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white38,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select characters and tap "Save as group"',
            style: TextStyle(fontSize: 13, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}
