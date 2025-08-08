
class UserProfile {
  final String id;
  final String name;
  final String gender;
  final DateTime birthday;
  final bool notificationsEnabled;
  final String? profilePhotoUrl;
  final List<String>? additionalPhotos;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthday,
    this.notificationsEnabled = false,
    this.profilePhotoUrl,
    this.additionalPhotos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      birthday: DateTime.parse(json['birthday']),
      notificationsEnabled: json['notifications_enabled'] ?? false,
      profilePhotoUrl: json['profile_photo_url'],
      additionalPhotos: json['additional_photos'] != null 
          ? List<String>.from(json['additional_photos'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthday': birthday.toIso8601String(),
      'notifications_enabled': notificationsEnabled,
      'profile_photo_url': profilePhotoUrl,
      'additional_photos': additionalPhotos,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
