import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/recoleccion_model.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HistorialViewModel {
  final String userId;
  final String filterBy;
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  HistorialViewModel(this.userId, this.filterBy);

  Stream<QuerySnapshot> getFilteredStream() {
    return FirebaseFirestore.instance
        .collection('pickup_requests')
        .where(filterBy, isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Map<String, List<PickupRequest>> groupByDate(QuerySnapshot snapshot) {
    final List<Map<String, dynamic>> items =
        snapshot.docs.map((e) => e.data() as Map<String, dynamic>).toList();

    final Map<String, List<PickupRequest>> groupedByDate = {};
    for (var item in items) {
      final date = dateFormat.format((item['createdAt'] as Timestamp).toDate());
      groupedByDate
          .putIfAbsent(date, () => [])
          .add(PickupRequest.fromJson(item));
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
      print('➡️ Intentando actualizar el estado...');
      print('🔍 ID del documento: ${pickupRequest.requestId}');
      print('🔍 Nuevo estado: $newStatus');

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
}
