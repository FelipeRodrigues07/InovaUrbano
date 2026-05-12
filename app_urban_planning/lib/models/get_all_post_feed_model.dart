class GetAllPostsFeedModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String postImageUrl;
  final DateTime createdAt;
  final String userName;
  final String profilePictureUrl;

  GetAllPostsFeedModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.postImageUrl,
    required this.createdAt,
    required this.userName,
    required this.profilePictureUrl,

  });

  factory  GetAllPostsFeedModel.fromJson(Map<String, dynamic> json) {
    return GetAllPostsFeedModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      postImageUrl: json['postImageUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['userName'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '', 
    );
  }
}