class UserModel {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String imageUrl;
  final String city;
  final List<String> interests;
  final DateTime createdAt;
  final bool isOnline;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final bool isActive;
  final DateTime? lastSeen;
  final DateTime updatedAt;
  final String? profilePicture;
  final String? location;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.imageUrl,
    required this.city,
    required this.interests,
    required this.createdAt,
    required this.isOnline,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.isActive = true,
    this.lastSeen,
    required this.updatedAt,
    this.profilePicture,
    this.location,
    this.isVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      bio: json['bio'] as String,
      imageUrl: json['image_url'] as String,
      city: json['city'] as String,
      interests: List<String>.from(json['interests'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      isOnline: json['is_online'] as bool? ?? false,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      gender: json['gender'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      lastSeen: json['last_seen'] != null ? DateTime.parse(json['last_seen']) : null,
      updatedAt: DateTime.parse(json['updated_at']),
      profilePicture: json['profile_picture'] as String?,
      location: json['location'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'bio': bio,
      'image_url': imageUrl,
      'city': city,
      'interests': interests,
      'created_at': createdAt.toIso8601String(),
      'is_online': isOnline,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'is_active': isActive,
      'last_seen': lastSeen?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'profile_picture': profilePicture,
      'location': location,
      'is_verified': isVerified,
    };
  }

  String get displayAge => '$age años';
  String get displayLocation => city;
  String get displayInterests => interests.join(', ');

  bool get isNewUser {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays <= 7; // New user if joined within last week
  }
}