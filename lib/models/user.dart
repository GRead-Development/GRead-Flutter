class User {
  final int id;
  final String name;
  final String? link;
  final String? userLogin;
  final List<String>? memberTypes;
  final String? registeredDate;
  final AvatarUrls? avatarUrls;

  User({
    required this.id,
    required this.name,
    this.link,
    this.userLogin,
    this.memberTypes,
    this.registeredDate,
    this.avatarUrls,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle id as either Int or String
    int userId;
    if (json['id'] is int) {
      userId = json['id'];
    } else if (json['id'] is String) {
      userId = int.tryParse(json['id']) ?? 0;
    } else {
      userId = 0;
    }

    return User(
      id: userId,
      name: json['name'] ?? '',
      link: json['link'],
      userLogin: json['user_login'],
      memberTypes: json['member_types'] != null
          ? List<String>.from(json['member_types'])
          : null,
      registeredDate: json['registered_date'],
      avatarUrls: json['avatar_urls'] != null
          ? AvatarUrls.fromJson(json['avatar_urls'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'link': link,
      'user_login': userLogin,
      'member_types': memberTypes,
      'registered_date': registeredDate,
      'avatar_urls': avatarUrls?.toJson(),
    };
  }
}

class AvatarUrls {
  final String? full;
  final String? thumb;

  AvatarUrls({this.full, this.thumb});

  factory AvatarUrls.fromJson(Map<String, dynamic> json) {
    return AvatarUrls(
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
