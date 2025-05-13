import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentReport {
  final String requestId;
  final String? collectorId;
  final String? userId;
  final String? reportType;
  final String? details;
  final Timestamp createdAt; // Cambié DateTime por Timestamp

  IncidentReport({
    required this.requestId,
    this.collectorId,
    this.userId,
    this.reportType,
    this.details,
    required this.createdAt, // Usamos Timestamp aquí también
  });

  // Convertir el modelo en un mapa para Firebase
  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'collectorId': collectorId,
      'userId': userId,
      'reportType': reportType,
      'details': details,
      'createdAt': createdAt, // Guardamos Timestamp directamente
    };
  }

  // Crear el modelo desde un mapa (útil para Firebase)
  factory IncidentReport.fromMap(Map<String, dynamic> map) {
    return IncidentReport(
      requestId: map['requestId'],
      collectorId: map['collectorId'],
      userId: map['userId'],
      reportType: map['reportType'],
      details: map['details'],
      createdAt: map['createdAt'] as Timestamp, // Firebase devuelve un Timestamp
    );
  }
}
