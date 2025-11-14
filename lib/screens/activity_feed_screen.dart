import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';
import '../utils/html_utils.dart';

class ActivityFeedScreen extends StatefulWidget {
  const ActivityFeedScreen({super.key});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    developer.log('ActivityFeedScreen initState', name: 'ActivityFeedScreen');
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load initial activities when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('ActivityFeedScreen post-frame callback - triggering fetch', name: 'ActivityFeedScreen');
      context.read<ActivityProvider>().fetchActivityFeed();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final provider = context.read<ActivityProvider>();
      if (provider.hasMore && !provider.loading) {
        provider.fetchActivityFeed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        developer.log(
          'ActivityFeedScreen build - Activities: ${activityProvider.activities.length}, Loading: ${activityProvider.loading}, Error: ${activityProvider.error}',
          name: 'ActivityFeedScreen',
        );

        if (activityProvider.activities.isEmpty && activityProvider.loading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading activities...'),
              ],
            ),
          );
        }

        if (activityProvider.error != null && activityProvider.activities.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to Load Activities'),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        activityProvider.error!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      developer.log('User tapped retry', name: 'ActivityFeedScreen');
                      activityProvider.refreshActivityFeed();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (activityProvider.activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.feed, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No activities yet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => activityProvider.refreshActivityFeed(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => activityProvider.refreshActivityFeed(),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: activityProvider.activities.length + (activityProvider.loading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == activityProvider.activities.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              final activity = activityProvider.activities[index];
              return ActivityCard(activity: activity);
            },
          ),
        );
      },
    );
  }
}

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({
    super.key,
    required this.activity,
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  String _getDisplayContent() {
    // Prefer HTML content with proper decoding
    if (activity.contentHtml != null && activity.contentHtml!.isNotEmpty) {
      return HtmlUtils.htmlToPlainText(activity.contentHtml);
    }
    // Fallback to plain text content
    return activity.content;
  }

  String _getActivityLabel() {
    // Format component and type for display
    final componentLabel = activity.component
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    final typeLabel = activity.type
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return '$componentLabel • $typeLabel';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (activity.avatar != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(activity.avatar!),
                    radius: 24,
                  )
                else
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      activity.userName.isNotEmpty ? activity.userName[0].toUpperCase() : '?',
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.displayName ?? activity.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _getTimeAgo(activity.dateRecorded),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getDisplayContent(),
              style: const TextStyle(fontSize: 14),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _getActivityLabel(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
