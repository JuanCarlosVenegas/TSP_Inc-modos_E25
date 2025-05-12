/*
 * Pantalla de historial de recolecciones
 *
 * De momento muestra todas las recolecciones, -no tiene fintro de usuario. -toda la logica está en esta misma clase.
 */


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';



class HistorialScreen extends StatelessWidget {
  // Retorna un color según el estado de la recolección
  Color getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.amber;
      case 'Finalizado':
        return Colors.green;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Retorna un ícono representativo según el estado
  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Pendiente':
        return Icons.pending_actions;
      case 'Finalizado':
        return Icons.check_circle;
      case 'Cancelado':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  // Muestra un diálogo de confirmación para cancelar la solicitud
  void _mostrarDialogoCancelar(BuildContext context, String requestId, String address, double price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar recolección'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("¿Seguro que quieres cancelar la recolección?"),
              const SizedBox(height: 10),
              // Muestra la dirección y el precio de la solicitud
              Row(
                children: [
                  const Icon(Icons.place, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("\$${price.toStringAsFixed(2)}"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('No', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo
            ),
            TextButton(
              child: const Text('Sí', style: TextStyle(color: Colors.green)),
              onPressed: () async {
                // Actualiza el estado a "Cancelado" en Firestore
                await FirebaseFirestore.instance
                    .collection('pickup_requests')
                    .doc(requestId)
                    .update({'status': 'Cancelado'});
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  // Muestra un diálogo para reportar un incidente con detalles y tipo
  void _mostrarDialogoIncidente(BuildContext context, String requestId, String address, Timestamp? timestamp) {
    final TextEditingController descripcionController = TextEditingController();
    String? tipoSeleccionado;
    final DateTime? fecha = timestamp?.toDate();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reporte de incidencias'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información de la recolección
                Text("Recolección: $requestId"),
                const Text("Recolector: xxxxxxxx xxxxx"), // Se puede personalizar
                Text("Fecha: ${fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : 'dd/mm/aaaa'}"),
                const SizedBox(height: 12),
                const Text("¿Cuál es el motivo de tu reporte?"),
                const SizedBox(height: 6),
                // Campo para descripción del incidente
                TextField(
                  controller: descripcionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Escribe aquí los detalles...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Tipo:"),
                // Dropdown para seleccionar tipo de incidente
                DropdownButtonFormField<String>(
                  value: tipoSeleccionado,
                  items: ['Retraso', 'No llegó', 'Mala actitud', 'Otro']
                      .map((tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          ))
                      .toList(),
                  onChanged: (value) => tipoSeleccionado = value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(), // Cierra el diálogo
            ),
            TextButton(
              child: const Text('Enviar', style: TextStyle(color: Colors.green)),
              onPressed: () async {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (descripcionController.text.isNotEmpty && tipoSeleccionado != null) {
                  // Envía el reporte a Firestore
                  await FirebaseFirestore.instance.collection('incidentes').add({
                    'requestId': requestId,
                    'userId': userId,
                    'descripcion': descripcionController.text,
                    'tipo': tipoSeleccionado,
                    'timestamp': Timestamp.now(),
                    'direccion': address,
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reporte enviado')),
                  );
                } else {
                  // Validación de campos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Completa todos los campos')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      // Escucha en tiempo real los datos desde Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pickup_requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay recolecciones.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // Obtiene los campos relevantes del documento
              final String requestId = doc.id;
              final String status = data['status'] ?? 'Desconocido';
              final String address = data['address'] ?? 'Sin dirección';
              final String bags = data['amount']?.toString() ?? '0';
              final String category = data['category'] ?? 'General';
              final double price = (data['price'] ?? 0).toDouble();
              final Timestamp? timestamp = data['date'];
              final String hour = timestamp != null
                  ? DateFormat('h:mm a').format(timestamp.toDate())
                  : '';
              final String date = timestamp != null
                  ? DateFormat('dd/MM/yyyy').format(timestamp.toDate())
                  : '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fecha
                      Text(date, style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(height: 6),

                      // Estado y menú de acciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: getStatusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'cancelar') {
                                _mostrarDialogoCancelar(context, requestId, address, price);
                              } else if (value == 'incidente') {
                                _mostrarDialogoIncidente(context, requestId, address, timestamp);
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return <PopupMenuEntry<String>>[
                                if (status == 'Pendiente')
                                  const PopupMenuItem<String>(
                                    value: 'cancelar',
                                    child: Row(
                                      children: [
                                        Icon(Icons.cancel, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Cancelar'),
                                      ],
                                    ),
                                  ),
                                const PopupMenuItem<String>(
                                  value: 'incidente',
                                  child: Row(
                                    children: [
                                      Icon(Icons.report_problem, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text('Reportar incidente'),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      // Dirección y hora (si no está pendiente)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(address, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          if (status != 'Pendiente') Text(hour),
                        ],
                      ),

                      const SizedBox(height: 4),
                      // Información adicional
                      Text('- $bags - $category'),

                      const SizedBox(height: 6),
                      // Precio
                      Text(
                        '\$ ${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}