import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recoleccion_model.dart';
import '../services/solicitud_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class PickupRequestViewModel extends ChangeNotifier {
  final String userId;
  final PickupRequestService _service = PickupRequestService();

  bool _isDisposed = false;

  PickupRequestViewModel({required this.userId}) {
    _initLocation();
  }

  final locationController = TextEditingController();
  final timeController = TextEditingController();
  final amountController = TextEditingController();
  final quantityController = TextEditingController(text: "1");

  bool showWasteForm = false;
  bool isLoading = true;

  String selectedWasteType = 'General';
  int quantity = 1;
  int size = 1;
  double sizeValue = 1.0;

  Position? currentPosition;
  final List<File> selectedImages = [];

  bool _isPickingImage = false;

  void _safeNotify() {
    if (!_isDisposed && hasListeners) notifyListeners();
  }

  void _initLocation() async {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, 
    );

    currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    isLoading = false;
    _safeNotify();
  }

  void toggleWasteForm(bool show) {
    showWasteForm = show;
    _safeNotify();
  }

  void updateWasteType(String type) {
    selectedWasteType = type;
    _safeNotify();
  }

  void increaseQuantity() {
    quantity++;
    quantityController.text = quantity.toString();
    _safeNotify();
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
      quantityController.text = quantity.toString();
      _safeNotify();
    }
  }

  void updateSize(int value) {
    size = value;
    sizeValue = value.toDouble();
    _safeNotify();
  }

  String get sizeLabel {
    switch (size) {
      case 1: return "Pequeño";
      case 2: return "Mediano";
      case 3: return "Grande";
      default: return "Desconocido";
    }
  }

  Future<void> pickImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      selectedImages.add(File(file.path));
      _safeNotify();
    }
    _isPickingImage = false;
  }

  Future<void> confirmRequest() async {
    if (currentPosition == null) return;

    // Crear una solicitud con los valores actuales
    final request = PickupRequest(
      requestId: '',  // Se genera automáticamente en el servicio
      userId: userId,
      location: GeoPoint(currentPosition!.latitude, currentPosition!.longitude), // GeoPoint con las coordenadas
      time: timeController.text,
      amount: amountController.text,
      wasteType: selectedWasteType,
      quantity: quantity,
      size: sizeLabel, // Usa el método sizeLabel para obtener el nombre del tamaño
      status: 'pendiente', // El estado inicial es 'pendiente'
      createdAt: DateTime.now(), // Usar la fecha y hora actual
      collectorId: null, // Aún no asignado
      imageUrls: [], // Las imágenes serán manejadas por el servicio
    );

    // Llamar al servicio para guardar la solicitud en Firestore
    try {
      await _service.saveRequest(request, selectedImages, currentPosition!);
      // Puedes agregar alguna lógica para manejar el estado de éxito, como un mensaje o actualización de UI
    } catch (e) {
      print("Error al confirmar la solicitud: $e");
      // Aquí podrías agregar una lógica de manejo de errores para mostrar al usuario si algo falla
    }
  }


  @override
  void dispose() {
    _isDisposed = true;
    locationController.dispose();
    timeController.dispose();
    amountController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  // Función que actualiza la ubicación cuando se toca en el mapa
  void updateLocation(LatLng latLng) {
  currentPosition = Position(
    latitude: latLng.latitude,
    longitude: latLng.longitude,
    timestamp: DateTime.now(),
    accuracy: 0, // O usa el valor de precisión si lo tienes
    altitude: 0, // Asumiendo que no tienes datos de altitud
    altitudeAccuracy: 0, // Valor por defecto si no tienes datos
    heading: 0, // Valor por defecto si no tienes datos de orientación
    headingAccuracy: 0, // Valor por defecto si no tienes datos de precisión de orientación
    speed: 0, // O usa la velocidad actual si tienes datos
    speedAccuracy: 0, // O usa precisión de velocidad si tienes datos
  );
  notifyListeners();
}


  // Función para cerrar sesión
  void logout() {
    // Lógica para cerrar sesión, tal vez borrando datos locales o similar
    // No olvides llamar a notifyListeners() si necesitas actualizar la UI
  }
}
