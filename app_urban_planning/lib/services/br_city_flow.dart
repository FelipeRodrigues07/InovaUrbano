import 'package:planejamento_urbano/models/br_city.dart';
import 'package:planejamento_urbano/services/ibge_cities_service.dart';
import 'package:planejamento_urbano/services/nominatim_geocoding_service.dart';
import 'package:planejamento_urbano/storage/storage_city_prefs.dart';
import 'package:planejamento_urbano/utils/pt_br_normalize.dart';

/// IBGE search, geocode when coords missing, and city prefs — shared by Home and Report.
class BrCityFlow {
  BrCityFlow({
    IbgeCitiesService? ibge,
    NominatimGeocodingService? geocoder,
  })  : _ibge = ibge ?? IbgeCitiesService(),
        _geocoder = geocoder ?? const NominatimGeocodingService();

  final IbgeCitiesService _ibge;
  final NominatimGeocodingService _geocoder;

  Future<List<BrCity>> searchMunicipiosSorted(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];
    final results = await _ibge.searchMunicipios(q);
    final nq = normalizePtBr(q);
    final sorted = results.toList()
      ..sort((a, b) {
        final an = normalizePtBr(a.name);
        final bn = normalizePtBr(b.name);
        final aStarts = an.startsWith(nq);
        final bStarts = bn.startsWith(nq);
        if (aStarts != bStarts) return aStarts ? -1 : 1;
        final aContains = an.contains(nq);
        final bContains = bn.contains(nq);
        if (aContains != bContains) return aContains ? -1 : 1;
        return an.compareTo(bn);
      });
    return sorted.take(50).toList();
  }

  /// Returns [city] with coordinates, or `null` if geocoding failed.
  Future<BrCity?> resolveCoordinates(BrCity city) async {
    if (city.lat != null && city.lon != null) return city;
    final coords = await _geocoder.geocodeCity(
      cityName: city.name,
      uf: city.uf,
    );
    if (coords == null) return null;
    return city.copyWith(lat: coords.lat, lon: coords.lon);
  }

  Future<List<BrCity>> persistSelection(
    BrCity resolved,
    List<BrCity> recentCities,
  ) async {
    await StorageCityPrefs.setLastCity(resolved);
    final recents = [
      resolved,
      ...recentCities.where((c) => c.ibgeId != resolved.ibgeId),
    ].take(8).toList();
    await StorageCityPrefs.setRecent(recents);
    return recents;
  }
}
