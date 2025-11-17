import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'managers/theme_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/main_tab_view.dart';

void main() {
  runApp(const GReadApp());
}

class GReadApp extends StatelessWidget {
  const GReadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeManager.shared),
      ],
      child: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.wait([
      context.read<AuthProvider>().initialize(),
      context.read<ThemeManager>().loadAvailableThemes(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, _) {
        return MaterialApp(
          title: 'GRead',
          theme: themeManager.themeData,
          debugShowCheckedModeBanner: false,
          home: _showSplash
              ? SplashScreen(
                  onComplete: () {
                    setState(() {
                      _showSplash = false;
                    });
                  },
                )
              : const HomeRouter(),
        );
      },
    );
  }
}

class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated || auth.isGuestMode) {
          return const MainTabView();
        } else {
          return FutureBuilder<dynamic>(
            future: Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LandingScreen(),
                fullscreenDialog: true,
              ),
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == 'guest') {
                // User selected guest mode
                Future.microtask(() => auth.enterGuestMode());
                return const MainTabView();
              }
              // If we're waiting or user logged in
              if (auth.isAuthenticated || auth.isGuestMode) {
                return const MainTabView();
              }
              // Show landing while waiting
              return const Center(child: CircularProgressIndicator());
            },
          );
        }
      },
    );
  }
}
