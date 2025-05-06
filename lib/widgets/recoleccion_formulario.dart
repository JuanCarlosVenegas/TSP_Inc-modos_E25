import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../viewmodels/generador_viewmodel.dart';

class MainRequestForm extends StatelessWidget {
  final PickupRequestViewModel viewModel;

  const MainRequestForm({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Solicitar recolección", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        TextField(
          controller: viewModel.locationController,
          decoration: _inputDecoration("Tu ubicación"),
          focusNode: viewModel.locationFocusNode,
          onSubmitted: (value) => viewModel.updatePositionFromAddress(value),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () async {
                  TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) => Theme(
                      data: ThemeData.light().copyWith(
                        primaryColor: Colors.green,
                        colorScheme: const ColorScheme.light(primary: Colors.green),
                        buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                      ),
                      child: child!,
                    ),
                  );
                  if (selectedTime != null) {
                    viewModel.timeController.text = selectedTime.format(context);
                    viewModel.notifyListeners();
                  }
                },
                child: InputDecorator(
                  decoration: _inputDecoration("Hora"),
                  child: Text(
                    viewModel.timeController.text.isEmpty
                        ? 'Seleccionar hora'
                        : viewModel.timeController.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: viewModel.amountController,
                decoration: _inputDecoration("Monto"),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  MoneyInputFormatter(
                    leadingSymbol: '\$',
                    useSymbolPadding: true,
                    thousandSeparator: ThousandSeparator.Comma,
                    mantissaLength: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => viewModel.toggleWasteForm(true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const SizedBox(width: double.infinity, child: Center(child: Text("Agregar detalles"))),
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          onPressed: viewModel.confirmRequest,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const SizedBox(width: double.infinity, child: Center(child: Text("Confirmar"))),
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
