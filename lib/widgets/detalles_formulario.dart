import 'package:flutter/material.dart';
import '../viewmodels/generador_viewmodel.dart';

class WasteDetailsForm extends StatelessWidget {
  final PickupRequestViewModel viewModel;

  const WasteDetailsForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Detalles de la basura", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: viewModel.selectedWasteType,
                decoration: _inputDecoration('Tipo de residuo'),
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Orgánico', child: Text('Orgánico')),
                  DropdownMenuItem(value: 'Reciclable', child: Text('Reciclable')),
                ],
                onChanged: (value) => viewModel.updateWasteType(value!),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 110,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: viewModel.decreaseQuantity,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Center(child: Text(viewModel.quantityController.text, style: const TextStyle(fontSize: 16))),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: viewModel.increaseQuantity,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Tamaño", style: TextStyle(fontWeight: FontWeight.bold)),
        Center(
          child: SizedBox(
            width: 250,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.green,
                inactiveTrackColor: Colors.green[100],
                thumbColor: Colors.green,
                overlayColor: Colors.green.withOpacity(0.2),
                valueIndicatorColor: Colors.green,
              ),
              child: Slider(
                value: viewModel.sizeValue,
                min: 1,
                max: 3,
                divisions: 2,
                label: viewModel.sizeLabel,
                onChanged: (value) => viewModel.updateSize(value.toInt()),
              ),
            ),
          ),
        ),
        Center(child: Text("Tamaño seleccionado: ${viewModel.sizeLabel}")),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: viewModel.selectedImages.length >= 3 ? null : viewModel.pickImage,
          icon: const Icon(Icons.upload_file),
          label: Text("Subir foto (${viewModel.selectedImages.length}/3)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
          ),
        ),
        if (viewModel.selectedImages.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: viewModel.selectedImages
                .map(
                  (file) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => viewModel.toggleWasteForm(false),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const SizedBox(width: double.infinity, child: Center(child: Text("Continuar"))),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }
}
