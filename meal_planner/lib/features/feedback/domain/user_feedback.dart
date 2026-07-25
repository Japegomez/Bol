enum FeedbackCategory {
  issue,
  feature,
  other;

  String get dbValue => name;

  static FeedbackCategory fromDb(String value) {
    return FeedbackCategory.values.firstWhere(
      (c) => c.dbValue == value,
      orElse: () => FeedbackCategory.other,
    );
  }
}

enum FeedbackStatus {
  pending,
  resolved,
  ignored;

  String get dbValue => name;

  static FeedbackStatus fromDb(String value) {
    return FeedbackStatus.values.firstWhere(
      (s) => s.dbValue == value,
      orElse: () => FeedbackStatus.pending,
    );
  }
}

class AdminFeedbackFilters {
  const AdminFeedbackFilters({
    this.category,
    this.status = FeedbackStatus.pending,
  });

  final FeedbackCategory? category;
  final FeedbackStatus? status;

  @override
  bool operator ==(Object other) {
    return other is AdminFeedbackFilters &&
        other.category == category &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(category, status);
}

class UserFeedback {
  const UserFeedback({
    required this.id,
    required this.userId,
    required this.category,
    required this.status,
    required this.message,
    required this.createdAt,
    this.userDisplayName,
  });

  final String id;
  final String userId;
  final FeedbackCategory category;
  final FeedbackStatus status;
  final String message;
  final DateTime createdAt;
  final String? userDisplayName;

  factory UserFeedback.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    String? username;
    if (user is Map<String, dynamic>) {
      username = user['username']?.toString();
    }

    return UserFeedback(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      category: FeedbackCategory.fromDb(json['category']?.toString() ?? 'other'),
      status: FeedbackStatus.fromDb(json['status']?.toString() ?? 'pending'),
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.fromMillisecondsSinceEpoch(0),
      userDisplayName: username,
    );
  }
}
