class BrCity {
  final int ibgeId;
  final String name;
  final String uf;
  final double? lat;
  final double? lon;

  const BrCity({
    required this.ibgeId,
    required this.name,
    required this.uf,
    this.lat,
    this.lon,
  });

  String get label => '$name - $uf';

  BrCity copyWith({double? lat, double? lon}) {
    return BrCity(
      ibgeId: ibgeId,
      name: name,
      uf: uf,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  Map<String, dynamic> toJson() => {
        'ibgeId': ibgeId,
        'name': name,
        'uf': uf,
        'lat': lat,
        'lon': lon,
      };

  static BrCity fromJson(Map<String, dynamic> json) => BrCity(
        ibgeId: (json['ibgeId'] as num).toInt(),
        name: json['name'] as String,
        uf: json['uf'] as String,
        lat: (json['lat'] as num?)?.toDouble(),
        lon: (json['lon'] as num?)?.toDouble(),
      );
}

