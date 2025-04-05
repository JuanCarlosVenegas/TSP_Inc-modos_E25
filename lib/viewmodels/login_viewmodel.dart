import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../views/register_screen.dart';
import '../views/recolector_home_screen.dart';
import '../views/generador_home_screen.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      setLoading(true);

      final hashedPassword = hashPassword(password);

      // Buscar usuario por email y contraseña encriptada
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: hashedPassword)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Usuario válido
        final userData = querySnapshot.docs.first.data();
        final isCollector = userData['isCollector'] ?? false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Inicio de sesión exitoso")),
        );

        // Aquí puedes navegar a otra pantalla dependiendo del tipo de usuario
        if (isCollector) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RequestPickupScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EnConstruccionWidget()),
          );
        }

      } else {
        // Usuario no encontrado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Correo o contraseña incorrectos")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: ${e.toString()}")),
      );
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
