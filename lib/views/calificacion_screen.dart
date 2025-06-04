import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../models/recoleccion_model.dart';
import '../viewmodels/calificacion_viewmodel.dart';

void showRatingDialog({
  required BuildContext context,
  required String collectorName,
  required PickupRequest request,
  required String fromUserId,
  required String toUserId,
}) {
  final TextEditingController commentController = TextEditingController();
  double rating = 0;
  final ratingService = RatingViewModel();
  final dateFormat = DateFormat('dd/MM/yyyy');
  final ratingViewModel = RatingViewModel();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            '¿Qué tal estuvo el servicio de $collectorName?',
            textAlign: TextAlign.center,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido: ${request.requestId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('${request.quantity} bolsas - ${request.wasteType}'),
                    Text(
                      '${dateFormat.format(request.createdAt)}   ${request.time}',
                    ),
                    Text(
                      request.amount,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 40,
                itemBuilder:
                    (context, _) => const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Escribir un comentario'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Comentario',
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await ratingViewModel.enviarCalificacion(
                      context: context,
                      requestId: request.requestId,
                      fromUserId: fromUserId,
                      toUserId: toUserId,
                      stars: rating,
                      comment: commentController.text,
                      onSuccess: () => Navigator.of(context).pop(),
                    );
                  },
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
