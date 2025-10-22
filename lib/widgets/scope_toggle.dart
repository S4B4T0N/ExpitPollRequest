// lib/widgets/scope_toggle.dart
import 'package:flutter/material.dart';

enum ScopeSide { left, right }

class ScopeToggle extends StatelessWidget {
  const ScopeToggle({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.value,
    required this.onChanged,
  });

  final String leftLabel; // "World"
  final String rightLabel; // "Local"
  final ScopeSide value;
  final ValueChanged<ScopeSide> onChanged;

  @override
  Widget build(BuildContext context) {
    final isLeft = value == ScopeSide.left;
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surface.withValues(alpha: 0.5);
    final fg = theme.colorScheme.primary;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          _item(
            label: leftLabel,
            selected: isLeft,
            onTap: () => onChanged(ScopeSide.left),
          ),
          _item(
            label: rightLabel,
            selected: !isLeft,
            onTap: () => onChanged(ScopeSide.right),
          ),
        ],
      ),
    );
  }

  Expanded _item({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected
                  ? Colors.black.withValues(alpha: 0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: selected ? null : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
