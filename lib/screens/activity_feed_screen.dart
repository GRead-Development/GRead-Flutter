import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/activity.dart';
import '../services/api_manager.dart';
import '../utils/string_extensions.dart';
import '../widgets/activity_card.dart';
import '../widgets/new_post_dialog.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  final List<Activity> _activities = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await APIManager.shared.getActivityFeed(
        page: _page,
        perPage: 20,
      );

      if (mounted) {
        setState(() {
          if (_page == 1) {
            _activities.clear();
          }
          _activities.addAll(response.activities);
          _hasMore = response.activities.length >= 20;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading activities: $e');
    }
  }

  Future<void> _refresh() async {
    _page = 1;
    _hasMore = true;
    await _loadActivities();
  }

  Future<void> _showNewPostDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const NewPostDialog(),
    );

    if (result == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _showNewPostDialog,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _activities.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _activities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No activity yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (auth.isAuthenticated)
                          TextButton(
                            onPressed: _showNewPostDialog,
                            child: const Text('Be the first to post!'),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _activities.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _activities.length) {
                        if (!_isLoading) {
                          _page++;
                          _loadActivities();
                        }
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final activity = _activities[index];
                      return ActivityCard(
                        activity: activity,
                        onRefresh: _refresh,
                      );
                    },
                  ),
      ),
    );
  }
}

