import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../models/residuo_model.dart';
import '../services/solicitud_service.dart';

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

  void _safeNotify() {
    if (!_isDisposed && hasListeners) notifyListeners();
  }

  void _initLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
      default: return "";
    }
  }

  Future<void> pickImage() async {
  if (selectedImages.length >= 3) return;

  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final file = File(pickedFile.path);
    if (await file.exists()) {
      selectedImages.add(file);
      _safeNotify();
    } else {
      print("El archivo seleccionado no existe en la ruta: ${pickedFile.path}");
    }
  }
}

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
      _safeNotify();
    }
  }

  Future<void> confirmRequest() async {
  if (currentPosition == null) return;

  final request = PickupRequest(
    requestId: '',
    userId: userId,
    location: locationController.text,
    time: timeController.text,
    amount: amountController.text,
    wasteType: selectedWasteType,
    quantity: quantity,
    size: sizeLabel,
    status: 'pendiente',
    createdAt: DateTime.now(),
    collectorId: null,
    imageUrls: [],
  );

  try {
    await _service.saveRequest(request, selectedImages, currentPosition!);
    _clearForm();
    _safeNotify();
  } catch (e) {
    print("Error al confirmar solicitud: $e");
    // Opcional: puedes mostrar un snackbar o dialog:
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir: $e')));
  }
}


  void _clearForm() {
    locationController.clear();
    timeController.clear();
    amountController.clear();
    quantity = 1;
    quantityController.text = "1";
    selectedWasteType = 'General';
    size = 1;
    sizeValue = 1.0;
    selectedImages.clear();
    showWasteForm = false;
  }

  void logout() {}

  @override
  void dispose() {
    locationController.dispose();
    timeController.dispose();
    amountController.dispose();
    quantityController.dispose();
    _isDisposed = true;
    super.dispose();
  }
}
