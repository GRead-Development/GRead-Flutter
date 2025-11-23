import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';
import '../providers/moderation_provider.dart';
import '../models/activity.dart';
import '../utils/html_utils.dart';
import '../widgets/compose_post_dialog.dart';

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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          developer.log('Compose post FAB tapped', name: 'ActivityFeedScreen');
          showComposePostDialog(context);
        },
        tooltip: 'Create Post',
        child: const Icon(Icons.add),
      ),
      body: Consumer<ActivityProvider>(
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
      ),
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
    try {
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
    } catch (e) {
      developer.log(
        'Error calculating time ago: $e',
        name: 'ActivityCard',
        error: e,
      );
      return 'unknown time';
    }
  }

  String _getDisplayContent() {
    try {
      // Prefer HTML content with proper decoding
      if (activity.contentHtml != null && activity.contentHtml!.isNotEmpty) {
        return HtmlUtils.htmlToPlainText(activity.contentHtml);
      }
      // Fallback to plain text content
      if (activity.content.isNotEmpty) {
        return activity.content;
      }
      return '(No content)';
    } catch (e) {
      developer.log(
        'Error getting display content: $e',
        name: 'ActivityCard',
        error: e,
      );
      return '(Content unavailable)';
    }
  }

  String _getActivityLabel() {
    try {
      // Format component and type for display
      final componentLabel = activity.component.isNotEmpty
          ? activity.component
              .replaceAll('_', ' ')
              .split(' ')
              .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
              .join(' ')
          : 'Activity';

      final typeLabel = activity.type.isNotEmpty
          ? activity.type
              .replaceAll('_', ' ')
              .split(' ')
              .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
              .join(' ')
          : 'Update';

      return '$componentLabel • $typeLabel';
    } catch (e) {
      developer.log(
        'Error formatting activity label: $e',
        name: 'ActivityCard',
        error: e,
      );
      return 'Activity • Update';
    }
  }

  void _handleMenuAction(BuildContext context, String action, Activity activity) {
    switch (action) {
      case 'block':
        _showBlockDialog(context, activity);
        break;
      case 'mute':
        _showMuteDialog(context, activity);
        break;
      case 'report':
        _showReportDialog(context, activity);
        break;
    }
  }

  Future<void> _showBlockDialog(BuildContext context, Activity activity) async {
    final username = activity.displayName ?? activity.userName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User?'),
        content: Text(
          'Are you sure you want to block $username?\n\nThey won\'t be able to see your posts and you won\'t see theirs.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final moderationProvider = context.read<ModerationProvider>();
        await moderationProvider.blockUser(activity.userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Blocked $username')),
          );
          // Refresh the feed
          context.read<ActivityProvider>().refreshActivityFeed();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to block user: $e')),
          );
        }
      }
    }
  }

  Future<void> _showMuteDialog(BuildContext context, Activity activity) async {
    final username = activity.displayName ?? activity.userName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mute User?'),
        content: Text(
          'Are you sure you want to mute $username?\n\nYou won\'t see their posts, but they can still see yours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mute'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final moderationProvider = context.read<ModerationProvider>();
        await moderationProvider.muteUser(activity.userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Muted $username')),
          );
          // Refresh the feed
          context.read<ActivityProvider>().refreshActivityFeed();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to mute user: $e')),
          );
        }
      }
    }
  }

  Future<void> _showReportDialog(BuildContext context, Activity activity) async {
    final username = activity.displayName ?? activity.userName;
    String selectedReason = 'Spam';
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Report User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Report $username for:'),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Spam', child: Text('Spam')),
                    DropdownMenuItem(value: 'Harassment', child: Text('Harassment')),
                    DropdownMenuItem(value: 'Inappropriate Content', child: Text('Inappropriate Content')),
                    DropdownMenuItem(value: 'Hate Speech', child: Text('Hate Speech')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedReason = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Additional details (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final moderationProvider = context.read<ModerationProvider>();
        await moderationProvider.reportUser(
          userId: activity.userId,
          reason: selectedReason,
          additionalInfo: reasonController.text.isNotEmpty ? reasonController.text : null,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reported $username')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to report user: $e')),
          );
        }
      }
    }

    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
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
                          activity.displayName?.isNotEmpty == true
                              ? activity.displayName!
                              : (activity.userName.isNotEmpty ? activity.userName : 'Unknown'),
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
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) => _handleMenuAction(context, value, activity),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(Icons.block, size: 20),
                            SizedBox(width: 12),
                            Text('Block User'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'mute',
                        child: Row(
                          children: [
                            Icon(Icons.volume_off, size: 20),
                            SizedBox(width: 12),
                            Text('Mute User'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag, size: 20),
                            SizedBox(width: 12),
                            Text('Report User'),
                          ],
                        ),
                      ),
                    ],
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
    } catch (e, stackTrace) {
      developer.log(
        'Error building activity card: $e',
        name: 'ActivityCard',
        error: e,
        stackTrace: stackTrace,
      );
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Error loading activity'),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }
  }
}
