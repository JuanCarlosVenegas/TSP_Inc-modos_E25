import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recoleccion_model.dart';
import '../services/solicitud_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class PickupRequestViewModel extends ChangeNotifier {
  final String userId;
  final PickupRequestService _service = PickupRequestService();

  bool _isDisposed = false;
  final locationFocusNode = FocusNode();

  PickupRequestViewModel({required this.userId}) {
    _initLocation();

    // Escuchar cuando el campo pierde el foco
    locationFocusNode.addListener(() {
      if (!locationFocusNode.hasFocus) {
        updatePositionFromAddress(locationController.text);
      }
    });
  }

  // No olvides llamar a dispose para liberar recursos
  // @override
  // void dispose() {
  //   locationFocusNode.dispose();
  //   locationController.dispose();
  //   super.dispose();
  // }

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

  Future<void> _initLocation() async {
    try {
      // Configuramos los ajustes de localización
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      // Intentamos obtener la posición actual del usuario
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      // Si obtenemos la posición correctamente, actualizamos la dirección
      await updateAddressFromPosition(currentPosition!);
    } catch (e) {
      // Si no se puede obtener la posición, manejamos el error
      debugPrint("Error al obtener la localización: $e");

      /// Asignamos una ubicación predeterminada (Zacatecas)
      currentPosition = Position(
        latitude: 22.7733, // Latitud de Zacatecas
        longitude: -102.5837, // Longitud de Zacatecas
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
      );


      // Actualizamos la dirección de la ubicación predeterminada
      await updateAddressFromPosition(currentPosition!);
    }

    // Cuando la ubicación está lista (ya sea actual o predeterminada), dejamos de cargar y notificamos
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
    locationFocusNode.dispose();
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
    updateAddressFromPosition(currentPosition!);
  }
  Future<void> updateAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = '${place.street}, ${place.locality}, ${place.country}';
        locationController.text = address;
      }
    } catch (e) {
      debugPrint("Error al obtener dirección: $e");
      locationController.text = 'Dirección no disponible';
    }
  }

  Future<void> updatePositionFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final newPosition = Position(
          latitude: loc.latitude,
          longitude: loc.longitude,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0,
        );

        currentPosition = newPosition;
        locationController.text = address;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error al convertir dirección a coordenadas: $e");
    }
  }

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // El usuario ha denegado permanentemente los permisos
      // Muestra un mensaje al usuario o redirígelo a la configuración de la app.
      debugPrint("Permiso de localización denegado permanentemente.");
    }
  }

  // Función para cerrar sesión
  void logout() {
    // Lógica para cerrar sesión, tal vez borrando datos locales o similar
    // No olvides llamar a notifyListeners() si necesitas actualizar la UI
  }
}
