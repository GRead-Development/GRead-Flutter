class Activity {
  final int id;
  final int? userId;
  final String? component;
  final String? type;
  final String? action;
  final String? content;
  final String? primaryLink;
  final int? itemId;
  final int? secondaryItemId;
  final String? dateRecorded;
  final int? hideSitewide;
  final int? isSpam;
  final String? userNicename;
  final String? userLogin;
  final String? displayName;
  final String? userFullname;
  final String? userAvatar;
  final int? parent;
  List<Activity>? children;

  Activity({
    required this.id,
    this.userId,
    this.component,
    this.type,
    this.action,
    this.content,
    this.primaryLink,
    this.itemId,
    this.secondaryItemId,
    this.dateRecorded,
    this.hideSitewide,
    this.isSpam,
    this.userNicename,
    this.userLogin,
    this.displayName,
    this.userFullname,
    this.userAvatar,
    this.parent,
    this.children,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse user ID
    int? parseUserId() {
      if (json['userId'] is int) return json['userId'];
      if (json['userId'] is String) return int.tryParse(json['userId']);
      if (json['user_id'] is int) return json['user_id'];
      if (json['user_id'] is String) return int.tryParse(json['user_id']);
      return null;
    }

    // Parse content - might be wrapped in an object or plain string
    String? parseContent() {
      final contentField = json['content'];
      if (contentField is String) return contentField;
      if (contentField is Map) {
        return contentField['rendered'] ?? contentField['raw'];
      }
      return null;
    }

    return Activity(
      id: json['id'] ?? 0,
      userId: parseUserId(),
      component: json['component'],
      type: json['type'],
      action: json['action'],
      content: parseContent(),
      primaryLink: json['primaryLink'] ?? json['primary_link'],
      itemId: json['itemId'] ?? json['item_id'],
      secondaryItemId: json['secondaryItemId'] ?? json['secondary_item_id'],
      dateRecorded: json['dateRecorded'] ?? json['date_recorded'],
      hideSitewide: json['hideSitewide'] ?? json['hide_sitewide'],
      isSpam: json['isSpam'] ?? json['is_spam'],
      userNicename: json['userNicename'] ?? json['user_nicename'],
      userLogin: json['userLogin'] ?? json['user_login'],
      displayName: json['displayName'] ?? json['display_name'],
      userFullname: json['userFullname'] ?? json['user_fullname'],
      userAvatar: json['userAvatar'] ?? json['user_avatar'],
      parent: json['parent'],
      children: json['children'] != null
          ? (json['children'] as List).map((c) => Activity.fromJson(c)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'component': component,
      'type': type,
      'action': action,
      'content': content,
      'primary_link': primaryLink,
      'item_id': itemId,
      'secondary_item_id': secondaryItemId,
      'date_recorded': dateRecorded,
      'hide_sitewide': hideSitewide,
      'is_spam': isSpam,
      'user_nicename': userNicename,
      'user_login': userLogin,
      'display_name': displayName,
      'user_fullname': userFullname,
      'user_avatar': userAvatar,
      'parent': parent,
      'children': children?.map((c) => c.toJson()).toList(),
    };
  }

  // Computed property for getting the best available name
  String get bestUserName {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    } else if (userFullname != null && userFullname!.isNotEmpty) {
      return userFullname!;
    } else if (userLogin != null && userLogin!.isNotEmpty) {
      return userLogin!;
    } else if (userId != null) {
      return 'User $userId';
    } else {
      return 'Unknown User';
    }
  }

  // Computed property for avatar URL
  String get avatarURL {
    // If we have a user_avatar field from API, use it
    if (userAvatar != null && userAvatar!.isNotEmpty) {
      return userAvatar!;
    }

    // Otherwise construct BuddyPress members avatar URL
    if (userId != null) {
      return 'https://gread.fun/wp-content/uploads/avatars/$userId/avatar-bpfull.jpg';
    }

    // Final fallback - use a generic avatar
    return 'https://www.gravatar.com/avatar/default?d=mp&s=150';
  }
}

class ActivityResponse {
  final List<Activity> activities;
  final int? total;
  final bool? hasMoreItems;

  ActivityResponse({
    required this.activities,
    this.total,
    this.hasMoreItems,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      activities: json['activities'] != null
          ? (json['activities'] as List).map((a) => Activity.fromJson(a)).toList()
          : [],
      total: json['total'],
      hasMoreItems: json['has_more_items'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activities': activities.map((a) => a.toJson()).toList(),
      'total': total,
      'has_more_items': hasMoreItems,
    };
  }
}

class ActivityFeedResponse {
  final bool success;
  final List<Activity> activities;
  final int? totalCount;
  final bool? hasMorePages;

  ActivityFeedResponse({
    required this.success,
    required this.activities,
    this.totalCount,
    this.hasMorePages,
  });

  factory ActivityFeedResponse.fromJson(Map<String, dynamic> json) {
    return ActivityFeedResponse(
      success: json['success'] ?? true,
      activities: json['activities'] != null
          ? (json['activities'] as List).map((a) => Activity.fromJson(a)).toList()
          : [],
      totalCount: json['total_count'],
      hasMorePages: json['has_more_pages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'activities': activities.map((a) => a.toJson()).toList(),
      'total_count': totalCount,
      'has_more_pages': hasMorePages,
    };
  }
}
