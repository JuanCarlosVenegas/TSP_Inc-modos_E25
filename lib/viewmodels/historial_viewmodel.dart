import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/historial_model.dart';
import '../services/historial_service.dart';

// ViewModel que maneja la lógica del historial y expone un stream de datos al UI
class HistorialViewModel extends ChangeNotifier {
  final HistorialService _service;        // Servicio que interactúa con Firestore
  final Stream<List<Historial>> historialStream;  // Stream de historial expuesto al frontend

  // Constructor privado que inicializa el stream utilizando el servicio
  HistorialViewModel._(this._service)
      : historialStream = _service.getHistorial();

  // Fábrica que crea una instancia del ViewModel usando el userId proporcionado
  factory HistorialViewModel.create(String userId) {
    return HistorialViewModel._(HistorialService(userId: userId));
  }
}
