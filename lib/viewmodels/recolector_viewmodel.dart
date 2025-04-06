import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import '../models/recoleccion_model.dart';
import '../services/solicitud_service.dart';
import '../services/location_service.dart';
import '../views/login_screen.dart';

class PendingRequestsViewModel extends ChangeNotifier {
  final PickupRequestService _service = PickupRequestService();

  List<PickupRequest> _pendingRequests = [];
  bool _isLoading = false;
  LatLng? _initialPosition;
  GoogleMapController? _mapController;

  List<PickupRequest> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  LatLng? get initialPosition => _initialPosition;

  Set<Marker> get markers => _pendingRequests.map((req) {
        return Marker(
          markerId: MarkerId(req.requestId),
          position: _parseLocation(req.location),
          infoWindow: InfoWindow(
            title: req.wasteType,
            snippet: req.amount,
          ),
        );
      }).toSet();

  Future<void> loadPendingRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Obtener ubicación actual del recolector
      final currentPosition = await LocationService().getUserLocation();

      // Obtener las solicitudes pendientes
      _pendingRequests = await _service.fetchPendingRequests();

      // Ordenar por distancia (si la ubicación está disponible)
      if (currentPosition != null) {
        _pendingRequests.sort((a, b) {
          final aDistance = _calculateDistance(currentPosition, _parseLocation(a.location));
          final bDistance = _calculateDistance(currentPosition, _parseLocation(b.location));
          return aDistance.compareTo(bDistance);
        });

        _initialPosition = currentPosition;
      }
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
      await _service.updateRequestStatus(request.requestId, 'en recolección');
      request.status = 'en recolección';
      notifyListeners();
    } catch (e) {
      debugPrint('Error al aceptar solicitud: $e');
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
}
