import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulación de datos de historial
    final List<Map<String, String>> historial = [
      //solo son placeholders
      {'fecha': '2025-05-05', 'descripcion': 'Recolección en Calle 10'},
      {'fecha': '2025-05-04', 'descripcion': 'Recolección en Calle 8'},
      {'fecha': '2025-05-03', 'descripcion': 'Recolección en Calle 12'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historial.length,
        itemBuilder: (context, index) {
          final item = historial[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.green),
              title: Text(item['descripcion'] ?? ''),
              subtitle: Text('Fecha: ${item['fecha']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
              },
            ),
          );
        },
      ),
    );
  }
}
