import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/residuo_model.dart';
import 'package:geolocator/geolocator.dart';

class PickupRequestService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// Sube imágenes y devuelve sus URLs
  Future<List<String>> uploadImages(String requestId, List<File> images) async {
  List<String> downloadUrls = [];

  for (int i = 0; i < images.length; i++) {
    try {
      final ref = _storage.ref().child('pickup_images/$requestId/image_$i.jpg');
      final uploadTask = await ref.putFile(images[i]);
      final url = await ref.getDownloadURL();
      downloadUrls.add(url);
    } catch (e) {
      print('Error al subir imagen $i: $e');
      rethrow; // Lanza nuevamente para capturarlo arriba si es necesario
    }
  }

  return downloadUrls;
}

  /// Guarda la solicitud en Firestore, incluyendo imágenes
  Future<void> saveRequest(PickupRequest request, List<File> images, Position position) async {
    final requestId = _firestore.collection('pickup_requests').doc().id;
    final imageUrls = await uploadImages(requestId, images);

    final updatedRequest = request.copyWith(
      requestId: requestId,
      imageUrls: imageUrls,
      location: '${position.latitude},${position.longitude}',
    );

    await _firestore
        .collection('pickup_requests')
        .doc(requestId)
        .set(updatedRequest.toJson());
  }

  /// ✅ Trae solo solicitudes pendientes
  Future<List<PickupRequest>> fetchPendingRequests() async {
    final snapshot = await _firestore
        .collection('pickup_requests')
        .where('status', isEqualTo: 'pendiente')
        .get();

    return snapshot.docs
        .map((doc) => PickupRequest.fromJson(doc.data()))
        .toList();
  }

  /// Opcional: obtener **todas** las solicitudes sin filtrar
  Future<List<PickupRequest>> getAllRequests() async {
    final snapshot = await _firestore.collection('pickup_requests').get();
    return snapshot.docs
        .map((doc) => PickupRequest.fromJson(doc.data()))
        .toList();
  }
}
