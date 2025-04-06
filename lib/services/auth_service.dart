// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';

// class AuthService {
//   Future<bool> login(String email, String password) async {
//   try {
//     // Inicializa Firebase
//     await Firebase.initializeApp();

//     // Intenta iniciar sesión con el correo y la contraseña proporcionados
//     UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: email,
//       password: password,
//     );

//     // Si se inicia sesión correctamente, se devuelve true
//     return userCredential.user != null;
//   } on FirebaseAuthException catch (e) {
//     // Si ocurre un error (por ejemplo, usuario no encontrado o contraseña incorrecta)
//     print("Error de autenticación: ${e.message}");
//     return false;
//   }
// }


//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   Future<void> register(String name, String email, String password, bool isCollector) async {
//     try {
//       await _db.collection('users').doc(email).set({
//         'name': name,
//         'email': email,
//         'password': password, // ⚠️ No deberías guardar contraseñas en texto plano
//         'isCollector': isCollector,
//       });
//     } catch (e) {
//       print("Error al registrar usuario: $e");
//     }
//   // 
// }
