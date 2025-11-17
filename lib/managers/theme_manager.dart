import 'package:flutter/material.dart';
import '../models/cosmetic.dart';
import '../services/api_manager.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager shared = ThemeManager._internal();

  AppTheme currentTheme = AppTheme(
    id: 'default',
    name: 'Default',
    description: 'Default GRead theme',
    primaryColor: '#6750A4',
    secondaryColor: '#625B71',
    accentColor: '#7D5260',
    backgroundColor: '#FFFFFF',
    isDarkTheme: false,
  );

  List<AppTheme> availableThemes = [];
  UserCosmetics? userCosmetics;

  ThemeManager._internal() {
    _initializeDefaultThemes();
  }

  void _initializeDefaultThemes() {
    availableThemes = [
      AppTheme(
        id: 'default',
        name: 'Default',
        description: 'Light purple theme',
        primaryColor: '#6750A4',
        secondaryColor: '#625B71',
        accentColor: '#7D5260',
        backgroundColor: '#FFFFFF',
        isDarkTheme: false,
      ),
      AppTheme(
        id: 'dark',
        name: 'Dark',
        description: 'Dark theme',
        primaryColor: '#D0BCFF',
        secondaryColor: '#CCC2DC',
        accentColor: '#EFB8C8',
        backgroundColor: '#1C1B1F',
        isDarkTheme: true,
      ),
    ];
  }

  Future<void> loadUserCosmetics() async {
    try {
      userCosmetics = await APIManager.shared.getUserCosmetics();
      if (userCosmetics?.activeTheme != null) {
        final theme = availableThemes.firstWhere(
          (t) => t.id == userCosmetics!.activeTheme,
          orElse: () => currentTheme,
        );
        setTheme(theme);
      }
    } catch (e) {
      print('Failed to load user cosmetics: $e');
    }
  }

  Future<void> loadAvailableThemes() async {
    try {
      final cosmetics = await APIManager.shared.getAvailableCosmetics();
      for (final cosmetic in cosmetics) {
        if (cosmetic.type == CosmeticType.theme && cosmetic.theme != null) {
          if (!availableThemes.any((t) => t.id == cosmetic.theme!.id)) {
            availableThemes.add(cosmetic.theme!);
          }
        }
      }
      notifyListeners();
    } catch (e) {
      print('Failed to load available themes: $e');
    }
  }

  void setTheme(AppTheme theme) {
    currentTheme = theme;
    notifyListeners();
  }

  Future<void> setActiveTheme(String themeId) async {
    try {
      userCosmetics = await APIManager.shared.setActiveTheme(themeId);
      final theme = availableThemes.firstWhere(
        (t) => t.id == themeId,
        orElse: () => currentTheme,
      );
      setTheme(theme);
    } catch (e) {
      print('Failed to set active theme: $e');
    }
  }

  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: currentTheme.effectiveIsDarkTheme ? Brightness.dark : Brightness.light,
        primary: currentTheme.primary,
        onPrimary: currentTheme.effectiveIsDarkTheme ? Colors.black : Colors.white,
        secondary: currentTheme.secondary,
        onSecondary: currentTheme.effectiveIsDarkTheme ? Colors.black : Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: currentTheme.background,
        onSurface: currentTheme.effectiveIsDarkTheme ? Colors.white : Colors.black,
      ),
      scaffoldBackgroundColor: currentTheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: currentTheme.background,
        foregroundColor: currentTheme.effectiveIsDarkTheme ? Colors.white : Colors.black,
        elevation: 0,
      ),
    );
  }
}
