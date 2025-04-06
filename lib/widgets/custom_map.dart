import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatelessWidget {
  final LatLng position;
  final Function(GoogleMapController) onMapCreated;
  final Function(LatLng) onMapTapped; // Este es el parámetro que manejará el toque en el mapa

  const MapWidget({
    super.key,
    required this.position,
    required this.onMapCreated,
    required this.onMapTapped, // Asegúrate de pasarlo al constructor
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
    //  key: ValueKey("${position.latitude},${position.longitude}"), // fuerza reconstrucción si cambia posición
      initialCameraPosition: CameraPosition(
        target: position,
        zoom: 15,
      ),
      onMapCreated: onMapCreated,
      onTap: (LatLng latLng) {
        onMapTapped(latLng);
      },
      markers: {
        Marker(
          markerId: MarkerId("currentLocation"),
          position: position,
        ),
      },
    );
  }
}

