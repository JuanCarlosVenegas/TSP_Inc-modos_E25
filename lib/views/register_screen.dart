import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_viewmodel.dart'; 
import '../models/user_model.dart';  

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controladores de texto
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isCollector = false; // Estado local para el switch

  @override
  Widget build(BuildContext context) {
    // Accediendo al ViewModel con Consumer para que sea reactivo
    return ChangeNotifierProvider(
      create: (context) => RegisterViewModel(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade800,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/locoEcoRide.png',
                  height: 30,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'EcoRide',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green.shade200, Colors.green.shade800],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono de usuario arriba de los campos de texto
                  Icon(
                    Icons.account_circle,
                    size: 150, // Tamaño del icono
                    color: Colors.white,
                  ),
                  SizedBox(height: 20), // Espacio entre el icono y los campos de texto
                  
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.green.shade700,
                      prefixIcon: Icon(Icons.person, color: Colors.white), // Icono en el campo
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.green.shade700,
                      prefixIcon: Icon(Icons.email, color: Colors.white), // Icono en el campo
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.green.shade700,
                      prefixIcon: Icon(Icons.lock, color: Colors.white), // Icono en el campo
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "¿Eres recolector?",
                        style: TextStyle(color: Colors.white),
                      ),
                      Switch(
                        value: isCollector,
                        onChanged: (value) {
                          setState(() {
                            isCollector = value; // Actualiza el estado local
                          });
                        },
                        activeColor: Colors.white,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Consumer<RegisterViewModel>(
                    builder: (context, registerViewModel, child) {
                      return registerViewModel.isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 40),
                              ),
                              onPressed: () {
                                final user = UserModel(
                                  name: nameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                  isCollector: isCollector,
                                );
                                registerViewModel.registerUser(user, context);
                              },
                              child: Text(
                                "Crear Cuenta",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
