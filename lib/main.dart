import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/moderation_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  developer.log('App starting', name: 'main');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ModerationProvider()),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    developer.log('AppRoot initializing', name: 'AppRoot');
    // Initialize auth on app startup
    _initFuture = context.read<AuthProvider>().initializeAuth();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        developer.log(
          'AppRoot build - Auth init snapshot state: ${snapshot.connectionState}',
          name: 'AppRoot',
        );

        return MaterialApp(
          title: 'GRead App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: _buildHome(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/home': (_) => const HomeScreen(),
          },
        );
      },
    );
  }

  Widget _buildHome() {
    final authProvider = context.watch<AuthProvider>();

    developer.log(
      'Building home - Logged in: ${authProvider.loggedIn}',
      name: 'AppRoot',
    );

    // Always show HomeScreen, authentication is handled per-feature
    return const HomeScreen();
  }
}
