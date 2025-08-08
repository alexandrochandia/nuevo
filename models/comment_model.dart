
class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final List<String>? mediaUrls;
  final DateTime createdAt;
  final int likesCount;
  final int repliesCount;
  final bool isLiked;
  final bool isVerified;
  final String? parentCommentId; // Para respuestas
  final List<Comment>? replies;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    this.mediaUrls,
    required this.createdAt,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isLiked = false,
    this.isVerified = false,
    this.parentCommentId,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userAvatar: json['user_avatar'] ?? '',
      content: json['content'],
      mediaUrls: json['media_urls'] != null 
          ? List<String>.from(json['media_urls']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      likesCount: json['likes_count'] ?? 0,
      repliesCount: json['replies_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isVerified: json['is_verified'] ?? false,
      parentCommentId: json['parent_comment_id'],
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((reply) => Comment.fromJson(reply))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'media_urls': mediaUrls,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'replies_count': repliesCount,
      'is_liked': isLiked,
      'is_verified': isVerified,
      'parent_comment_id': parentCommentId,
      'replies': replies?.map((reply) => reply.toJson()).toList(),
    };
  }
}
