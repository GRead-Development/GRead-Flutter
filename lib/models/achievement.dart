class Achievement {
  final int id;
  final String slug;
  final String name;
  final String description;
  final AchievementIcon icon;
  final UnlockRequirements unlockRequirements;
  final int reward;
  final bool isHidden;
  final int displayOrder;
  final AchievementProgress? progress;
  final bool? isUnlocked;
  final String? dateUnlocked;

  Achievement({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlockRequirements,
    required this.reward,
    required this.isHidden,
    required this.displayOrder,
    this.progress,
    this.isUnlocked,
    this.dateUnlocked,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: AchievementIcon.fromJson(json['icon'] ?? {}),
      unlockRequirements:
          UnlockRequirements.fromJson(json['unlock_requirements'] ?? {}),
      reward: json['reward'] ?? 0,
      isHidden: json['is_hidden'] ?? false,
      displayOrder: json['display_order'] ?? 0,
      progress: json['progress'] != null
          ? AchievementProgress.fromJson(json['progress'])
          : null,
      isUnlocked: json['is_unlocked'],
      dateUnlocked: json['date_unlocked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'description': description,
      'icon': icon.toJson(),
      'unlock_requirements': unlockRequirements.toJson(),
      'reward': reward,
      'is_hidden': isHidden,
      'display_order': displayOrder,
      'progress': progress?.toJson(),
      'is_unlocked': isUnlocked,
      'date_unlocked': dateUnlocked,
    };
  }
}

class AchievementIcon {
  final String type;
  final String color;
  final String symbol;

  AchievementIcon({
    required this.type,
    required this.color,
    required this.symbol,
  });

  factory AchievementIcon.fromJson(Map<String, dynamic> json) {
    return AchievementIcon(
      type: json['type'] ?? '',
      color: json['color'] ?? '#000000',
      symbol: json['symbol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'color': color,
      'symbol': symbol,
    };
  }
}

class UnlockRequirements {
  final String metric;
  final int value;
  final String condition;

  UnlockRequirements({
    required this.metric,
    required this.value,
    required this.condition,
  });

  factory UnlockRequirements.fromJson(Map<String, dynamic> json) {
    return UnlockRequirements(
      metric: json['metric'] ?? '',
      value: json['value'] ?? 0,
      condition: json['condition'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metric': metric,
      'value': value,
      'condition': condition,
    };
  }
}

class AchievementProgress {
  final int current;
  final int required;
  final double percentage;

  AchievementProgress({
    required this.current,
    required this.required,
    required this.percentage,
  });

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      current: json['current'] ?? 0,
      required: json['required'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'required': required,
      'percentage': percentage,
    };
  }
}

class UserAchievementsResponse {
  final int userId;
  final int total;
  final int unlockedCount;
  final List<Achievement> achievements;

  UserAchievementsResponse({
    required this.userId,
    required this.total,
    required this.unlockedCount,
    required this.achievements,
  });

  factory UserAchievementsResponse.fromJson(Map<String, dynamic> json) {
    int userId;
    if (json['user_id'] is int) {
      userId = json['user_id'];
    } else if (json['user_id'] is String) {
      userId = int.tryParse(json['user_id']) ?? 0;
    } else {
      userId = 0;
    }

    return UserAchievementsResponse(
      userId: userId,
      total: json['total'] ?? 0,
      unlockedCount: json['unlocked_count'] ?? 0,
      achievements: json['achievements'] != null
          ? (json['achievements'] as List)
              .map((a) => Achievement.fromJson(a))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total': total,
      'unlocked_count': unlockedCount,
      'achievements': achievements.map((a) => a.toJson()).toList(),
    };
  }
}

class LeaderboardEntry {
  final int rank;
  final int userId;
  final String userName;
  final String userAvatarUrl;
  final int achievementCount;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.achievementCount,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    int userId;
    if (json['user_id'] is int) {
      userId = json['user_id'];
    } else if (json['user_id'] is String) {
      userId = int.tryParse(json['user_id']) ?? 0;
    } else {
      userId = 0;
    }

    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      userId: userId,
      userName: json['user_name'] ?? '',
      userAvatarUrl: json['user_avatar_url'] ?? '',
      achievementCount: json['achievement_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'user_name': userName,
      'user_avatar_url': userAvatarUrl,
      'achievement_count': achievementCount,
    };
  }
}
