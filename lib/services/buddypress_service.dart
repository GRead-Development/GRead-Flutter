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

        // Filter to only show BuddyPress activities (not posts, etc.)
        final filtered = activities.where((activity) => activity.isBuddyPressActivity()).toList();
        developer.log(
          'After filtering: ${filtered.length} activities (removed ${activities.length - filtered.length})',
          name: 'BuddyPressService',
        );
        return filtered;
      } else if (response.data is List) {
        final activities = (response.data as List)
            .map((item) => Activity.fromJson(item as Map<String, dynamic>))
            .toList();
        developer.log(
          'Parsed ${activities.length} activities from list response',
          name: 'BuddyPressService',
        );

        // Filter to only show BuddyPress activities (not posts, etc.)
        final filtered = activities.where((activity) => activity.isBuddyPressActivity()).toList();
        developer.log(
          'After filtering: ${filtered.length} activities (removed ${activities.length - filtered.length})',
          name: 'BuddyPressService',
        );
        return filtered;
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
        // Handle both Map and List responses
        if (response.data is Map<String, dynamic>) {
          return Activity.fromJson(response.data as Map<String, dynamic>);
        } else if (response.data is List) {
          final list = response.data as List;
          if (list.isNotEmpty && list[0] is Map<String, dynamic>) {
            developer.log(
              'Activity response was a list, extracting first element',
              name: 'BuddyPressService',
            );
            return Activity.fromJson(list[0] as Map<String, dynamic>);
          }
        }
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

  /// Create a new activity post
  Future<Activity?> createActivityPost(String content) async {
    try {
      final endpoint = '/buddypress/v1/activity';

      print('🚀 Creating activity post');
      print('📝 Content: $content');

      final response = await _apiService.dio.post(
        endpoint,
        data: {
          'content': content,
        },
      );

      print('✅ Create activity response status: ${response.statusCode}');
      print('📦 Full response data: ${response.data}');

      if (response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        print('🔑 Response keys: ${responseData.keys.toList()}');

        // Check if the response contains success and activity_id
        if (responseData['success'] == true && responseData['activity_id'] != null) {
          final activityId = responseData['activity_id'] as int;
          print('🎯 Activity created with ID: $activityId, fetching full details...');

          // Fetch the full activity data
          final activity = await getActivityById(activityId);

          if (activity != null) {
            print('✨ Activity fetched - ID: ${activity.id}');
            print('📄 Content: ${activity.content}');
            print('🎨 ContentHtml: ${activity.contentHtml}');
            developer.log(
              'Activity created successfully with ID: ${activity.id}',
              name: 'BuddyPressService',
            );
            return activity;
          } else {
            print('⚠️ Activity ID $activityId returned but could not fetch full data');
            // Fallback: create activity object with what we have
            return Activity(
              id: activityId,
              component: 'activity',
              type: 'activity_update',
              userId: 0,
              userName: '',
              content: content,
              contentHtml: content,
              dateRecorded: DateTime.now(),
            );
          }
        }

        // Original logic for full response
        final activity = Activity.fromJson(responseData);
        print('✨ Activity created - ID: ${activity.id}');
        print('📄 Parsed Content: ${activity.content}');
        print('🎨 Parsed ContentHtml: ${activity.contentHtml}');

        developer.log(
          'Activity created successfully with ID: ${activity.id}',
          name: 'BuddyPressService',
        );
        return activity;
      }
      return null;
    } catch (e) {
      print('❌ Error creating activity: $e');
      developer.log(
        'Error creating activity: $e',
        name: 'BuddyPressService',
        error: e,
      );
      rethrow;
    }
  }
}
