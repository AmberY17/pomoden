import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../models/session_state.dart';
import '../providers/character_provider.dart';
import '../providers/character_usage_provider.dart';
import '../providers/session_provider.dart';
import '../providers/study_group_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/group_chips.dart';

class CharacterSelectScreen extends ConsumerWidget {
  final SessionConfig config;
  const CharacterSelectScreen({super.key, required this.config});

  void _startSession(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.read(characterSelectionProvider);
    ref.read(characterProvider.notifier).initForSession(selectedIds);
    final usageNotifier = ref.read(characterUsageProvider.notifier);
    for (final id in selectedIds) {
      usageNotifier.increment(id);
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    ref.read(sessionEngineProvider).startSession(config);
  }

  void _saveGroup(BuildContext context, WidgetRef ref, List<String> selectedIds) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text(
          'Name your group',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. Dream Team',
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
          onSubmitted: (_) {
            _confirmSave(ctx, ref, controller.text, selectedIds);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => _confirmSave(ctx, ref, controller.text, selectedIds),
            child: const Text('Save', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  void _confirmSave(
    BuildContext ctx,
    WidgetRef ref,
    String name,
    List<String> selectedIds,
  ) {
    if (name.trim().isEmpty) return;
    ref.read(studyGroupProvider.notifier).create(name, selectedIds);
    Navigator.pop(ctx);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(characterSelectionProvider);
    final groups = ref.watch(studyGroupProvider);
    final hasExactGroup = groups.any((g) => g.matches(selected));

    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────
          _Header(selectedCount: selected.length),

          // ── Scrollable content ──────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GroupChips(),
                  _CharacterGrid(
                    selected: selected,
                    onToggle: (id) =>
                        ref.read(characterSelectionProvider.notifier).toggle(id),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom bar ──────────────────────────────────────
      bottomNavigationBar: _BottomBar(
        selectedCount: selected.length,
        showSave: selected.isNotEmpty && !hasExactGroup,
        onSave: () => _saveGroup(context, ref, selected),
        onStart: () => _startSession(context, ref),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int selectedCount;
  const _Header({required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 44px top clears the macOS traffic lights (TitleBarStyle.hidden)
      padding: const EdgeInsets.only(top: 44),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                'Choose your pals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$selectedCount/4',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: selectedCount == 4 ? AppColors.accent : Colors.white38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Character grid ────────────────────────────────────────

class _CharacterGrid extends ConsumerWidget {
  final List<String> selected;
  final void Function(String id) onToggle;

  const _CharacterGrid({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(characterUsageProvider);
    final usageNotifier = ref.read(characterUsageProvider.notifier);
    final characters = CharacterPresets.all;

    if (usage.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.82,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: characters.length,
      itemBuilder: (context, i) {
        final character = characters[i];
        final isExhausted = usageNotifier.isExhausted(character);
        final isSelected = selected.contains(character.id);
        final atMax = selected.length >= 4 && !isSelected;
        final tappable = !isExhausted && !atMax;

        return CharacterSelectCard(
          character: character,
          isSelected: isSelected,
          isExhausted: isExhausted,
          sessionsRemaining: usageNotifier.remaining(character),
          tappable: tappable,
          onTap: tappable ? () => onToggle(character.id) : null,
        );
      },
    );
  }
}

// ── Character card ────────────────────────────────────────

class CharacterSelectCard extends StatelessWidget {
  final Character character;
  final bool isSelected;
  final bool isExhausted;
  final int sessionsRemaining;
  final bool tappable;
  final VoidCallback? onTap;

  const CharacterSelectCard({
    super.key,
    required this.character,
    required this.isSelected,
    required this.isExhausted,
    required this.sessionsRemaining,
    required this.tappable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: (isExhausted || (!tappable && !isSelected)) ? 0.4 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Character image or placeholder
                Image.asset(
                  character.assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _CardPlaceholder(name: character.name),
                ),

                // Bottom gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Name + count
                Positioned(
                  bottom: 8,
                  left: 10,
                  right: 10,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          character.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black54),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        isExhausted ? 'Resting' : '$sessionsRemaining',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isExhausted
                              ? Colors.white38
                              : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardPlaceholder extends StatelessWidget {
  final String name;
  const _CardPlaceholder({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardDark,
      child: Center(
        child: Text(
          name[0],
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: AppColors.borderDark,
          ),
        ),
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int selectedCount;
  final bool showSave;
  final VoidCallback onSave;
  final VoidCallback onStart;

  const _BottomBar({
    required this.selectedCount,
    required this.showSave,
    required this.onSave,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          top: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: Row(
        children: [
          if (showSave)
            TextButton(
              onPressed: onSave,
              child: const Text(
                'Save as group',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const Spacer(),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                selectedCount == 0 ? 'Start solo' : 'Start session',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
