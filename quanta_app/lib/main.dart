import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Services
import 'services/firebase_auth_service.dart';
import 'services/groq_service.dart';
import 'theme/theme_provider.dart';
import 'theme/quanta_theme.dart';
import 'storage/history_store.dart';
import 'storage/coin_store.dart';

// Screens
import 'screens/account_screen.dart';
import 'screens/history_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/terms_screen.dart';

// Visualiser
import 'visualiser/visualiser_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase — wrapped so the app can still launch without it.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    // Firebase disabled / not configured. App will run in offline mode.
    // ignore: avoid_print
    print('[main] Firebase.initializeApp failed (running without Firebase): $e');
    // ignore: avoid_print
    print(st);
  }

  // Initialize Auth service (skip if Firebase init above failed).
  final authService = FirebaseAuthService();
  try {
    await authService.initialize();
  } catch (e) {
    // ignore: avoid_print
    print('[main] FirebaseAuthService.initialize failed: $e');
  }

  // Initialize History persistence
  await HistoryStore.init();

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  final coinStore = CoinStore();
  await coinStore.init();
  await coinStore.seedIfEmpty();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider<FirebaseAuthService>.value(value: authService),
        ChangeNotifierProvider(create: (_) => GroqService()..loadApiKey()),
        ChangeNotifierProvider<CoinStore>.value(value: coinStore),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: "Quanta",
      debugShowCheckedModeBanner: false,

      themeMode: themeProvider.themeMode,

      // Quanta palette — single source of truth in quanta_theme.dart
      theme: quantaLight,
      darkTheme: quantaDark,

      initialRoute: '/splash',

      onGenerateRoute: (settings) {
        late Widget page;

        switch (settings.name) {
          case '/splash':
            page = const SplashScreen();
            break;

          case '/':
            page = const MainScreen();
            break;

          case '/login':
            page = const LoginScreen();
            break;

          case '/history':
            page = const HistoryScreen();
            break;

          case '/settings':
            page = const SettingsScreen();
            break;

          case '/privacy':
            page = const PrivacyPolicyScreen();
            break;

          case '/terms':
            page = const TermsScreen();
            break;

          case '/account':
            page = const AccountScreen();
            break;

          default:
            page = const MainScreen();
        }

        // Smooth transition effect
        return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 240),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          pageBuilder: (_, animation, secondaryAnimation) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.03, 0),
                  end: Offset.zero,
                ).animate(curved),
                child: page,
              ),
            );
          },
        );
      },
    );
  }
}