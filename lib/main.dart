import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: const KhatwaApp(),
    ),
  );
}

class KhatwaApp extends StatelessWidget {
  const KhatwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppState>().themeMode;
    return MaterialApp(
      title: 'خطوة',
      debugShowCheckedModeBanner: false,
      theme: KhatwaTheme.light,
      darkTheme: KhatwaTheme.dark,
      themeMode: themeMode,
      home: const MainShell(),
    );
  }
}
