import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/historial_model.dart';

// Clase que gestiona la obtención del historial de recolecciones desde Firestore
class HistorialService {
  final String userId; // ID del usuario autenticado, utilizado para filtrar sus solicitudes

  // Constructor que requiere el userId
  HistorialService({required this.userId});

  // Método que retorna un stream de listas de objetos Historial
  Stream<List<Historial>> getHistorial() {
    return FirebaseFirestore.instance
        .collection('pickup_requests')
        .where('userId', isEqualTo: userId) // Filtrar por usuario
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Historial.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}
