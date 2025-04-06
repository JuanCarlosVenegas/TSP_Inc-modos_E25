import 'package:flutter/material.dart';
import '../repositories/register_repository.dart'; // Asegúrate de importar el RegisterRepository
import '../models/user_model.dart';
import '../views/recolector_screen.dart';
import '../views/generador_screen.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final RegisterRepository _repository = RegisterRepository();

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Validar correo
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Validar contraseña
  bool isValidPassword(String password) {
    return password.length >= 8 && password.contains(RegExp(r'\d'));
  }


  Future<void> registerUser(UserModel user, BuildContext context) async {
    try {
      setLoading(true);

      // Validación de correo y contraseña
      if (!isValidEmail(user.email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Por favor ingresa un correo válido")),
        );
        return;
      }

      if (!isValidPassword(user.password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("La contraseña debe tener al menos 8 caracteres y contener un número")),
        );
        return;
      }

      // Verificar si el correo ya está registrado
      bool emailAlreadyExists = await _repository.emailExists(user.email);

      if (emailAlreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("El correo ya está registrado")),
        );
        return;
      }

      // Registrar al usuario
      await _repository.registerUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cuenta registrada exitosamente")),
      );

      // Redirigir a la página correspondiente después del registro
      navigateToAppropriateScreen(context, user.email, user.isCollector);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: ${e.toString()}")),
      );
    } finally {
      setLoading(false);
    }
  }

  void navigateToAppropriateScreen(BuildContext context, String? userId, bool isCollector) {
    if (userId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isCollector
              ? const PendingRequestsScreen()
              : RequestPickupScreen(userId: userId),
        ),
      );
    }
  }
}
