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
      return Marker(
        markerId: MarkerId(req.requestId),
        position: _parseLocation(req.location),
        icon: isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarker,
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

      // Filtrar las solicitudes "en recolección" del recolector logueado
      var collectingRequests = _pendingRequests.where((req) =>
          req.status == 'en recolección' /*&& req.collectorId == collectorId*/).toList();

      // Filtrar las solicitudes "pendientes"
      var pendingRequests = _pendingRequests.where((req) => req.status == 'pendiente').toList();

      // Filtrar las solicitudes que no están en "recolección" ni "pendientes" (puede ser "completadas" u otros estados)
      var otherRequests = _pendingRequests.where((req) =>
          req.status != 'en recolección' && req.status != 'pendiente').toList();

      // Unir las solicitudes: primero "en recolección" del recolector, luego las "pendientes", y luego el resto
      _pendingRequests = collectingRequests + pendingRequests /*+ otherRequests*/;

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
      await _service.updateRequestStatusAndCollector(
        requestId: request.requestId,
        status: 'en recolección',
        collectorId: collectorId,
      );
      request.status = 'en recolección';
      request.collectorId = collectorId;
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
}
