class BPGroup {
  final int id;
  final int? creatorId;
  final String name;
  final String? link;
  final GroupDescription? description;
  final String? slug;
  final String? status;
  final String? dateCreated;
  final int? parentId;
  final int? enableForum;
  final int? totalMemberCount;
  final GroupAvatarUrls? avatarUrls;
  final String? args;

  BPGroup({
    required this.id,
    this.creatorId,
    required this.name,
    this.link,
    this.description,
    this.slug,
    this.status,
    this.dateCreated,
    this.parentId,
    this.enableForum,
    this.totalMemberCount,
    this.avatarUrls,
    this.args,
  });

  factory BPGroup.fromJson(Map<String, dynamic> json) {
    return BPGroup(
      id: json['id'] ?? 0,
      creatorId: json['creator_id'],
      name: json['name'] ?? '',
      link: json['link'],
      description: json['description'] != null
          ? GroupDescription.fromJson(json['description'])
          : null,
      slug: json['slug'],
      status: json['status'],
      dateCreated: json['date_created'],
      parentId: json['parent_id'],
      enableForum: json['enable_forum'],
      totalMemberCount: json['total_member_count'],
      avatarUrls: json['avatar_urls'] != null
          ? GroupAvatarUrls.fromJson(json['avatar_urls'])
          : null,
      args: json['args'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'name': name,
      'link': link,
      'description': description?.toJson(),
      'slug': slug,
      'status': status,
      'date_created': dateCreated,
      'parent_id': parentId,
      'enable_forum': enableForum,
      'total_member_count': totalMemberCount,
      'avatar_urls': avatarUrls?.toJson(),
      'args': args,
    };
  }
}

class GroupDescription {
  final String? rendered;
  final String? raw;

  GroupDescription({this.rendered, this.raw});

  factory GroupDescription.fromJson(dynamic json) {
    if (json is String) {
      return GroupDescription(rendered: json, raw: json);
    } else if (json is Map<String, dynamic>) {
      return GroupDescription(
        rendered: json['rendered'],
        raw: json['raw'],
      );
    }
    return GroupDescription();
  }

  Map<String, dynamic> toJson() {
    return {
      'rendered': rendered,
      'raw': raw,
    };
  }
}

class GroupAvatarUrls {
  final String? full;
  final String? thumb;

  GroupAvatarUrls({this.full, this.thumb});

  factory GroupAvatarUrls.fromJson(Map<String, dynamic> json) {
    return GroupAvatarUrls(
      full: json['full'],
      thumb: json['thumb'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full': full,
      'thumb': thumb,
    };
  }
}
