import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'dart:convert'; // para utf8
import 'package:crypto/crypto.dart';

class RegisterViewModel extends ChangeNotifier {
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

  // Registro sin FirebaseAuth
  Future<void> registerUser(UserModel user, BuildContext context) async {
    try {
      setLoading(true);

      // Verificar si el correo ya existe
      final existingUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (existingUsers.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("El correo ya está registrado")),
        );
        return;
      }

      final hashedPassword = hashPassword(user.password);

      await FirebaseFirestore.instance.collection('users').add({
        'name': user.name,
        'email': user.email,
        'isCollector': user.isCollector,
        'password': hashedPassword,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cuenta registrada exitosamente")),
      );

    //  Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: ${e.toString()}")),
      );
    } finally {
      setLoading(false);
    }
  }
}
