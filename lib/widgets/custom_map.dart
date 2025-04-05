import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatelessWidget {
  final LatLng position;
  final Function(GoogleMapController) onMapCreated;

  const MapWidget({super.key, required this.position, required this.onMapCreated});

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: position,
        zoom: 15,
      ),
      onMapCreated: onMapCreated,
      markers: {
        Marker(
          markerId: MarkerId("currentLocation"),
          position: position,
        ),
      },
    );
  }
}
