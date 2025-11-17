class Message {
  final int id;
  final MessageSubject? subject;
  final MessageContent? message;
  final String? dateSent;
  final int? unreadCount;
  final List<int>? senderIds;
  final List<Recipient>? recipients;

  Message({
    required this.id,
    this.subject,
    this.message,
    this.dateSent,
    this.unreadCount,
    this.senderIds,
    this.recipients,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      subject: json['subject'] != null
          ? MessageSubject.fromJson(json['subject'])
          : null,
      message: json['message'] != null
          ? MessageContent.fromJson(json['message'])
          : null,
      dateSent: json['date_sent'],
      unreadCount: json['unread_count'],
      senderIds: json['sender_ids'] != null
          ? List<int>.from(json['sender_ids'])
          : null,
      recipients: json['recipients'] != null
          ? (json['recipients'] as List)
              .map((r) => Recipient.fromJson(r))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject?.toJson(),
      'message': message?.toJson(),
      'date_sent': dateSent,
      'unread_count': unreadCount,
      'sender_ids': senderIds,
      'recipients': recipients?.map((r) => r.toJson()).toList(),
    };
  }
}

class MessageSubject {
  final String? rendered;
  final String? raw;

  MessageSubject({this.rendered, this.raw});

  factory MessageSubject.fromJson(Map<String, dynamic> json) {
    return MessageSubject(
      rendered: json['rendered'],
      raw: json['raw'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rendered': rendered,
      'raw': raw,
    };
  }
}

class MessageContent {
  final String? rendered;
  final String? raw;

  MessageContent({this.rendered, this.raw});

  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      rendered: json['rendered'],
      raw: json['raw'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rendered': rendered,
      'raw': raw,
    };
  }
}

class Recipient {
  final int? userId;
  final String? userName;
  final bool? isDeleted;

  Recipient({this.userId, this.userName, this.isDeleted});

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      userId: json['user_id'],
      userName: json['user_name'],
      isDeleted: json['is_deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'is_deleted': isDeleted,
    };
  }
}
