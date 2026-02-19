import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../../../state/app_state.dart";
import "../../../state/models.dart";
import "../../widgets/layout.dart";
import "../../widgets/nba_card.dart";
import "../../widgets/game_count_chip.dart";

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key, required this.state});

  final AppState state;

  String _weekLabel(DateTime date) {
    final weekday = date.weekday;
    final monday = date.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final fmt = DateFormat("MMM d");
    return "${fmt.format(monday)} – ${fmt.format(sunday)}";
  }

  bool _isCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final nowMonday = now.subtract(Duration(days: now.weekday - 1));
    final dateMonday = date.subtract(Duration(days: date.weekday - 1));
    return nowMonday.year == dateMonday.year &&
        nowMonday.month == dateMonday.month &&
        nowMonday.day == dateMonday.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final teams = state.filteredWeeklyTeams;
        final isCurrentWeek = _isCurrentWeek(state.selectedWeekDate);

        return MaxWidth(
          child: Column(
            children: [
              // Week navigation
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Weekly Schedule",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!isCurrentWeek)
                          TextButton(
                            onPressed: () => state.resetToCurrentWeek(),
                            child: const Text("This Week"),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    NbaCard(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => state.navigateWeek(-1),
                          ),
                          Expanded(
                            child: Text(
                              _weekLabel(state.selectedWeekDate),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => state.navigateWeek(1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter chips
                    Row(
                      children: [
                        _FilterChip(
                          label: "All Teams",
                          selected: state.weekFilter == WeekFilter.all,
                          onTap: () => state.setWeekFilter(WeekFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: "4+ Games",
                          selected: state.weekFilter == WeekFilter.fourPlus,
                          onTap: () => state.setWeekFilter(WeekFilter.fourPlus),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: "5+ Games",
                          selected: state.weekFilter == WeekFilter.fivePlus,
                          onTap: () => state.setWeekFilter(WeekFilter.fivePlus),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Results summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${teams.length} teams",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              // Team list
              Expanded(
                child: teams.isEmpty
                    ? Center(
                        child: Text(
                          "No teams match this filter",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        itemCount: teams.length,
                        itemBuilder: (context, index) {
                          final team = teams[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TeamWeekTile(
                              team: team,
                              selectedWeek: state.selectedWeekDate,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TeamWeekTile extends StatelessWidget {
  const _TeamWeekTile({
    required this.team,
    required this.selectedWeek,
  });

  final TeamWeekInfo team;
  final DateTime selectedWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekday = selectedWeek.weekday;
    final monday = selectedWeek.subtract(Duration(days: weekday - 1));
    final dayLabels = ["M", "T", "W", "T", "F", "S", "S"];

    final gameDayIndices = <int>{};
    for (final d in team.gameDates) {
      gameDayIndices.add(d.difference(monday).inDays);
    }

    return NbaCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    team.abbreviation,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.teamName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${team.gamesRemaining} games remaining",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              GameCountChip(count: team.gamesThisWeek),
            ],
          ),
          const SizedBox(height: 12),
          // Day dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final hasGame = gameDayIndices.contains(i);
              return Column(
                children: [
                  Text(
                    dayLabels[i],
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: hasGame
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: hasGame
                        ? Icon(Icons.sports_basketball, size: 14,
                            color: theme.colorScheme.onPrimary)
                        : null,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
