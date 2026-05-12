class CreateSugestionModel {
   String type;
  String description;
  double latitude;
  double longitude;
  int ibgeId;
  String userId;

  CreateSugestionModel({
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.ibgeId,
    required this.userId,
  });

  // Método para converter a classe para JSON (para envio na API)
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'ibgeId': ibgeId,
      'userId': userId,
    };
  }

  // Sobrescrever o método toString para imprimir informações da instância
  @override
  String toString() {
    return 'CreateSugestionModel(type: $type, description: $description, latitude: $latitude, longitude: $longitude, ibgeId: $ibgeId, userId: $userId)';
  }
}