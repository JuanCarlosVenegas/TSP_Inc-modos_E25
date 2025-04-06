import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';

class RegisterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para encriptar la contraseña
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Verificar si el correo ya está registrado
  Future<bool> emailExists(String email) async {
    try {
      final existingUsers = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return existingUsers.docs.isNotEmpty;
    } catch (e) {
      throw Exception("Error al verificar si el correo existe: ${e.toString()}");
    }
  }

  // Función para registrar un nuevo usuario
  Future<void> registerUser(UserModel user) async {
    try {
      final hashedPassword = hashPassword(user.password);

      await _firestore.collection('users').add({
        'name': user.name,
        'email': user.email,
        'isCollector': user.isCollector,
        'password': hashedPassword,
      });
    } catch (e) {
      throw Exception("Error al registrar el usuario: ${e.toString()}");
    }
  }
}
