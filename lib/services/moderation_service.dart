import 'dart:developer' as developer;
import 'api_service.dart';

class ModerationService {
  final ApiService _apiService = ApiService();

  //Blocking a user
  Future<bool> blockUser(int userId) async{
    try {
      final endpoint = '/gread/v1/user/block';

      developer.log('Blocking user: $userId', name: 'ModerationService',);
    
      final response = await _apiService.dio.post(
      endpoint, data: {'user_id': userId,},
      );

      developer.log('Block user response: ${response.statusCode}',
      name: 'ModerationService');

      return response.statusCode == 200;
    }
    catch (e) {developer.log('Error blocking user: $e', name: 'ModerationService', error: e,);
    rethrow;

    }
    
  }

  Future<bool> unblockUser(int userId) async {
    try {
      final endpoint = '/gread/v1/user/unblock';

      developer.log( 
        'Unblocking user: $userId',
        name:   'ModerationService',
      );
      
      final response = await _apiService.dio.post(
        endpoint,
        data: {
          'user_id': userId,
        },
      );

      developer.log(
        'Unblock user response: ${response.statusCode}',
        name: 'ModerationService',

      );
      return response.statusCode == 200;

    } catch (e) {developer.log(
      'Error unblocking user: $e',
      name: 'ModerationService',
      error: e,
      );
      rethrow;
    }
  }
  
  //Report a user for violations
  Future<bool> reportUser({
    required int userId,
    required String reason,
    String? additionalInfo,
  }) async {
    try{
      final endpoint = '/gread/v1/user/report';

      developer.log(
        'Reporting user: $userId - Reason: $reason',
        name: 'ModerationService',
      );

      final response = await _apiService.dio.post(
        endpoint,
        data: {
          'user_id': userId,
          'reason': reason,
          if (additionalInfo != null) 'additional_info': additionalInfo,

        },
      );
      developer.log(
        'Report user response: ${response.statusCode}',
        name: 'ModerationService',
      );
      return response.statusCode == 200;
    }
    catch (e) {
      developer.log(
        'Error reporting user: $e',
        name: 'ModerationService',
        error: e,
      );
      rethrow;
    }
  }

  Future<List<int>> getBlockedUsers() async {
    try {
      final endpoint = '/gread/v1/user/blocked_list';

      developer.log(
        'Fetching blocked users list',
        name: 'ModerationService',
      );

      final response = await _apiService.dio.get(endpoint);

      developer.log(
        'Blocked users response: ${response.statusCode}',
        name: 'ModerationService',
      );

      if (response.data is List) {
        return (response.data as List).map((id) => id as int).toList();
      }
      else if (response.data is Map && response.data['blocked_users'] is List){
        return (response.data['blocked_users'] as List)
          .map((id) => id as int)
          .toList();
      }
      return [];
    } catch (e){
      developer.log('Error fetching blocked users: $e', name: 'ModerationService', error:e,);

      rethrow;
    }
  }

  // Muting a user
  Future<bool> muteUser(int userId) async {
    try {
      final endpoint = '/gread/v1/user/mute';

      developer.log(
        'Muting user: $userId',
        name: 'ModerationService',
      );

      final response = await _apiService.dio.post(
        endpoint,
        data: {
          'user_id': userId,
        },
      );

      developer.log(
        'Mute user response: ${response.statusCode}',
        name: 'ModerationService',
      );

      return response.statusCode == 200;
    } catch (e) {
      developer.log(
        'Error muting user: $e',
        name: 'ModerationService',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> unmuteUser(int userId) async {
    try {
      final endpoint = '/gread/v1/user/unmute';

      developer.log(
        'Unmuting user: $userId',
        name: 'ModerationService',
      );

      final response = await _apiService.dio.post(
        endpoint,
        data: {
          'user_id': userId,
        },
      );

      developer.log(
        'Unmute user response: ${response.statusCode}',
        name: 'ModerationService',
      );

      return response.statusCode == 200;
    } catch (e) {
      developer.log(
        'Error unmuting user: $e',
        name: 'ModerationService',
        error: e,
      );
      rethrow;
    }
  }

  Future<List<int>> getMutedUsers() async {
    try {
      final endpoint = '/gread/v1/user/muted_list';

      developer.log(
        'Fetching muted users list',
        name: 'ModerationService',
      );

      final response = await _apiService.dio.get(endpoint);

      developer.log(
        'Muted users response: ${response.statusCode}',
        name: 'ModerationService',
      );

      if (response.data is List) {
        return (response.data as List).map((id) => id as int).toList();
      } else if (response.data is Map && response.data['muted_users'] is List) {
        return (response.data['muted_users'] as List)
            .map((id) => id as int)
            .toList();
      }
      return [];
    } catch (e) {
      developer.log(
        'Error fetching muted users: $e',
        name: 'ModerationService',
        error: e,
      );
      rethrow;
    }
  }

}
