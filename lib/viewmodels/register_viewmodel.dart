import 'package:flutter/material.dart';
import '../repositories/register_repository.dart'; // Asegúrate de importar el RegisterRepository
import '../models/user_model.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final RegisterRepository _repository = RegisterRepository();

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> registerUser(UserModel user, BuildContext context) async {
    try {
      setLoading(true);

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

      // Puedes navegar a otra pantalla si el registro es exitoso
      // Navigator.pop(context);

    //NOOTAAA: falta redirijirlo a la pagina logeado.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: ${e.toString()}")),
      );
    } finally {
      setLoading(false);
    }
  }
}
