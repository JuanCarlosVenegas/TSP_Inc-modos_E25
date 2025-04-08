import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import '../models/recoleccion_model.dart';
import '../services/solicitud_service.dart';
import '../services/location_service.dart';
import '../views/login_screen.dart';
import 'package:geocoding/geocoding.dart';


class PendingRequestsViewModel extends ChangeNotifier {
  final PickupRequestService _service = PickupRequestService();
  final String collectorId;

  PendingRequestsViewModel({required this.collectorId});

  List<PickupRequest> _pendingRequests = [];
  bool _isLoading = false;
  LatLng? _initialPosition;
  GoogleMapController? _mapController;

  List<PickupRequest> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  LatLng? get initialPosition => _initialPosition;

  String? _selectedRequestId;
  String? get selectedRequestId => _selectedRequestId;

  void selectRequest(String requestId) {
    _selectedRequestId = requestId;
    final selected = _pendingRequests.firstWhere((r) => r.requestId == requestId);
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_parseLocation(selected.location)),
    );
    notifyListeners();
  }

  Set<Marker> get markers {
    return _pendingRequests.map((req) {
      final isSelected = req.requestId == _selectedRequestId;

      // Determina el color según el estado
      BitmapDescriptor markerColor;
      if (req.status == 'en recolección') {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      } else if (isSelected) {
        markerColor = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      } else {
        markerColor = BitmapDescriptor.defaultMarker;
      }

      return Marker(
        markerId: MarkerId(req.requestId),
        position: _parseLocation(req.location),
        icon: markerColor,
        infoWindow: InfoWindow(
          title: req.wasteType,
          snippet: req.amount,
        ),
      );
    }).toSet();
  }


  Future<void> loadPendingRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Obtener todas las solicitudes de recolección
      _pendingRequests = await _service.fetchPendingRequests();
      final currentPosition = await LocationService().getUserLocation();

      // Si tenemos la ubicación actual, calculamos distancia y ordenamos
      if (currentPosition != null) {
        for (var req in _pendingRequests) {
          final distance = _calculateDistance(currentPosition, _parseLocation(req.location));
          req.distance = distance;
        }

        _pendingRequests.sort((a, b) => a.distance!.compareTo(b.distance!));
        _initialPosition = currentPosition;
      }

      // 🔍 Filtrar solicitudes en recolección del recolector logueado
      var collectingRequests = _pendingRequests.where((req) =>
          req.status == 'en recolección' && req.collectorId == collectorId).toList();

      // 🔍 Filtrar solicitudes pendientes (sin asignar aún)
      var pendingRequests = _pendingRequests.where((req) => req.status == 'pendiente').toList();

      // 🔄 Unir: primero las del recolector, luego las pendientes
      _pendingRequests = collectingRequests + pendingRequests;

    } catch (e) {
      debugPrint('Error al cargar solicitudes pendientes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }


  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void zoomIn() {
    _mapController?.moveCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    _mapController?.moveCamera(CameraUpdate.zoomOut());
  }

  LatLng _parseLocation(GeoPoint geoPoint) {
    return LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  void logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> acceptRequest(PickupRequest request) async {
  try {
    // Actualiza la solicitud en Firestore
    await _service.updateRequestStatusAndCollector(
      requestId: request.requestId,
      status: 'en recolección',
      collectorId: collectorId,
    );
    
    // Cambia el estado de la solicitud localmente
    request.status = 'en recolección';
    request.collectorId = collectorId;

    // Actualizar la lista localmente: mover la solicitud "en recolección" al principio
    _pendingRequests.removeWhere((req) => req.requestId == request.requestId); // Elimina la solicitud antigua
    _pendingRequests.insert(0, request); // Inserta la solicitud al principio de la lista

    // Reordenar las solicitudes en recolección por hora (si es necesario)
    _pendingRequests.sort((a, b) {
      // Solo ordenar entre las solicitudes "en recolección"
      if (a.status == 'en recolección' && b.status == 'en recolección') {
        return _timeStringToMinutes(a.time).compareTo(_timeStringToMinutes(b.time));
      }
      return 0; // No cambiar el orden de las demás solicitudes
    });

    // Notificar a los listeners para actualizar la UI
    notifyListeners();
  } catch (e) {
    debugPrint('Error al aceptar solicitud: $e');
  }
}

int _timeStringToMinutes(String time) {
  final regExp = RegExp(r'(\d+):(\d+) (\w{2})'); // RegExp para capturar hora, minuto y AM/PM
  final match = regExp.firstMatch(time);

  if (match != null) {
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final amPm = match.group(3);

    int totalMinutes = minute;

    // Convertir hora a 24 horas
    if (amPm == 'PM' && hour != 12) {
      totalMinutes += (hour + 12) * 60; // Convertir PM a 24 horas
    } else if (amPm == 'AM' && hour == 12) {
      totalMinutes += 0; // 12 AM es medianoche (00:00)
    } else {
      totalMinutes += hour * 60; // Hora en formato AM sin cambiar
    }

    return totalMinutes;
  }

  return 0; // Si el formato es incorrecto o no se puede parsear, devuelve 0
}

Future<void> completeRequest(PickupRequest request) async {
  try {
    // Actualiza el estado de la solicitud en Firestore
    await _service.updateRequestStatus(request.requestId, 'completada');

    // Elimina la solicitud de la lista local
    _pendingRequests.removeWhere((r) => r.requestId == request.requestId);

    // Notificar a los listeners para que la UI se actualice
    notifyListeners();
  } catch (e) {
    debugPrint('Error al completar solicitud: $e');
    rethrow; // Vuelve a lanzar el error para poder gestionarlo fuera de la función
  }
}







  double _calculateDistance(LatLng from, LatLng to) {
    const earthRadius = 6371000; // en metros

    final dLat = _degreesToRadians(to.latitude - from.latitude);
    final dLng = _degreesToRadians(to.longitude - from.longitude);

    final a = 
      (sin(dLat / 2) * sin(dLat / 2)) +
      cos(_degreesToRadians(from.latitude)) *
      cos(_degreesToRadians(to.latitude)) *
      (sin(dLng / 2) * sin(dLng / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  String formatDistance(double? distanceInMeters) {
    if (distanceInMeters == null) return '';
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // Obtén la dirección a partir de las coordenadas
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Concatenar la dirección completa
        String address = '';
        if (place.thoroughfare != null) address += place.thoroughfare!;
        if (place.name != null) address += '${place.name!}, ';       
        if (place.subLocality != null) address += '${place.subLocality!}, ';
        if (place.administrativeArea != null) address += '${place.administrativeArea!}, ';
        if (place.country != null) address += place.country!;
        
        return address;
      } else {
        return 'Dirección no disponible';
      }
    } catch (e) {
      return 'Error al obtener la dirección: $e';
    }
  }

  
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _db.collection('pickup_requests').doc(requestId).update({
      'status': status,
    });
  }

  Future<void> removeRequestFromList(String requestId) async {
    // Este método no es necesario si solo gestionas la lista en el ViewModel
    // Aquí el ViewModel se encargará de eliminar la solicitud de la lista localmente
  }
}


