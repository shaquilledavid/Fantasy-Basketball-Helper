import "package:flutter/material.dart";
import "package:intl/intl.dart";

import "../../../state/app_state.dart";
import "../../../state/models.dart";
import "../../widgets/layout.dart";
import "../../widgets/nba_card.dart";
import "../../widgets/game_count_chip.dart";

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key, required this.state});

  final AppState state;

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  String _search = "";
  String _conferenceFilter = "All";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: widget.state,
      builder: (context, _) {
        if (widget.state.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        var teams = widget.state.allTeams;
        if (_conferenceFilter != "All") {
          teams = teams.where((t) => t.conference == _conferenceFilter).toList();
        }
        if (_search.isNotEmpty) {
          final q = _search.toLowerCase();
          teams = teams.where((t) =>
              t.fullName.toLowerCase().contains(q) ||
              t.abbreviation.toLowerCase().contains(q)).toList();
        }

        return MaxWidth(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Teams",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Search bar
                    TextField(
                      onChanged: (v) => setState(() => _search = v),
                      decoration: InputDecoration(
                        hintText: "Search teams...",
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ConfChip(
                          label: "All",
                          selected: _conferenceFilter == "All",
                          onTap: () => setState(() => _conferenceFilter = "All"),
                        ),
                        const SizedBox(width: 8),
                        _ConfChip(
                          label: "East",
                          selected: _conferenceFilter == "East",
                          onTap: () => setState(() => _conferenceFilter = "East"),
                        ),
                        const SizedBox(width: 8),
                        _ConfChip(
                          label: "West",
                          selected: _conferenceFilter == "West",
                          onTap: () => setState(() => _conferenceFilter = "West"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TeamDetailTile(
                        team: team,
                        state: widget.state,
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

class _ConfChip extends StatelessWidget {
  const _ConfChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

class _TeamDetailTile extends StatefulWidget {
  const _TeamDetailTile({
    required this.team,
    required this.state,
  });

  final NbaTeam team;
  final AppState state;

  @override
  State<_TeamDetailTile> createState() => _TeamDetailTileState();
}

class _TeamDetailTileState extends State<_TeamDetailTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekInfo = widget.state.weeklyBreakdown[widget.team.abbreviation];
    final schedule = widget.state.teamScheduleThisWeek(widget.team.abbreviation);
    final gamesLeft = widget.state.gamesLeftThisWeek(widget.team.abbreviation);
    final dayFmt = DateFormat("EEE, MMM d");

    return NbaCard(
      padding: const EdgeInsets.all(14),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        children: [
          Row(
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
                    widget.team.abbreviation,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
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
                      widget.team.fullName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${widget.team.conference} Conference",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (weekInfo != null)
                    GameCountChip(count: weekInfo.gamesThisWeek),
                  const SizedBox(height: 4),
                  Text(
                    "$gamesLeft left",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: _expanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: schedule.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      "No games this week",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 4),
                        for (final game in schedule) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    dayFmt.format(game.date),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    game.awayAbbrev == widget.team.abbreviation
                                        ? "@ ${game.homeName}"
                                        : "vs ${game.awayName}",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: game.awayAbbrev == widget.team.abbreviation
                                        ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                                        : const Color(0xFF22C55E).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    game.awayAbbrev == widget.team.abbreviation
                                        ? "Away"
                                        : "Home",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: game.awayAbbrev == widget.team.abbreviation
                                          ? const Color(0xFF8B5CF6)
                                          : const Color(0xFF22C55E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
