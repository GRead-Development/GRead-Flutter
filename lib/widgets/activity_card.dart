import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/activity.dart';
import '../utils/string_extensions.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onRefresh;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = activity.content ?? '';
    final cleanContent = content.decodingHTMLEntities.stripHTML();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage: activity.userAvatar != null
                      ? CachedNetworkImageProvider(activity.avatarURL)
                      : null,
                  child: activity.userAvatar == null
                      ? Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.bestUserName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (activity.dateRecorded != null)
                        Text(
                          activity.dateRecorded!.toRelativeTime(),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                if (activity.type != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity.type!.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            if (cleanContent.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                cleanContent,
                style: const TextStyle(fontSize: 14),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Comment button row
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Open comment dialog
                  },
                  icon: const Icon(Icons.comment_outlined, size: 18),
                  label: const Text('Comment'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
