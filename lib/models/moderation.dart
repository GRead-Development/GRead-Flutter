class BlockedListResponse {
  final bool success;
  final List<int> blockedUsers;

  BlockedListResponse({
    required this.success,
    required this.blockedUsers,
  });

  factory BlockedListResponse.fromJson(Map<String, dynamic> json) {
    return BlockedListResponse(
      success: json['success'] ?? false,
      blockedUsers: json['blocked_users'] != null
          ? List<int>.from(json['blocked_users'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'blocked_users': blockedUsers,
    };
  }
}

class MutedListResponse {
  final bool success;
  final List<int> mutedUsers;

  MutedListResponse({
    required this.success,
    required this.mutedUsers,
  });

  factory MutedListResponse.fromJson(Map<String, dynamic> json) {
    return MutedListResponse(
      success: json['success'] ?? false,
      mutedUsers: json['muted_users'] != null
          ? List<int>.from(json['muted_users'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'muted_users': mutedUsers,
    };
  }
}

class ModerationResponse {
  final bool success;
  final String message;

  ModerationResponse({
    required this.success,
    required this.message,
  });

  factory ModerationResponse.fromJson(Map<String, dynamic> json) {
    return ModerationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}
