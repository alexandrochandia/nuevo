
class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final String category; // 'bible_study', 'prayer', 'youth', 'men', 'women'
  final List<String> tags;
  final String leaderId;
  final String leaderName;
  final String leaderAvatar;
  final int membersCount;
  final int maxMembers;
  final bool isPrivate;
  final bool requiresApproval;
  final DateTime createdAt;
  final DateTime? nextMeeting;
  final String? meetingLocation;
  final String? meetingLink;
  final List<StudyGroupMember>? members;
  final String? currentStudy; // Libro o tema actual
  final int lessonsCompleted;
  final int totalLessons;

  StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.category,
    required this.tags,
    required this.leaderId,
    required this.leaderName,
    required this.leaderAvatar,
    required this.membersCount,
    this.maxMembers = 50,
    this.isPrivate = false,
    this.requiresApproval = false,
    required this.createdAt,
    this.nextMeeting,
    this.meetingLocation,
    this.meetingLink,
    this.members,
    this.currentStudy,
    this.lessonsCompleted = 0,
    this.totalLessons = 1,
  });

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coverImage: json['cover_image'] ?? '',
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      leaderId: json['leader_id'],
      leaderName: json['leader_name'],
      leaderAvatar: json['leader_avatar'] ?? '',
      membersCount: json['members_count'] ?? 0,
      maxMembers: json['max_members'] ?? 50,
      isPrivate: json['is_private'] ?? false,
      requiresApproval: json['requires_approval'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      nextMeeting: json['next_meeting'] != null 
          ? DateTime.parse(json['next_meeting']) 
          : null,
      meetingLocation: json['meeting_location'],
      meetingLink: json['meeting_link'],
      currentStudy: json['current_study'],
      lessonsCompleted: json['lessons_completed'] ?? 0,
      totalLessons: json['total_lessons'] ?? 1,
    );
  }

  double get progress => totalLessons > 0 ? lessonsCompleted / totalLessons : 0.0;

  bool get isFull => membersCount >= maxMembers;

  String get categoryDisplayName {
    switch (category) {
      case 'bible_study': return 'Estudio Bíblico';
      case 'prayer': return 'Oración';
      case 'youth': return 'Jóvenes';
      case 'men': return 'Hombres';
      case 'women': return 'Mujeres';
      default: return 'General';
    }
  }
}

class StudyGroupMember {
  final String userId;
  final String userName;
  final String userAvatar;
  final String role; // 'leader', 'co_leader', 'member'
  final DateTime joinedAt;
  final bool isVerified;

  StudyGroupMember({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.role,
    required this.joinedAt,
    this.isVerified = false,
  });

  factory StudyGroupMember.fromJson(Map<String, dynamic> json) {
    return StudyGroupMember(
      userId: json['user_id'],
      userName: json['user_name'],
      userAvatar: json['user_avatar'] ?? '',
      role: json['role'],
      joinedAt: DateTime.parse(json['joined_at']),
      isVerified: json['is_verified'] ?? false,
    );
  }
}
