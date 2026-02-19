import "package:flutter/material.dart";

class GameCountChip extends StatelessWidget {
  const GameCountChip({
    super.key,
    required this.count,
    this.label,
  });

  final int count;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bg;
    Color fg;

    if (count >= 5) {
      bg = const Color(0xFF22C55E).withValues(alpha: 0.14);
      fg = const Color(0xFF16A34A);
    } else if (count == 4) {
      bg = const Color(0xFF3B82F6).withValues(alpha: 0.14);
      fg = const Color(0xFF2563EB);
    } else if (count == 3) {
      bg = const Color(0xFFF59E0B).withValues(alpha: 0.14);
      fg = const Color(0xFFD97706);
    } else {
      bg = theme.colorScheme.surfaceContainerHighest;
      fg = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label ?? "$count games",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
