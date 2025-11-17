import 'package:flutter/material.dart';
import 'user_stats.dart';

enum CosmeticType { theme, icon, badge, profileFrame }

class UnlockRequirement {
  final String stat; // "booksCompleted", "pagesRead", "points", etc.
  final int value;

  UnlockRequirement({
    required this.stat,
    required this.value,
  });

  factory UnlockRequirement.fromJson(Map<String, dynamic> json) {
    return UnlockRequirement(
      stat: json['stat'] ?? '',
      value: json['value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stat': stat,
      'value': value,
    };
  }

  bool isMet(UserStats stats) {
    final normalizedStat = stat.replaceAll('_', '').toLowerCase();
    switch (normalizedStat) {
      case 'bookscompleted':
        return stats.booksCompleted >= value;
      case 'pagesread':
        return stats.pagesRead >= value;
      case 'points':
        return stats.points >= value;
      case 'booksadded':
        return stats.booksAdded >= value;
      case 'approvedreports':
        return stats.approvedReports >= value;
      default:
        return false;
    }
  }

  String get label {
    switch (stat) {
      case 'booksCompleted':
        return 'Books Completed';
      case 'pagesRead':
        return 'Pages Read';
      case 'points':
        return 'Points';
      case 'booksAdded':
        return 'Books Added';
      case 'approvedReports':
        return 'Approved Reports';
      default:
        return stat;
    }
  }
}

class AppTheme {
  final String id;
  final String name;
  final String description;
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String backgroundColor;
  final bool isDarkTheme;
  final UnlockRequirement? unlockRequirement;

  AppTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    this.isDarkTheme = false,
    this.unlockRequirement,
  });

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      primaryColor: json['primary_color'] ?? '#6750A4',
      secondaryColor: json['secondary_color'] ?? '#625B71',
      accentColor: json['accent_color'] ?? '#7D5260',
      backgroundColor: json['background_color'] ?? '#FFFFFF',
      isDarkTheme: json['is_dark_theme'] ?? false,
      unlockRequirement: json['unlock_requirement'] != null
          ? UnlockRequirement.fromJson(json['unlock_requirement'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'accent_color': accentColor,
      'background_color': backgroundColor,
      'is_dark_theme': isDarkTheme,
      'unlock_requirement': unlockRequirement?.toJson(),
    };
  }

  Color get primary => _colorFromHex(primaryColor);
  Color get secondary => _colorFromHex(secondaryColor);
  Color get accent => _colorFromHex(accentColor);
  Color get background => _colorFromHex(backgroundColor);

  bool get effectiveIsDarkTheme {
    // Calculate brightness of background color
    final color = background;
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance < 0.5;
  }

  Color _colorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class CustomIcon {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  CustomIcon({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory CustomIcon.fromJson(Map<String, dynamic> json) {
    return CustomIcon(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
    };
  }
}

class CosmeticUnlock {
  final String id;
  final CosmeticType type;
  final String name;
  final String description;
  final String? imageUrl;
  final DateTime? unlockedAt;
  final String unlockedBy;
  final int requiredValue;
  final AppTheme? theme;
  final CustomIcon? icon;

  CosmeticUnlock({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    this.imageUrl,
    this.unlockedAt,
    required this.unlockedBy,
    required this.requiredValue,
    this.theme,
    this.icon,
  });

  factory CosmeticUnlock.fromJson(Map<String, dynamic> json) {
    CosmeticType parseType(String type) {
      switch (type.toLowerCase()) {
        case 'theme':
          return CosmeticType.theme;
        case 'icon':
          return CosmeticType.icon;
        case 'badge':
          return CosmeticType.badge;
        case 'profileframe':
          return CosmeticType.profileFrame;
        default:
          return CosmeticType.theme;
      }
    }

    return CosmeticUnlock(
      id: json['id'] ?? '',
      type: parseType(json['type'] ?? 'theme'),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.tryParse(json['unlocked_at'])
          : null,
      unlockedBy: json['unlocked_by'] ?? '',
      requiredValue: json['required_value'] ?? 0,
      theme: json['theme'] != null ? AppTheme.fromJson(json['theme']) : null,
      icon: json['icon'] != null ? CustomIcon.fromJson(json['icon']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'unlocked_at': unlockedAt?.toIso8601String(),
      'unlocked_by': unlockedBy,
      'required_value': requiredValue,
      'theme': theme?.toJson(),
      'icon': icon?.toJson(),
    };
  }
}

class UserCosmetics {
  String? activeTheme;
  String? activeIcon;
  String? activeFont;
  List<String> unlockedCosmetics;

  UserCosmetics({
    this.activeTheme,
    this.activeIcon,
    this.activeFont,
    this.unlockedCosmetics = const [],
  });

  factory UserCosmetics.fromJson(Map<String, dynamic> json) {
    return UserCosmetics(
      activeTheme: json['active_theme'],
      activeIcon: json['active_icon'],
      activeFont: json['active_font'],
      unlockedCosmetics: json['unlocked_cosmetics'] != null
          ? List<String>.from(json['unlocked_cosmetics'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_theme': activeTheme,
      'active_icon': activeIcon,
      'active_font': activeFont,
      'unlocked_cosmetics': unlockedCosmetics,
    };
  }
}
