import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/buddypress_service.dart';

class ActivityProvider extends ChangeNotifier {
  final BuddyPressService _buddypress = BuddyPressService();

  List<Activity> _activities = [];
  bool _loading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  List<Activity> get activities => _activities;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> fetchActivityFeed({bool refresh = false}) async {
    if (refresh) {
      developer.log(
        'Refreshing activity feed (clearing existing activities)',
        name: 'ActivityProvider',
      );
      _activities = [];
      _currentPage = 1;
      _hasMore = true;
    }

    if (_loading) {
      developer.log(
        'Already loading, skipping fetch',
        name: 'ActivityProvider',
      );
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    developer.log(
      'Fetching page $_currentPage of activity feed',
      name: 'ActivityProvider',
    );

    try {
      final newActivities = await _buddypress.getActivityFeed(
        page: _currentPage,
        perPage: 20,
      );

      developer.log(
        'Received ${newActivities.length} activities',
        name: 'ActivityProvider',
      );

      if (newActivities.isEmpty) {
        _hasMore = false;
        developer.log(
          'No more activities available',
          name: 'ActivityProvider',
        );
      } else {
        _activities.addAll(newActivities);
        _currentPage++;
        developer.log(
          'Added activities, now have ${_activities.length} total',
          name: 'ActivityProvider',
        );
      }

      _error = null;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Failed to load activity feed: $e';
      developer.log(
        'Error fetching activity feed: $e',
        name: 'ActivityProvider',
        error: e,
        stackTrace: stackTrace,
      );
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
      developer.log(
        'Fetch complete. Loading: $_loading, Error: $_error',
        name: 'ActivityProvider',
      );
    }
  }

  Future<void> refreshActivityFeed() async {
    developer.log(
      'User requested refresh',
      name: 'ActivityProvider',
    );
    await fetchActivityFeed(refresh: true);
  }
}
