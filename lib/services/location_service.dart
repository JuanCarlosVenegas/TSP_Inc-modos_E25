import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  final Location _location = Location();

  Future<LatLng?> getUserLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return null;
      }

      // Asegúrate de que los permisos de ubicación sean válidos.
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return null;
      }

      // Espera a que la ubicación esté disponible
      LocationData locationData = await _location.getLocation();
      return LatLng(locationData.latitude!, locationData.longitude!);

    } catch (e) {
      print("Error al obtener la ubicación: $e");
      return null; // Devuelve null si ocurre un error.
    }
  }
}
