import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StepperRow extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final String suffix;
  final ValueChanged<int> onChanged;

  const StepperRow({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      StepBtn(
          icon: Icons.remove,
          onTap: value > min ? () => onChanged(value - step) : null),
      const SizedBox(width: 16),
      Text('$value $suffix', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(width: 16),
      StepBtn(
          icon: Icons.add,
          onTap: value < max ? () => onChanged(value + step) : null),
    ]);
  }
}

class StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const StepBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(8),
          color: onTap == null ? Colors.grey.shade100 : Colors.white,
        ),
        child: Icon(icon,
            size: 18,
            color: onTap == null
                ? Colors.grey.shade300
                : Colors.grey.shade700),
      ),
    );
  }
}