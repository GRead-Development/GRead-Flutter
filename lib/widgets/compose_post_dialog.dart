import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';

class ComposePostDialog extends StatefulWidget {
  final ActivityProvider activityProvider;

  const ComposePostDialog({
    super.key,
    required this.activityProvider,
  });

  @override
  State<ComposePostDialog> createState() => _ComposePostDialogState();
}

class _ComposePostDialogState extends State<ComposePostDialog> {
  final _contentController = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SizedBox(
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create a Post',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 5,
                minLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _posting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _posting ? null : _postContent,
                    icon: _posting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, size: 18),
                    label: Text(_posting ? 'Posting...' : 'Post'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _postContent() async {
    final content = _contentController.text.trim();

    developer.log(
      'Post button pressed - Content length: ${content.length}',
      name: 'ComposePostDialog',
    );

    if (content.isEmpty) {
      developer.log(
        'Content is empty, showing error',
        name: 'ComposePostDialog',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    developer.log(
      'Posting content from dialog',
      name: 'ComposePostDialog',
    );

    setState(() => _posting = true);

    try {
      developer.log('Using ActivityProvider from widget', name: 'ComposePostDialog');
      final provider = widget.activityProvider;

      developer.log('Calling provider.createPost()', name: 'ComposePostDialog');
      final success = await provider.createPost(content);

      developer.log(
        'provider.createPost() returned: $success',
        name: 'ComposePostDialog',
      );

      if (mounted) {
        setState(() => _posting = false);

        if (success) {
          developer.log(
            'Post created successfully, closing dialog',
            name: 'ComposePostDialog',
          );
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post created successfully!')),
            );
          }
        } else {
          developer.log(
            'Post creation failed - Error: ${provider.error}',
            name: 'ComposePostDialog',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.error ?? 'Failed to create post')),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        'Exception in post dialog: $e',
        name: 'ComposePostDialog',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        setState(() => _posting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}

/// Helper function to show the compose dialog
Future<void> showComposePostDialog(BuildContext context) async {
  developer.log(
    'showComposePostDialog called',
    name: 'ComposePostDialog',
  );

  try {
    final provider = context.read<ActivityProvider>();
    developer.log(
      'Successfully read ActivityProvider from context',
      name: 'ComposePostDialog',
    );

    return showDialog(
      context: context,
      builder: (dialogContext) {
        developer.log(
          'Dialog builder called, creating ComposePostDialog',
          name: 'ComposePostDialog',
        );
        return ComposePostDialog(activityProvider: provider);
      },
    );
  } catch (e) {
    developer.log(
      'Error reading ActivityProvider: $e',
      name: 'ComposePostDialog',
      error: e,
    );
    // Show error to user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not initialize post dialog - $e')),
      );
    }
  }
}
