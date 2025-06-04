// services/rating_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calificacion_model.dart';
import 'package:flutter/material.dart';

class RatingViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitRating(RatingModel rating) async {
    try {
      await _firestore.collection('ratings').add(rating.toMap());
    } catch (e) {
      print('Error al guardar la calificación: $e');
    }
  }

  Future<bool> sinCalificar(String requestId, String fromUserId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('ratings')
            .where('requestId', isEqualTo: requestId)
            .where('fromUserId', isEqualTo: fromUserId)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  // Valida el comentario y la calificación
  bool _verificaFormulario(String comment, double stars) {
    if (comment.trim().isEmpty || stars == 0) {
      return false;
    }
    return true;
  }

  Future<void> enviarCalificacion({
    required BuildContext context,
    required String requestId,
    required String fromUserId,
    required String toUserId,
    required double stars,
    required String comment,
    required VoidCallback onSuccess,
  }) async {
    if (_verificaFormulario(comment, stars)) {
      final newRating = RatingModel(
        requestId: requestId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        stars: stars,
        comment: comment.trim(),
        timestamp: DateTime.now(),
      );

      await submitRating(newRating);
      onSuccess();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Gracias por tu calificación.",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Color.fromARGB(255, 41, 195, 30),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Por favor escribe un comentario y selecciona una calificación.",
          ),
        ),
      );
    }
  }
}
