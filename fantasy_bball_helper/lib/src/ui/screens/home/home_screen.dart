import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../../../state/app_state.dart";
import "../../../state/models.dart";
import "../../widgets/layout.dart";
import "../../widgets/nba_card.dart";
import "../../widgets/game_count_chip.dart";
import "../../widgets/section_header.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => state.refresh(),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        final todayGames = state.gamesToday;
        final tomorrowGames = state.gamesTomorrow;
        final b2b = state.backToBackTeams;
        final resting = state.teamsResting;
        final weekBreakdown = state.weeklyBreakdown;
        final topTeams = weekBreakdown.values.toList()
          ..sort((a, b) => b.gamesThisWeek.compareTo(a.gamesThisWeek));
        final mostGames = topTeams.isNotEmpty ? topTeams.first.gamesThisWeek : 0;
        final hotTeams = topTeams.where((t) => t.gamesThisWeek == mostGames).toList();

        return MaxWidth(
          child: RefreshIndicator(
            onRefresh: () => state.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.sports_basketball, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Fantasy Helper",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              DateFormat("EEEE, MMMM d").format(DateTime.now()),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick stats row
                  Row(
                    children: [
                      Expanded(child: _StatPill(
                        label: "Today",
                        value: "${todayGames.length}",
                        subtitle: "games",
                        color: theme.colorScheme.primary,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatPill(
                        label: "Tomorrow",
                        value: "${tomorrowGames.length}",
                        subtitle: "games",
                        color: const Color(0xFF8B5CF6),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatPill(
                        label: "B2B",
                        value: "${b2b.length}",
                        subtitle: "teams",
                        color: const Color(0xFFF59E0B),
                      )),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Hot teams this week
                  if (hotTeams.isNotEmpty) ...[
                    NbaCard(
                      padding: const EdgeInsets.all(16),
                      border: Border.all(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: const Color(0xFF22C55E).withValues(alpha: 0.14),
                                ),
                                child: const Icon(Icons.local_fire_department, size: 16, color: Color(0xFF22C55E)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Most games this week",
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              GameCountChip(count: mostGames),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: hotTeams.map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                t.abbreviation,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Today's Games
                  const SectionHeader(
                    title: "Today's Games",
                    icon: Icons.today,
                  ),
                  if (todayGames.isEmpty)
                    NbaCard(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "No games today",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    NbaCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          for (int i = 0; i < todayGames.length; i++) ...[
                            _GameTile(game: todayGames[i]),
                            if (i < todayGames.length - 1)
                              Divider(height: 1, indent: 16, endIndent: 16,
                                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Back to Backs
                  SectionHeader(
                    title: "Back-to-Back Alert",
                    icon: Icons.warning_amber_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    trailing: Text(
                      "${b2b.length} teams",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (b2b.isEmpty)
                    NbaCard(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "No back-to-backs today/tomorrow",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    NbaCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "These teams play today AND tomorrow. Watch for rest days!",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: b2b.map((team) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                team,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Resting Teams
                  SectionHeader(
                    title: "Teams Resting",
                    icon: Icons.hotel,
                    iconColor: const Color(0xFF8B5CF6),
                    trailing: Text(
                      "${resting.length} teams",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  NbaCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "No games today or tomorrow",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (resting.isEmpty)
                          Text(
                            "All teams are playing!",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: resting.map((team) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                team,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tomorrow's Games
                  const SectionHeader(
                    title: "Tomorrow's Games",
                    icon: Icons.skip_next,
                  ),
                  if (tomorrowGames.isEmpty)
                    NbaCard(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "No games tomorrow",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    NbaCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          for (int i = 0; i < tomorrowGames.length; i++) ...[
                            _GameTile(game: tomorrowGames[i]),
                            if (i < tomorrowGames.length - 1)
                              Divider(height: 1, indent: 16, endIndent: 16,
                                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NbaCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({required this.game});

  final NbaGame game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                game.awayAbbrev,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "@",
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                game.homeAbbrev,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              game.displayLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
