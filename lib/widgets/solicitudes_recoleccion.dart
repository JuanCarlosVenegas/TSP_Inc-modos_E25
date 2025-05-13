import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoride/models/recoleccion_model.dart';
import 'package:flutter/material.dart';
import '../viewmodels/recolector_viewmodel.dart';
import '../widgets/recuest_card.dart';

class DraggableRequestsSheet extends StatelessWidget {
  final PendingRequestsViewModel viewModel;

  const DraggableRequestsSheet({super.key, required this.viewModel});

  /// ✅ Método para aceptar la solicitud y actualizar la lista local
  /// ✅ Método para aceptar la solicitud y actualizar la lista local
  Future<void> _handleAcceptRequest(
    PickupRequest request,
    BuildContext context,
  ) async {
    await viewModel.acceptRequest(request);

    // ✅ Eliminar la solicitud localmente del ViewModel
    viewModel.removeRequest(request);

    // ✅ Notificar cambios para actualizar la UI
    viewModel.notifyListeners();

    // ✅ Verificar si el contexto aún está montado antes de mostrar el SnackBar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recolección aceptada correctamente.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Solicitudes pendientes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('pickup_requests')
                          .where('status', isEqualTo: 'Pendiente')
                          .snapshots(), // 🔄 Escucha en tiempo real
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay solicitudes pendientes.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    final requests =
                        snapshot.data!.docs.map((doc) {
                          return PickupRequest.fromJson(
                            doc.data() as Map<String, dynamic>,
                          );
                        }).toList();

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return RequestCard(
                          request: request,
                          viewModel: viewModel,
                          onAcceptRequest:
                              (request) =>
                                  _handleAcceptRequest(request, context),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
