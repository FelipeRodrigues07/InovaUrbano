import 'dart:convert';

import 'package:http/http.dart' as http;

class NominatimGeocodingService {
  final String userAgent;

  const NominatimGeocodingService({
    this.userAgent = 'com.example.planejamento_urbano (Flutter)',
  });

  Future<({double lat, double lon})?> geocodeCity({
    required String cityName,
    required String uf,
  }) async {
    final query = '$cityName, $uf, Brazil';
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '1',
      'addressdetails': '0',
    });

    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': userAgent,
    });

    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    if (data is! List || data.isEmpty) return null;
    final first = data.first;
    if (first is! Map<String, dynamic>) return null;

    final latStr = first['lat']?.toString();
    final lonStr = first['lon']?.toString();
    final lat = latStr != null ? double.tryParse(latStr) : null;
    final lon = lonStr != null ? double.tryParse(lonStr) : null;
    if (lat == null || lon == null) return null;

    return (lat: lat, lon: lon);
  }
}

