import 'package:cloud_firestore/cloud_firestore.dart';

class Historial {
  final String id;
  final String status;
  final String address;
  final int amount;
  final String category;
  final double price;
  final DateTime? date;
  final GeoPoint? location;

  Historial({
    required this.id,
    required this.status,
    required this.address,
    required this.amount,
    required this.category,
    required this.price,
    required this.date,
    this.location,
  });

  factory Historial.fromMap(String id, Map<String, dynamic> data) {
    return Historial(
      id: id,
      status: data['status'] ?? 'Desconocido',
      address: data['address'] ?? 'Sin dirección',
      amount: (data['amount'] ?? 0).toInt(),
      category: data['category'] ?? 'General',
      price: (data['price'] ?? 0).toDouble(),
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
      location: data['location'], // ← Aquí se extrae el GeoPoint
    );
  }
}
