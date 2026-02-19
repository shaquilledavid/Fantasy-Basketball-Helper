import "package:flutter/material.dart";

class NbaCard extends StatelessWidget {
  const NbaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.border,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);

    final content = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: radius,
        border: border,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
