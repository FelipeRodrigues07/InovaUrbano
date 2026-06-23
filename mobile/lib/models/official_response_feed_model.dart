class OfficialResponseFeedModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String postImageUrl;
  final DateTime createdAt;
  final String userName;
  final String profilePictureUrl;
  final int numberSuggestion;
  final int? suggestionIbgeId;
  final String suggestionType;
  final String suggestionStatus;

  OfficialResponseFeedModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.postImageUrl,
    required this.createdAt,
    required this.userName,
    required this.profilePictureUrl,
    required this.numberSuggestion,
    this.suggestionIbgeId,
    required this.suggestionType,
    required this.suggestionStatus,
  });

  factory OfficialResponseFeedModel.fromJson(Map<String, dynamic> json) {
    return OfficialResponseFeedModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      postImageUrl: json['postImageUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['userName'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      numberSuggestion: (json['numberSuggestion'] as num?)?.toInt() ?? 0,
      suggestionIbgeId: (json['suggestionIbgeId'] as num?)?.toInt(),
      suggestionType: json['suggestionType'] ?? '',
      suggestionStatus: json['suggestionStatus'] ?? '',
    );
  }
}
