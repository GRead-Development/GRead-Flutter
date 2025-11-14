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
