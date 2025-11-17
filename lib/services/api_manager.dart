import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../models/user_stats.dart';
import '../models/moderation.dart';
import '../models/activity.dart';
import '../models/cosmetic.dart';
import '../models/friend.dart';
import '../models/achievement.dart';
import '../models/message.dart';
import '../models/group.dart';
import '../models/user.dart';
import 'auth_service.dart';

class APIManager {
  static final APIManager shared = APIManager._internal();

  late Dio _dio;
  final String baseURL = 'https://gread.fun/wp-json/buddypress/v1';
  final String customBaseURL = 'https://gread.fun/wp-json/gread/v1';
  final _auth = AuthService();

  APIManager._internal() {
    _dio = Dio();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _auth.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          developer.log('API Request: ${options.method} ${options.uri}', name: 'APIManager');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log('API Response: ${response.statusCode} ${response.requestOptions.uri}',
              name: 'APIManager');
          return handler.next(response);
        },
        onError: (error, handler) {
          developer.log(
              'API Error: ${error.response?.statusCode} - ${error.message}',
              name: 'APIManager',
              error: error);
          return handler.next(error);
        },
      ),
    );
  }

  // Generic request method for BuddyPress endpoints
  Future<T> request<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    String method = 'GET',
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    try {
      final url = baseURL + endpoint;
      final options = Options(method: method);

      Response response;
      if (method == 'GET') {
        response = await _dio.get(url, options: options);
      } else if (method == 'POST') {
        response = await _dio.post(url, data: body, options: options);
      } else if (method == 'PUT') {
        response = await _dio.put(url, data: body, options: options);
      } else if (method == 'DELETE') {
        response = await _dio.delete(url, options: options);
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log('Request failed: $e', name: 'APIManager', error: e);
      rethrow;
    }
  }

  // Generic request for custom GRead endpoints
  Future<T> customRequest<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
    String method = 'GET',
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    try {
      final url = customBaseURL + endpoint;
      final options = Options(method: method);

      Response response;
      if (method == 'GET') {
        response = await _dio.get(url, options: options);
      } else if (method == 'POST') {
        response = await _dio.post(url, data: body, options: options);
      } else if (method == 'PUT') {
        response = await _dio.put(url, data: body, options: options);
      } else if (method == 'DELETE') {
        response = await _dio.delete(url, options: options);
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log('Custom request failed: $e', name: 'APIManager', error: e);
      rethrow;
    }
  }

  // MARK: - User Stats Endpoints

  Future<UserStats> getUserStats(int userId) async {
    return customRequest(
      endpoint: '/user/$userId/stats',
      fromJson: (json) => UserStats.fromJson(json),
    );
  }

  // MARK: - Moderation Endpoints

  Future<ModerationResponse> blockUser(int userId) async {
    return customRequest(
      endpoint: '/user/block',
      method: 'POST',
      body: {'user_id': userId},
      fromJson: (json) => ModerationResponse.fromJson(json),
    );
  }

  Future<ModerationResponse> unblockUser(int userId) async {
    return customRequest(
      endpoint: '/user/unblock',
      method: 'POST',
      body: {'user_id': userId},
      fromJson: (json) => ModerationResponse.fromJson(json),
    );
  }

  Future<ModerationResponse> muteUser(int userId) async {
    return customRequest(
      endpoint: '/user/mute',
      method: 'POST',
      body: {'user_id': userId},
      fromJson: (json) => ModerationResponse.fromJson(json),
    );
  }

  Future<ModerationResponse> unmuteUser(int userId) async {
    return customRequest(
      endpoint: '/user/unmute',
      method: 'POST',
      body: {'user_id': userId},
      fromJson: (json) => ModerationResponse.fromJson(json),
    );
  }

  Future<ModerationResponse> reportUser(int userId, String reason) async {
    return customRequest(
      endpoint: '/user/report',
      method: 'POST',
      body: {'user_id': userId, 'reason': reason},
      fromJson: (json) => ModerationResponse.fromJson(json),
    );
  }

  Future<BlockedListResponse> getBlockedList() async {
    return customRequest(
      endpoint: '/user/blocked_list',
      fromJson: (json) => BlockedListResponse.fromJson(json),
    );
  }

  Future<MutedListResponse> getMutedList() async {
    return customRequest(
      endpoint: '/user/muted_list',
      fromJson: (json) => MutedListResponse.fromJson(json),
    );
  }

  // MARK: - Activity Feed Endpoints

  Future<ActivityFeedResponse> getActivityFeed({int page = 1, int perPage = 20}) async {
    return customRequest(
      endpoint: '/activity?per_page=$perPage&page=$page&type=activity_update',
      fromJson: (json) => ActivityFeedResponse.fromJson(json),
      authenticated: false,
    );
  }

  // MARK: - Cosmetics Endpoints

  Future<UserCosmetics> getUserCosmetics() async {
    return customRequest(
      endpoint: '/user/cosmetics',
      fromJson: (json) => UserCosmetics.fromJson(json),
    );
  }

  Future<List<CosmeticUnlock>> getAvailableCosmetics() async {
    final response = await _dio.get(customBaseURL + '/cosmetics');
    if (response.data is List) {
      return (response.data as List).map((c) => CosmeticUnlock.fromJson(c)).toList();
    }
    return [];
  }

  Future<UserCosmetics> setActiveTheme(String themeId) async {
    return customRequest(
      endpoint: '/user/cosmetics/theme',
      method: 'POST',
      body: {'theme_id': themeId},
      fromJson: (json) => UserCosmetics.fromJson(json),
    );
  }

  Future<UserCosmetics> setActiveIcon(String iconId) async {
    return customRequest(
      endpoint: '/user/cosmetics/icon',
      method: 'POST',
      body: {'icon_id': iconId},
      fromJson: (json) => UserCosmetics.fromJson(json),
    );
  }

  Future<List<CosmeticUnlock>> checkAndUnlockCosmetics(UserStats stats) async {
    final response = await _dio.post(
      customBaseURL + '/user/check-unlocks',
      data: {
        'points': stats.points,
        'books_completed': stats.booksCompleted,
        'pages_read': stats.pagesRead,
        'books_added': stats.booksAdded,
        'approved_reports': stats.approvedReports,
      },
    );
    if (response.data is List) {
      return (response.data as List).map((c) => CosmeticUnlock.fromJson(c)).toList();
    }
    return [];
  }

  // MARK: - Friend Endpoints

  Future<FriendsListResponse> getFriends(int userId) async {
    return customRequest(
      endpoint: '/friends/$userId',
      fromJson: (json) => FriendsListResponse.fromJson(json),
      authenticated: false,
    );
  }

  Future<PendingRequestsResponse> getPendingFriendRequests() async {
    return customRequest(
      endpoint: '/friends/requests/pending',
      fromJson: (json) => PendingRequestsResponse.fromJson(json),
    );
  }

  Future<FriendRequestResponse> sendFriendRequest(int friendId) async {
    return customRequest(
      endpoint: '/friends/request',
      method: 'POST',
      body: {'friend_id': friendId},
      fromJson: (json) => FriendRequestResponse.fromJson(json),
    );
  }

  Future<FriendRequestResponse> acceptFriendRequest(int requestId) async {
    return customRequest(
      endpoint: '/friends/request/$requestId/accept',
      method: 'POST',
      fromJson: (json) => FriendRequestResponse.fromJson(json),
    );
  }

  Future<FriendRequestResponse> rejectFriendRequest(int requestId) async {
    return customRequest(
      endpoint: '/friends/request/$requestId/reject',
      method: 'POST',
      fromJson: (json) => FriendRequestResponse.fromJson(json),
    );
  }

  Future<FriendRequestResponse> removeFriend(int friendId) async {
    return customRequest(
      endpoint: '/friends/$friendId/remove',
      method: 'POST',
      fromJson: (json) => FriendRequestResponse.fromJson(json),
    );
  }

  Future<UserSearchResponse> searchUsers(String query, {int page = 1, int perPage = 20}) async {
    final encodedQuery = Uri.encodeComponent(query);
    return customRequest(
      endpoint: '/members/search?search=$encodedQuery&per_page=$perPage&page=$page',
      fromJson: (json) => UserSearchResponse.fromJson(json),
      authenticated: false,
    );
  }

  // MARK: - Achievements API

  Future<List<Achievement>> getAllAchievements({bool showHidden = false}) async {
    final response = await _dio.get(
      customBaseURL + '/achievements?show_hidden=$showHidden',
    );
    if (response.data is List) {
      return (response.data as List).map((a) => Achievement.fromJson(a)).toList();
    }
    return [];
  }

  Future<Achievement> getAchievement(int id) async {
    return customRequest(
      endpoint: '/achievements/$id',
      fromJson: (json) => Achievement.fromJson(json),
      authenticated: false,
    );
  }

  Future<Achievement> getAchievementBySlug(String slug) async {
    return customRequest(
      endpoint: '/achievements/slug/$slug',
      fromJson: (json) => Achievement.fromJson(json),
      authenticated: false,
    );
  }

  Future<UserAchievementsResponse> getUserAchievements(int userId, {String filter = 'all'}) async {
    return customRequest(
      endpoint: '/user/$userId/achievements?filter=$filter',
      fromJson: (json) => UserAchievementsResponse.fromJson(json),
      authenticated: false,
    );
  }

  Future<List<LeaderboardEntry>> getAchievementsLeaderboard({int limit = 10, int offset = 0}) async {
    final response = await _dio.get(
      customBaseURL + '/achievements/leaderboard?limit=$limit&offset=$offset',
    );
    if (response.data is List) {
      return (response.data as List).map((e) => LeaderboardEntry.fromJson(e)).toList();
    }
    return [];
  }

  Future<UserAchievementsResponse> getMyAchievements({String filter = 'all'}) async {
    return customRequest(
      endpoint: '/me/achievements?filter=$filter',
      fromJson: (json) => UserAchievementsResponse.fromJson(json),
    );
  }

  Future<UserAchievementsResponse> checkAndUnlockAchievements() async {
    return customRequest(
      endpoint: '/me/achievements/check',
      method: 'POST',
      fromJson: (json) => UserAchievementsResponse.fromJson(json),
    );
  }

  // MARK: - Messages API

  Future<List<Message>> getMessages({int page = 1, int perPage = 20}) async {
    final response = await _dio.get(
      baseURL + '/messages?per_page=$perPage&page=$page',
    );
    if (response.data is List) {
      return (response.data as List).map((m) => Message.fromJson(m)).toList();
    }
    return [];
  }

  Future<Message> sendMessage({
    required List<int> recipients,
    required String subject,
    required String message,
  }) async {
    return request(
      endpoint: '/messages',
      method: 'POST',
      body: {
        'recipients': recipients,
        'subject': subject,
        'message': message,
      },
      fromJson: (json) => Message.fromJson(json),
    );
  }

  // MARK: - Groups API

  Future<List<BPGroup>> getGroups({int page = 1, int perPage = 20}) async {
    final response = await _dio.get(
      baseURL + '/groups?per_page=$perPage&page=$page',
    );
    if (response.data is List) {
      return (response.data as List).map((g) => BPGroup.fromJson(g)).toList();
    }
    return [];
  }

  Future<BPGroup> getGroup(int groupId) async {
    return request(
      endpoint: '/groups/$groupId',
      fromJson: (json) => BPGroup.fromJson(json),
      authenticated: false,
    );
  }

  // MARK: - User/Members API

  Future<User> getCurrentUser() async {
    return request(
      endpoint: '/members/me',
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<User> getUser(int userId) async {
    return request(
      endpoint: '/members/$userId',
      fromJson: (json) => User.fromJson(json),
      authenticated: false,
    );
  }
}
