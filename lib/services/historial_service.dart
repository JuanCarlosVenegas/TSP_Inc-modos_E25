import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class HistorialService {
  // Obtener dirección a partir de coordenadas
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        if (place.thoroughfare != null) address += '${place.thoroughfare!} ';
        if (place.name != null) address += '${place.name!}, ';
        if (place.subLocality != null) address += place.subLocality!;
        return address.trim();
      } else {
        return 'Dirección no disponible';
      }
    } catch (e) {
      return 'Error al obtener la dirección: $e';
    }
  }

  // Actualizar estado en Firestore
  Future<void> updatePickupStatus({
    required String requestId,
    required String filterBy,
  }) async {
    try {
      // Si el filtro es por usuario, cambia a "Cancelado".
      // Si es por recolector, cambia a "Pendiente" y limpia el collectorId.
      final Map<String, dynamic> updates = filterBy == 'userId'
          ? {'status': 'Cancelado'}
          : {'status': 'Pendiente', 'collectorId': null};

      await FirebaseFirestore.instance
          .collection('pickup_requests')
          .doc(requestId)
          .update(updates);

      print('Estado actualizado a "${updates['status']}" exitosamente');
    } catch (e) {
      print('Error al actualizar el estado: $e');
      throw Exception('No se pudo actualizar el estado');
    }
  }
}
