import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Map with a single draggable pin (tap to move) for the Report flow.
class ReportPinMap extends StatelessWidget {
  const ReportPinMap({
    super.key,
    required this.mapController,
    required this.pinLocation,
    required this.isBusyOverlay,
    required this.onMapTap,
  });

  final MapController mapController;
  final LatLng pinLocation;
  final bool isBusyOverlay;
  final ValueChanged<LatLng> onMapTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: pinLocation,
              initialZoom: 14,
              onTap: (_, point) => onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                userAgentPackageName: 'br.com.inovaurbano.app',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: pinLocation,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isBusyOverlay)
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
