class AppNotification {
  final int id;
  final int? itemId;
  final int? secondaryItemId;
  final int? userId;
  final String? componentName;
  final String? componentAction;
  final String? dateNotified;
  final bool? isNew;
  final String? content;
  final String? href;
  final int? totalCount;

  AppNotification({
    required this.id,
    this.itemId,
    this.secondaryItemId,
    this.userId,
    this.componentName,
    this.componentAction,
    this.dateNotified,
    this.isNew,
    this.content,
    this.href,
    this.totalCount,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Helper to parse id as int or string
    int parseId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Helper to parse boolean from various formats
    bool? parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) {
        return value == '1' || value.toLowerCase() == 'true';
      }
      if (value is int) return value == 1;
      return null;
    }

    return AppNotification(
      id: parseId(json['id']),
      itemId: json['item_id'] != null ? parseId(json['item_id']) : null,
      secondaryItemId: json['secondary_item_id'] != null
          ? parseId(json['secondary_item_id'])
          : null,
      userId: json['user_id'] != null ? parseId(json['user_id']) : null,
      componentName: json['component_name'],
      componentAction: json['component_action'],
      dateNotified: json['date_notified'],
      isNew: parseBool(json['is_new']),
      content: json['content'],
      href: json['href'],
      totalCount:
          json['total_count'] != null ? parseId(json['total_count']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'secondary_item_id': secondaryItemId,
      'user_id': userId,
      'component_name': componentName,
      'component_action': componentAction,
      'date_notified': dateNotified,
      'is_new': isNew,
      'content': content,
      'href': href,
      'total_count': totalCount,
    };
  }
}
