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

    return Activity(
      id: json['id'] ?? 0,
      component: json['component'] ?? '',
      type: json['type'] ?? '',
      userId: json['user_id'] ?? 0,
      userName: json['user_login'] ?? '',
      displayName: json['user_nicename'],
      content: json['content'] ?? '',
      contentHtml: json['content_html'],
      dateRecorded: DateTime.tryParse(json['date_recorded'] ?? '') ?? DateTime.now(),
      avatar: json['user_avatar_urls']?['full'],
    );
  }

  /// Check if this is a BuddyPress activity (not a post or other content)
  bool isBuddyPressActivity() {
    // Only show activities where component is 'activity' or 'groups' or 'members'
    // and type is 'activity_update', 'activity_comment', etc.
    final isActivityComponent = component.toLowerCase() == 'activity' ||
        component.toLowerCase() == 'groups' ||
        component.toLowerCase() == 'members' ||
        component.toLowerCase() == 'friends' ||
        component.toLowerCase() == 'xprofile';

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
