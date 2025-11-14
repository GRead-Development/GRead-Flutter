class User {
  final String email;
  final String username;
  final String displayName;

  User({
    required this.email,
    required this.username,
    required this.displayName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['user_email'] ?? '',
      username: json['user_nicename'] ?? '',
      displayName: json['user_display_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_email': email,
      'user_nicename': username,
      'user_display_name': displayName,
    };
  }
}
