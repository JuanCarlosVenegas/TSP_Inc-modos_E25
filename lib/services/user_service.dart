import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getUserNameById(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc['name'];
      }
    } catch (e) {
      print('Error al obtener el nombre de usuario: $e');
    }
    return null;
  }

  Future<String?> getUserRoleById(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final isCollector = userDoc['isCollector'] ?? false;
        return isCollector ? 'recolector' : 'generador';
      }
    } catch (e) {
      print('Error al obtener el rol del usuario: $e');
    }
    return null;
  }
}
