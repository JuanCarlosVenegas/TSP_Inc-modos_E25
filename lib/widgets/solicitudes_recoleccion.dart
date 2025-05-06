// widgets/draggable_requests_sheet.dart
import 'package:flutter/material.dart';
import '../viewmodels/recolector_viewmodel.dart';
import 'recuest_card.dart';

class DraggableRequestsSheet extends StatelessWidget {
  final PendingRequestsViewModel viewModel;

  const DraggableRequestsSheet({super.key, required this.viewModel});

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
                  "Solicitudes de recolección",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: viewModel.pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = viewModel.pendingRequests[index];
                    return RequestCard(request: request, viewModel: viewModel);
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
