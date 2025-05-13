import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incidente_model.dart';

class IncidentReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para guardar el reporte en Firestore
  Future<void> createIncidentReport(IncidentReport report) async {
    try {
      await _firestore.collection('incidentReports').add(report.toMap());
    } catch (e) {
      print('Error al guardar el reporte: $e');
      throw Exception('Error al guardar el reporte');
    }
  }
}
