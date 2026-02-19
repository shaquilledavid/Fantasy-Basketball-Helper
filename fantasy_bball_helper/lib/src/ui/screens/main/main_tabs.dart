import "package:flutter/material.dart";

import "../../../state/app_state.dart";
import "../home/home_screen.dart";
import "../schedule/schedule_screen.dart";
import "../teams/teams_screen.dart";
import "../settings/settings_screen.dart";

class MainTabs extends StatefulWidget {
  const MainTabs({super.key, required this.state});

  final AppState state;

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(state: widget.state),
      ScheduleScreen(state: widget.state),
      TeamsScreen(state: widget.state),
      SettingsScreen(state: widget.state),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: "Teams",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
