import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/recoleccion_model.dart';
import '../viewmodels/incidente_viewmodel.dart';

class ReportIncidentDialog extends StatelessWidget {
  final PickupRequest pickupRequest;

  const ReportIncidentDialog({super.key, required this.pickupRequest});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = dateFormat.format(pickupRequest.createdAt);

    return ChangeNotifierProvider(
      create: (_) => ReportIncidentViewModel()..fetchUserNames(pickupRequest.collectorId, pickupRequest.userId),
      child: Consumer<ReportIncidentViewModel>(
        builder: (context, viewModel, _) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reporte de incidencias',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  /// Información de la recolección
                  _buildInfoRow('Recolección: ${pickupRequest.requestId}'),
                  _buildInfoRow('Recolector: ${viewModel.collectorName ?? 'Cargando...'}'),
                  _buildInfoRow('Generador: ${viewModel.userName ?? 'Cargando...'}'),
                  _buildInfoRow('Fecha: $formattedDate'),

                  const SizedBox(height: 20),

                  /// Motivo del reporte
                  const Text('¿Cuál es el motivo de tu reporte?'),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 3,
                    onChanged: (value) {
                      viewModel.details = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Escribe aquí los detalles...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Tipo de reporte
                  const Text('Tipo:'),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: viewModel.selectedType,
                    items: <String>[
                      'Incidente',
                      'Retraso',
                      'Mal comportamiento',
                      'Sugerencia',
                      'Otro',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      viewModel.setSelectedType(newValue);
                    },
                    hint: const Text('Seleccionar tipo'),
                  ),
                  const SizedBox(height: 20),

                  /// Botones: Cancelar y Enviar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          // Verificar que ambos campos estén completos
                          if ((viewModel.details?.isEmpty ?? true) || viewModel.selectedType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Por favor, completa todos los campos.'),
                                backgroundColor: Colors.red, // SnackBar rojo
                              ),
                            );
                            return;
                          }

                          // Enviar el reporte
                          await viewModel.sendIncidentReport(pickupRequest);

                          // Mostrar SnackBar con mensaje de éxito
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reporte enviado exitosamente'),
                              backgroundColor: Colors.green, // SnackBar verde
                            ),
                          );

                          // Cerrar el diálogo
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Enviar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Método para crear las filas de información
  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
