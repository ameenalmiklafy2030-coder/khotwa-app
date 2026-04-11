import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: KhatwaTheme.primary,
      statusBarIconBrightness: Brightness.light,
    ),
  );
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
    final state = context.watch<AppState>();
    return MaterialApp(
      title: 'خطوة',
      debugShowCheckedModeBanner: false,
      theme: KhatwaTheme.light,
      darkTheme: KhatwaTheme.dark,
      themeMode: state.themeMode,
      home: state.loading
          ? const _SplashScreen()
          : state.isFirstLaunch
              ? const OnboardingScreen()
              : const MainShell(),
    );
  }
}

// ── شاشة البداية أثناء التحميل ──
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: KhatwaTheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الأيقونة مؤقتاً — تُستبدل بـ KhatwaIcon
            Text('👣', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('خطوة',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 2)),
            SizedBox(height: 40),
            CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
