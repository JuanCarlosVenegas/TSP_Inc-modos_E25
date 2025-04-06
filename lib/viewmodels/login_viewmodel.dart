import 'package:flutter/material.dart';
import '../views/register_screen.dart';
import '../repositories/login_repository.dart';
import '../views/generador_home_screen.dart'; // ✅ Importa la pantalla destino

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final LoginRepository _repository = LoginRepository();
  bool isCollector = false;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Intenta iniciar sesión y redirige si es exitoso.
  Future<String?> login(String email, String password, BuildContext context) async {
    try {
      setLoading(true);

      final isLoggedIn = await _repository.loginUser(email, password);

      if (isLoggedIn) {
        final userData = await _repository.getUserData(email);

        if (userData != null) {
          isCollector = userData['isCollector'] ?? false;
          final userId = userData['id']; // Firestore user ID

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inicio de sesión exitoso")),
          );

          // ✅ Redirige a RequestPickupScreen con el userId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RequestPickupScreen(userId: userId),
            ),
          );

          return userId;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se encontraron datos del usuario")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Correo o contraseña incorrectos")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: ${e.toString()}")),
      );
    } finally {
      setLoading(false);
    }

    return null;
  }

  Future<void> register(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }
}
