import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:planejamento_urbano/controllers/get_all_suggestions_controller.dart';
import 'package:planejamento_urbano/models/get_all_suggestions_model.dart';

/// Map + suggestion markers + pan debounce fetch (Home dashboard).
class HomeSuggestionsMap extends StatefulWidget {
  const HomeSuggestionsMap({
    super.key,
    required this.mapController,
    required this.initialCenter,
    required this.initialZoom,
    required this.controller,
    required this.statusType,
    required this.isBusyOverlay,
    required this.onSuggestionTap,
  });

  final MapController mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final GetAllSuggestionsController controller;
  final String statusType;
  final bool isBusyOverlay;
  final void Function(GetAllSuggestionsModel suggestion) onSuggestionTap;

  @override
  State<HomeSuggestionsMap> createState() => _HomeSuggestionsMapState();
}

class _HomeSuggestionsMapState extends State<HomeSuggestionsMap> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Color _markerColor(String type) {
    switch (type) {
      case 'Trânsito':
        return Colors.red;
      case 'Limpeza':
        return Colors.green;
      case 'Infraestrutura':
        return Colors.blue;
      case 'Acessibilidade':
        return Colors.yellow;
      case 'Segurança':
        return const Color(0xFFFF8C00);
      case 'Saúde Pública':
        return const Color(0xFFF48FB1);
      default:
        return Colors.grey;
    }
  }

  Future<void> _fetchForViewport(
    LatLng center,
    double zoom,
    double mapWidth,
    double mapHeight,
  ) async {
    final latDelta = (180 / (pow(2, zoom)) * (mapHeight / 256));
    final lonDelta = (180 / (pow(2, zoom)) * (mapWidth / 256));

    final latMin = center.latitude - latDelta;
    final latMax = center.latitude + latDelta;
    final lonMin = center.longitude - lonDelta;
    final lonMax = center.longitude + lonDelta;

    await widget.controller.getSuggestions(
      latMin: latMin,
      latMax: latMax,
      lonMin: lonMin,
      lonMax: lonMax,
      status: widget.statusType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Stack(
        children: [
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              return FlutterMap(
                mapController: widget.mapController,
                options: MapOptions(
                  initialCenter: widget.initialCenter,
                  initialZoom: widget.initialZoom,
                  onPositionChanged: (position, hasGesture) {
                    if (!hasGesture) return;
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), () async {
                      if (!mounted) return;
                      final center = position.center;
                      final zoom = position.zoom;
                      final size = MediaQuery.of(context).size;
                      final mapWidth = size.width;
                      const mapHeight = 230.0;
                      await _fetchForViewport(center, zoom, mapWidth, mapHeight);
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                    userAgentPackageName: 'br.com.inovaurbano.app',
                    retinaMode: RetinaMode.isHighDensity(context),
                  ),
                  MarkerLayer(
                    markers: widget.controller.suggestions.map((suggestion) {
                      final markerColor = _markerColor(suggestion.type);
                      return Marker(
                        point: LatLng(suggestion.latitude, suggestion.longitude),
                        width: 80.0,
                        height: 80.0,
                        child: GestureDetector(
                          onTap: () => widget.onSuggestionTap(suggestion),
                          child: Icon(
                            Icons.location_on,
                            color: markerColor,
                            size: 40,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          if (widget.isBusyOverlay)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
