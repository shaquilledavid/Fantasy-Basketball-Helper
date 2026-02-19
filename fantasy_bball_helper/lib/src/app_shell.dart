import "package:flutter/material.dart";

import "state/app_state.dart";
import "ui/screens/main/main_tabs.dart";

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.initialize();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: MainTabs(
            key: const ValueKey("main"),
            state: _appState,
          ),
        );
      },
    );
  }
}
