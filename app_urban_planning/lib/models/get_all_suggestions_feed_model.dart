class GetAllSuggestionsFeedModel {
  final String id;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
  final String userId;
  final String suggestionImageUrl;
  final DateTime createdAt;
  final String userName;
  final String profilePictureUrl;

  GetAllSuggestionsFeedModel({
    required this.id,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.userId,
    required this.suggestionImageUrl,
    required this.createdAt,
    required this.userName,
    required this.profilePictureUrl,

  });

  factory  GetAllSuggestionsFeedModel.fromJson(Map<String, dynamic> json) {
    return GetAllSuggestionsFeedModel(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      status: json['status'],
      userId: json['userId'],
      suggestionImageUrl: json['suggestionImageUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['userName'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '', 
    );
  }
}