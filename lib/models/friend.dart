import 'user.dart';

class FriendRequest {
  final int id;
  final int userId;
  final int friendId;
  final int initiatorId;
  final String status; // "pending", "accepted", "rejected"
  final String createdAt;
  final User? user;
  final User? friend;

  FriendRequest({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.initiatorId,
    required this.status,
    required this.createdAt,
    this.user,
    this.friend,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      friendId: json['friend_id'] ?? 0,
      initiatorId: json['initiator_id'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      friend: json['friend'] != null ? User.fromJson(json['friend']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'initiator_id': initiatorId,
      'status': status,
      'created_at': createdAt,
      'user': user?.toJson(),
      'friend': friend?.toJson(),
    };
  }
}

class FriendsListResponse {
  final bool success;
  final List<User> friends;
  final int? totalCount;

  FriendsListResponse({
    required this.success,
    required this.friends,
    this.totalCount,
  });

  factory FriendsListResponse.fromJson(Map<String, dynamic> json) {
    return FriendsListResponse(
      success: json['success'] ?? false,
      friends: json['friends'] != null
          ? (json['friends'] as List).map((f) => User.fromJson(f)).toList()
          : [],
      totalCount: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'friends': friends.map((f) => f.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class FriendRequestResponse {
  final bool success;
  final String message;
  final FriendRequest? friendRequest;

  FriendRequestResponse({
    required this.success,
    required this.message,
    this.friendRequest,
  });

  factory FriendRequestResponse.fromJson(Map<String, dynamic> json) {
    return FriendRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      friendRequest: json['friend_request'] != null
          ? FriendRequest.fromJson(json['friend_request'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'friend_request': friendRequest?.toJson(),
    };
  }
}

class PendingRequestsResponse {
  final bool success;
  final List<FriendRequest> requests;
  final int? totalCount;

  PendingRequestsResponse({
    required this.success,
    required this.requests,
    this.totalCount,
  });

  factory PendingRequestsResponse.fromJson(Map<String, dynamic> json) {
    return PendingRequestsResponse(
      success: json['success'] ?? false,
      requests: json['requests'] != null
          ? (json['requests'] as List)
              .map((r) => FriendRequest.fromJson(r))
              .toList()
          : [],
      totalCount: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'requests': requests.map((r) => r.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}

class UserSearchResponse {
  final bool success;
  final List<User> users;
  final int? totalCount;

  UserSearchResponse({
    required this.success,
    required this.users,
    this.totalCount,
  });

  factory UserSearchResponse.fromJson(Map<String, dynamic> json) {
    return UserSearchResponse(
      success: json['success'] ?? false,
      users: json['users'] != null
          ? (json['users'] as List).map((u) => User.fromJson(u)).toList()
          : [],
      totalCount: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'users': users.map((u) => u.toJson()).toList(),
      'total_count': totalCount,
    };
  }
}
