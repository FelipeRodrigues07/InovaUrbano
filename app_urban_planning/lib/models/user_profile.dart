class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
       profilePictureUrl: json['profilePictureUrl'],
    );
  }
}