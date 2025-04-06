import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LoginRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para encriptar la contraseña
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Función para verificar el inicio de sesión
  Future<bool> loginUser(String email, String password) async {
    try {
      final hashedPassword = hashPassword(password);

      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: hashedPassword)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception("Error al verificar el inicio de sesión: ${e.toString()}");
    }
  }

  // Función para obtener datos del usuario, incluyendo el ID
  Future<Map<String, dynamic>?> getUserData(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        data['id'] = doc.id; //  Agregamos el ID generado por Firestore
        return data;
      }

      return null;
    } catch (e) {
      throw Exception("Error al obtener los datos del usuario: ${e.toString()}");
    }
  }
}
