import 'package:flutter/material.dart';
import '../viewmodels/generador_viewmodel.dart';

class ConfirmRequestDialog extends StatelessWidget {
  final PickupRequestViewModel viewModel;
  final VoidCallback onConfirm;

  const ConfirmRequestDialog({
    super.key,
    required this.viewModel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 60, color: Colors.green.shade700),
            const SizedBox(height: 12),
            const Text(
              'Confirmar Pedido',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Ubicación', viewModel.locationController.text),
            _buildDetailRow('Hora', viewModel.timeController.text),
            _buildDetailRow('Monto', viewModel.amountController.text),
            _buildDetailRow('Tipo de residuo', viewModel.selectedWasteType),
            _buildDetailRow('Cantidad', viewModel.quantityController.text),
            _buildDetailRow('Tamaño', viewModel.sizeLabel),
            _buildDetailRow('Fotos subidas', '${viewModel.selectedImages.length}'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.green.shade700),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  child: const Text('Confirmar', style: TextStyle(fontSize: 16)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}
