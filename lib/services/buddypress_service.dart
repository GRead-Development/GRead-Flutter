import 'dart:developer' as developer;
import 'api_service.dart';
import '../models/activity.dart';

class BuddyPressService {
  final ApiService _apiService = ApiService();

  Future<List<Activity>> getActivityFeed({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final endpoint = '/buddypress/v1/activity';
      final fullUrl = 'https://gread.fun/wp-json$endpoint';

      developer.log(
        'Fetching activity feed',
        name: 'BuddyPressService',
        time: DateTime.now(),
      );
      developer.log(
        'Full URL: $fullUrl?page=$page&per_page=$perPage',
        name: 'BuddyPressService',
      );

      final response = await _apiService.dio.get(
        endpoint,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      developer.log(
        'Activity feed response status: ${response.statusCode}',
        name: 'BuddyPressService',
      );
      developer.log(
        'Activity feed response data: ${response.data}',
        name: 'BuddyPressService',
      );

      if (response.data is Map<String, dynamic> && response.data['activities'] is List) {
        final activities = (response.data['activities'] as List)
            .map((item) => Activity.fromJson(item as Map<String, dynamic>))
            .toList();
        developer.log(
          'Parsed ${activities.length} activities from map response',
          name: 'BuddyPressService',
        );
        return activities;
      } else if (response.data is List) {
        final activities = (response.data as List)
            .map((item) => Activity.fromJson(item as Map<String, dynamic>))
            .toList();
        developer.log(
          'Parsed ${activities.length} activities from list response',
          name: 'BuddyPressService',
        );
        return activities;
      }

      developer.log(
        'Response was neither list nor map with activities key',
        name: 'BuddyPressService',
      );
      return [];
    } catch (e) {
      developer.log(
        'Error fetching activity feed: $e',
        name: 'BuddyPressService',
        error: e,
      );
      rethrow;
    }
  }

  Future<Activity?> getActivityById(int activityId) async {
    try {
      final endpoint = '/buddypress/v1/activity/$activityId';
      developer.log(
        'Fetching activity: $endpoint',
        name: 'BuddyPressService',
      );

      final response = await _apiService.dio.get(endpoint);

      developer.log(
        'Activity response status: ${response.statusCode}',
        name: 'BuddyPressService',
      );

      if (response.data != null) {
        return Activity.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      developer.log(
        'Error fetching activity: $e',
        name: 'BuddyPressService',
        error: e,
      );
      rethrow;
    }
  }
}
