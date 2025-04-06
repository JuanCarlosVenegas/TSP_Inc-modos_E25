import 'package:flutter/material.dart';
import '../views/register_screen.dart';
import '../repositories/login_repository.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final LoginRepository _repository = LoginRepository();
  bool isCollector = false;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      setLoading(true);

      final isLoggedIn = await _repository.loginUser(email, password);

      if (isLoggedIn) {
        final userData = await _repository.getUserData(email);

        if (userData != null) {
          isCollector = userData['isCollector'] ?? false;
          final userId = userData['id'];

          return userId;
        } else {
          return "No se encontraron datos del usuario";
        }
      } else {
        return "Correo o contraseña incorrectos";
      }
    } catch (e) {
      return "Error inesperado: ${e.toString()}";
    } finally {
      setLoading(false);
    }
  }

  Future<void> register(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }
}
