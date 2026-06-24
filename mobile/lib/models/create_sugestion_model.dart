class CreateSugestionModel {
  String type;
  String description;
  double latitude;
  double longitude;
  int ibgeId;

  CreateSugestionModel({
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.ibgeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'ibgeId': ibgeId,
    };
  }

  @override
  String toString() {
    return 'CreateSugestionModel(type: $type, description: $description, latitude: $latitude, longitude: $longitude, ibgeId: $ibgeId)';
  }
}
