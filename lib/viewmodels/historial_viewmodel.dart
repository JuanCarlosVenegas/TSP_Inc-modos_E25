import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoride/viewmodels/calificacion_viewmodel.dart';
import 'package:ecoride/services/user_service.dart';
import 'package:ecoride/views/calificacion_screen.dart';
import 'package:ecoride/views/chat_screen.dart';
import 'package:intl/intl.dart';
import '../models/recoleccion_model.dart';
import 'package:flutter/material.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HistorialViewModel {
  final String userId;
  final String filterBy;
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  final UserService _userService = UserService();
  final RatingViewModel _califService = RatingViewModel();

  HistorialViewModel(this.userId, this.filterBy);

  Stream<QuerySnapshot> getFilteredStream() {
    return FirebaseFirestore.instance
        .collection('pickup_requests')
        .where(filterBy, isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Map<String, List<DocumentSnapshot>> groupByDate(QuerySnapshot snapshot) {
    final Map<String, List<DocumentSnapshot>> groupedByDate = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = dateFormat.format((data['createdAt'] as Timestamp).toDate());

      groupedByDate.putIfAbsent(date, () => []).add(doc);
    }

    return groupedByDate;
  }

  Future<void> updatePickupStatus(
    PickupRequest pickupRequest,
    String filterBy,
  ) async {
    String newStatus;
    Map<String, dynamic> updateData = {};

    // ✅ Lógica para determinar el nuevo estado y datos a actualizar
    if (filterBy == 'userId') {
      newStatus = 'Cancelado';
      updateData = {'status': newStatus};
    } else if (filterBy == 'collectorId') {
      newStatus = 'Pendiente';
      updateData = {
        'status': newStatus,
        'collectorId': null, // 🔄 Se actualiza a null
      };
    } else {
      throw Exception('filterBy no válido');
    }

    try {
      // print('➡️ Intentando actualizar el estado...');
      // print('🔍 ID del documento: ${pickupRequest.requestId}');
      // print('🔍 Nuevo estado: $newStatus');

      // ✅ Verificación de existencia
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('pickup_requests')
              .doc(pickupRequest.requestId)
              .get();

      if (!doc.exists) {
        print('⚠️ El documento no existe en Firebase');
        return;
      }

      // ✅ Actualización en Firebase Firestore
      await FirebaseFirestore.instance
          .collection('pickup_requests')
          .doc(pickupRequest.requestId)
          .update(updateData);

      // ✅ Actualización local del objeto para reflejar el cambio
      pickupRequest = pickupRequest.copyWith(
        status: newStatus,
        collectorId:
            filterBy == 'collectorId' ? null : pickupRequest.collectorId,
      );

      print('✅ Estado actualizado a: $newStatus');
      if (filterBy == 'collectorId') {
        print('🔄 collectorId actualizado a: null');
      }
    } catch (e) {
      print('❌ Error al actualizar el estado: $e');
    }
  }

  void navigateToChat({
    required BuildContext context,
    required PickupRequest request,
    required String filterBy,
    required VoidCallback refresh,
  }) {
    final currentUserId =
        filterBy == 'userId' ? request.userId : request.collectorId ?? '';
    final otherUserId =
        filterBy == 'userId' ? request.collectorId ?? '' : request.userId;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatScreen(
              currentUserId: currentUserId,
              otherUserId: otherUserId,
              requestId: request.requestId,
            ),
      ),
    ).then((_) => refresh());
  }

  Future<void> calificarRecoleccion({
    required BuildContext context,
    required String filterBy,
    required PickupRequest request,
  }) async {
    String nameToShow = 'Desconocido';
    String actualUserId = 'Desconocido';
    String calificadoId = 'Desconocido';

    if (filterBy == 'userId') {
      nameToShow =
          await _userService.getUserNameById(request.collectorId ?? 'amer') ??
          'Usuario';
      actualUserId = request.userId;
      calificadoId = request.collectorId ?? 'no asignado';
    } else {
      nameToShow =
          await _userService.getUserNameById(request.userId) ?? 'Usuario';
      actualUserId = request.collectorId ?? 'no asignado';
      calificadoId = request.userId;
    }

    final alreadyRated = await _califService.sinCalificar(
      request.requestId,
      actualUserId,
    );

    if (alreadyRated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya has calificado este servicio.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showRatingDialog(
      context: context,
      collectorName: nameToShow,
      request: request,
      fromUserId: actualUserId,
      toUserId: calificadoId,
    );
  }
}
