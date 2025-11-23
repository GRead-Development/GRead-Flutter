import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../services/moderation_service.dart';

class ModerationProvider extends ChangeNotifier {
  final ModerationService _moderationService = ModerationService();
  List<int> _blockedUsers = [];
  List<int> _mutedUsers = [];
  bool _loading = false;

  List<int> get blockedUsers => _blockedUsers;
  List<int> get mutedUsers => _mutedUsers;
  bool get loading => _loading;

  Future<void> loadBlockedUsers() async {
    try {
      _loading = true;
      notifyListeners();

      _blockedUsers = await _moderationService.getBlockedUsers();
      developer.log(
        'Loaded ${_blockedUsers.length} blocked users',
        name: 'ModerationProvider',
      );

      _loading = false;
      notifyListeners();
    } catch (e) {
      developer.log(
        'Error loading blocked users: $e',
        name: 'ModerationProvider',
        error: e,
      );
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadMutedUsers() async {
    try {
      _loading = true;
      notifyListeners();

      _mutedUsers = await _moderationService.getMutedUsers();
      developer.log(
        'Loaded ${_mutedUsers.length} muted users',
        name: 'ModerationProvider',
      );

      _loading = false;
      notifyListeners();
    } catch (e) {
      developer.log(
        'Error loading muted users: $e',
        name: 'ModerationProvider',
        error: e,
      );
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> blockUser(int userId) async {
    try {
      final success = await _moderationService.blockUser(userId);
      if (success) {
        _blockedUsers.add(userId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      developer.log(
        'Error blocking user: $e',
        name: 'ModerationProvider',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> unblockUser(int userId) async {
    try {
      final success = await _moderationService.unblockUser(userId);
      if (success) {
        _blockedUsers.remove(userId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      developer.log(
        'Error unblocking user: $e',
        name: 'ModerationProvider',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> muteUser(int userId) async {
    try {
      final success = await _moderationService.muteUser(userId);
      if (success) {
        _mutedUsers.add(userId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      developer.log(
        'Error muting user: $e',
        name: 'ModerationProvider',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> unmuteUser(int userId) async {
    try {
      final success = await _moderationService.unmuteUser(userId);
      if (success) {
        _mutedUsers.remove(userId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      developer.log(
        'Error unmuting user: $e',
        name: 'ModerationProvider',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> reportUser({
    required int userId,
    required String reason,
    String? additionalInfo,
  }) async {
    try {
      return await _moderationService.reportUser(
        userId: userId,
        reason: reason,
        additionalInfo: additionalInfo,
      );
    } catch (e) {
      developer.log(
        'Error reporting user: $e',
        name: 'ModerationProvider',
        error: e,
      );
      rethrow;
    }
  }

  bool isUserBlocked(int userId) {
    return _blockedUsers.contains(userId);
  }

  bool isUserMuted(int userId) {
    return _mutedUsers.contains(userId);
  }
}
