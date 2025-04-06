import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Paquete para formatear la moneda

class MoneyTextInputFormatter extends TextInputFormatter {
  final NumberFormat format = NumberFormat.currency(symbol: '\$', decimalDigits: 2, locale: 'es_MX');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Eliminamos cualquier valor no numérico (excepto el punto)
    String text = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Aplicamos el formato monetario si el texto tiene al menos un número
    if (text.isNotEmpty) {
      try {
        double value = double.parse(text);
        String formattedText = format.format(value / 100); // Dividimos por 100 para manejar los centavos
        return newValue.copyWith(text: formattedText, selection: TextSelection.collapsed(offset: formattedText.length));
      } catch (e) {
        return newValue.copyWith(text: '');
      }
    } else {
      return newValue.copyWith(text: '');
    }
  }
}
