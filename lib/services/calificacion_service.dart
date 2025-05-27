// services/rating_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calificacion_model.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitRating(RatingModel rating) async {
    try {
      await _firestore.collection('ratings').add(rating.toMap());
    } catch (e) {
      print('Error al guardar la calificación: $e');
    }
  }

  Future<bool> hasUserRated(String requestId, String fromUserId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('ratings')
            .where('requestId', isEqualTo: requestId)
            .where('fromUserId', isEqualTo: fromUserId)
            .get();

    return snapshot.docs.isNotEmpty;
  }
}
