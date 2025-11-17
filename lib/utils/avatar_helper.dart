class AvatarHelper {
  /// Generate BuddyPress avatar URL for a user
  static String getAvatarUrl(int userId, {String size = 'bpfull'}) {
    return 'https://gread.fun/wp-content/uploads/avatars/$userId/avatar-$size.jpg';
  }

  /// Get fallback Gravatar URL
  static String getGravatarUrl({String email = '', int size = 150}) {
    return 'https://www.gravatar.com/avatar/default?d=mp&s=$size';
  }

  /// Get best available avatar URL from various sources
  static String getBestAvatar({
    String? providedAvatar,
    int? userId,
    String? email,
  }) {
    if (providedAvatar != null && providedAvatar.isNotEmpty) {
      return providedAvatar;
    }

    if (userId != null) {
      return getAvatarUrl(userId);
    }

    return getGravatarUrl(email: email ?? '');
  }
}
