class OfficialResponseFeedModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String imageUrl;
  final DateTime createdAt;
  final String userName;
  final String profilePictureUrl;
  final int numberSuggestion;
  final int? suggestionIbgeId;
  final String suggestionType;
  final String statusAtPublish;
  final String suggestionStatus;

  OfficialResponseFeedModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    required this.userName,
    required this.profilePictureUrl,
    required this.numberSuggestion,
    this.suggestionIbgeId,
    required this.suggestionType,
    required this.statusAtPublish,
    required this.suggestionStatus,
  });

  factory OfficialResponseFeedModel.fromJson(Map<String, dynamic> json) {
    return OfficialResponseFeedModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      imageUrl: json['imageUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['userName'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      numberSuggestion: (json['numberSuggestion'] as num?)?.toInt() ?? 0,
      suggestionIbgeId: (json['suggestionIbgeId'] as num?)?.toInt(),
      suggestionType: json['suggestionType'] ?? '',
      statusAtPublish: json['statusAtPublish'] ?? '',
      suggestionStatus: json['suggestionStatus'] ?? '',
    );
  }
}
