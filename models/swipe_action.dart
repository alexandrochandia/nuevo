enum SwipeDirection {
  left,
  right,
  up,
}

class SwipeAction {
  final String id;
  final String userId;
  final String targetUserId;
  final SwipeDirection direction;
  final DateTime createdAt;
  final String? comment;

  SwipeAction({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.direction,
    required this.createdAt,
    this.comment,
  });

  factory SwipeAction.fromJson(Map<String, dynamic> json) {
    return SwipeAction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetUserId: json['target_user_id'] as String,
      direction: SwipeDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => SwipeDirection.left,
      ),
      createdAt: DateTime.parse(json['created_at']),
      comment: json['comment'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_user_id': targetUserId,
      'direction': direction.name,
      'created_at': createdAt.toIso8601String(),
      'comment': comment,
    };
  }

  bool get isLike => direction == SwipeDirection.right;
  bool get isPass => direction == SwipeDirection.left;
  bool get isSuperLike => direction == SwipeDirection.up;
}