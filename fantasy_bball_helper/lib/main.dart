import "package:flutter/material.dart";

import "src/app_shell.dart";
import "src/theme/nba_theme.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FantasyBballApp());
}

class FantasyBballApp extends StatelessWidget {
  const FantasyBballApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Fantasy Basketball Helper",
      debugShowCheckedModeBanner: false,
      theme: NbaTheme.light(),
      darkTheme: NbaTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}
