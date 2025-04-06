import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/residuo_model.dart';
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
      _pendingRequests = await _service.fetchPendingRequests();
      _initialPosition = await LocationService().getUserLocation();
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

  LatLng _parseLocation(String locationString) {
    try {
      final parts = locationString.split(',');
      if (parts.length < 2) throw FormatException("Ubicación incompleta");
      final lat = double.parse(parts[0]);
      final lng = double.parse(parts[1]);
      return LatLng(lat, lng);
    } catch (e) {
      debugPrint('Error al parsear ubicación "$locationString": $e');
      // Posición por defecto: Ciudad de México
      return const LatLng(19.4326, -99.1332);
    }
  }

  void logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
