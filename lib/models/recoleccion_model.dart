import 'package:cloud_firestore/cloud_firestore.dart';

class PickupRequest {
  final String requestId;
  final String userId;
  final GeoPoint location;
  final String time;
  final String amount;
  final String wasteType;
  final int quantity;
  final String size;
  String status;
  final DateTime createdAt;
  String? collectorId;
  final List<String> imageUrls;
  
  // ✅ Nuevos atributos para manejar notificaciones enviadas
  bool recolectorLlegoNotificado;
  bool pedidoDesechadoNotificado;

  /// Campo opcional (no se guarda en Firestore) para calcular distancia
  double? distance;

  PickupRequest({
    required this.requestId,
    required this.userId,
    required this.location,
    required this.time,
    required this.amount,
    required this.wasteType,
    required this.quantity,
    required this.size,
    required this.status,
    required this.createdAt,
    this.collectorId,
    required this.imageUrls,
    this.distance,
    this.recolectorLlegoNotificado = false, // 🔄 Por defecto en `false`
    this.pedidoDesechadoNotificado = false, // 🔄 Por defecto en `false`
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'userId': userId,
      'location': location,
      'time': time,
      'amount': amount,
      'wasteType': wasteType,
      'quantity': quantity,
      'size': size,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'collectorId': collectorId,
      'imageUrls': imageUrls,
      'recolectorLlegoNotificado': recolectorLlegoNotificado, // 🔄 Se añade al JSON
      'pedidoDesechadoNotificado': pedidoDesechadoNotificado // 🔄 Se añade al JSON
    };
  }

  factory PickupRequest.fromJson(Map<String, dynamic> json) {
    return PickupRequest(
      requestId: json['requestId'],
      userId: json['userId'],
      location: json['location'] is GeoPoint
          ? json['location']
          : GeoPoint(0, 0),
      time: json['time'],
      amount: json['amount'],
      wasteType: json['wasteType'],
      quantity: json['quantity'],
      size: json['size'],
      status: json['status'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      collectorId: json['collectorId'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      recolectorLlegoNotificado: json['recolectorLlegoNotificado'] ?? false, // 🔄 Trae el valor o false por defecto
      pedidoDesechadoNotificado: json['pedidoDesechadoNotificado'] ?? false, // 🔄 Trae el valor o false por defecto
    );
  }

  /// 🔄 **Método copyWith actualizado:**
  PickupRequest copyWith({
    String? requestId,
    String? userId,
    GeoPoint? location,
    String? time,
    String? amount,
    String? wasteType,
    int? quantity,
    String? size,
    String? status,
    DateTime? createdAt,
    String? collectorId,
    List<String>? imageUrls,
    double? distance,
    bool? recolectorLlegoNotificado,
    bool? pedidoDesechadoNotificado,
  }) {
    return PickupRequest(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      location: location ?? this.location,
      time: time ?? this.time,
      amount: amount ?? this.amount,
      wasteType: wasteType ?? this.wasteType,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      collectorId: collectorId ?? this.collectorId,
      imageUrls: imageUrls ?? this.imageUrls,
      distance: distance ?? this.distance,
      recolectorLlegoNotificado: recolectorLlegoNotificado ?? this.recolectorLlegoNotificado,
      pedidoDesechadoNotificado: pedidoDesechadoNotificado ?? this.pedidoDesechadoNotificado,
    );
  }
}
