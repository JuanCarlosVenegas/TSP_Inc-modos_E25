import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoride/models/recoleccion_model.dart';
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/incidente_servicio.dart';
import '../models/incidente_model.dart';

class ReportIncidentViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final IncidentReportService _incidentReportService = IncidentReportService();

  String? collectorName;
  String? userName;
  String? selectedType;
  String? details;

  void setSelectedType(String? type) {
    selectedType = type;
    notifyListeners();
  }

  Future<void> fetchUserNames(String? collectorId, String userId) async {
    try {
      // Consultas asíncronas
      final fetchedCollectorName =
          collectorId != null
              ? await _userService.getUserNameById(collectorId)
              : null;

      final fetchedUserName = await _userService.getUserNameById(userId);

      // Actualización del estado
      collectorName = fetchedCollectorName ?? 'Sin asignar';
      userName = fetchedUserName ?? 'No encontrado';

      notifyListeners();
    } catch (e) {
      print('Error al obtener nombres: $e');
    }
  }

  // Llamada para crear el reporte
  Future<void> createReport(
    String requestId,
    String? collectorId,
    String? userId,
    DateTime createdAt,
  ) async {
    if (selectedType == null || selectedType!.isEmpty) {
      throw Exception("El tipo de reporte es obligatorio.");
    }

    final report = IncidentReport(
      requestId: "12345",
      collectorId: "collector1",
      userId: "user1",
      reportType: "Incidente",
      details: "Detalles del incidente...",
      createdAt: Timestamp.now(), // Establece el timestamp actual
    );

    try {
      // Llamar al servicio para guardar el reporte
      await _incidentReportService.createIncidentReport(report);
    } catch (e) {
      throw Exception("Error al guardar el reporte: $e");
    }
  }

  Future<void> sendIncidentReport(PickupRequest pickupRequest) async {
    // Crear el reporte con el timestamp actual
    final incidentReport = IncidentReport(
      requestId: pickupRequest.requestId,
      collectorId: pickupRequest.collectorId,
      userId: pickupRequest.userId,
      reportType: selectedType,
      details: details,
      createdAt: Timestamp.now(), // Fecha de creación (actual)
    );

    try {
      // Enviar el reporte a Firebase
      await FirebaseFirestore.instance.collection('incidentReports').add(incidentReport.toMap());
      print("Reporte enviado exitosamente.");
    } catch (e) {
      print("Error al enviar el reporte: $e");
    }
  }
}
