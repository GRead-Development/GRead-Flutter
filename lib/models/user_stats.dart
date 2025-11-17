class UserStats {
  final int? userId;
  final String displayName;
  final String avatarUrl;
  final int points;
  final int booksCompleted;
  final int pagesRead;
  final int booksAdded;
  final int approvedReports;

  UserStats({
    this.userId,
    required this.displayName,
    required this.avatarUrl,
    required this.points,
    required this.booksCompleted,
    required this.pagesRead,
    required this.booksAdded,
    required this.approvedReports,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['user_id'],
      displayName: json['display_name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      points: json['points'] ?? 0,
      booksCompleted: json['books_completed'] ?? 0,
      pagesRead: json['pages_read'] ?? 0,
      booksAdded: json['books_added'] ?? 0,
      approvedReports: json['approved_reports'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'points': points,
      'books_completed': booksCompleted,
      'pages_read': pagesRead,
      'books_added': booksAdded,
      'approved_reports': approvedReports,
    };
  }
}
