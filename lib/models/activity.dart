import 'dart:developer' as developer;

class Activity {
  final int id;
  final String component;
  final String type;
  final int userId;
  final String userName;
  final String? displayName;
  final String content;
  final String? contentHtml;
  final DateTime dateRecorded;
  final String? avatar;

  Activity({
    required this.id,
    required this.component,
    required this.type,
    required this.userId,
    required this.userName,
    this.displayName,
    required this.content,
    this.contentHtml,
    required this.dateRecorded,
    this.avatar,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    developer.log(
      'Parsing activity - Component: ${json['component']}, Type: ${json['type']}, ID: ${json['id']}',
      name: 'Activity',
    );
    developer.log(
      'Full activity data: $json',
      name: 'Activity',
    );

    // Helper to safely convert values to strings
    String _toSafeString(dynamic value, {String defaultValue = ''}) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      if (value is Map) {
        // If it's a map, try to get a string representation
        developer.log(
          'Warning: Expected String but got Map for value: $value',
          name: 'Activity',
        );
        return value.toString();
      }
      return value.toString();
    }

    // Extract avatar safely
    String? _getAvatar() {
      final avatarUrls = json['user_avatar_urls'];
      if (avatarUrls == null) return null;

      if (avatarUrls is Map) {
        final full = avatarUrls['full'];
        if (full is String) return full;
        if (full != null) return full.toString();
      } else if (avatarUrls is String) {
        return avatarUrls;
      }
      return null;
    }

    return Activity(
      id: json['id'] ?? 0,
      component: _toSafeString(json['component']),
      type: _toSafeString(json['type']),
      userId: json['user_id'] ?? 0,
      userName: _toSafeString(json['user_login']),
      displayName: _toSafeString(json['user_nicename']),
      content: _toSafeString(json['content']),
      contentHtml: _toSafeString(json['content_html']),
      dateRecorded: DateTime.tryParse(json['date_recorded'] ?? '') ?? DateTime.now(),
      avatar: _getAvatar(),
    );
  }

  /// Check if this is a BuddyPress activity (not a post or other content)
  bool isBuddyPressActivity() {
    final componentLower = component.toLowerCase();
    final typeLower = type.toLowerCase();

    // Exclude specific activity types that are not user-generated content
    final excludedTypes = {
      'new_member',
      'joined_group',
      'user_registered',
      'blog_published', // WordPress posts
      'bp_member_activity_created',
      'bp_activity_activity_created',
    };

    // Exclude non-user-content from members component
    if (componentLower == 'members' && excludedTypes.contains(typeLower)) {
      developer.log(
        'Filtering out members signup - Type: $type',
        name: 'Activity',
      );
      return false;
    }

    // Only show activities from these components with meaningful content
    final isActivityComponent = componentLower == 'activity' ||
        componentLower == 'groups' ||
        (componentLower == 'members' && typeLower == 'updated_profile') ||
        componentLower == 'friends' ||
        componentLower == 'xprofile';

    developer.log(
      'Activity check - Component: $component, Type: $type, IsActivity: $isActivityComponent',
      name: 'Activity',
    );

    return isActivityComponent;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'component': component,
      'type': type,
      'user_id': userId,
      'user_login': userName,
      'user_nicename': displayName,
      'content': content,
      'content_html': contentHtml,
      'date_recorded': dateRecorded.toIso8601String(),
      'user_avatar_urls': {'full': avatar},
    };
  }
}
