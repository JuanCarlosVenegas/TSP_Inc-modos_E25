import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../views/register_screen.dart';
import 'recolector_screen.dart';
import 'generador_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Scaffold(
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      'assets/locoEcoRide.png',
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: emailController,
                    label: 'Correo electrónico',
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: passwordController,
                    label: 'Contraseña',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  Consumer<LoginViewModel>(
                    builder: (context, loginViewModel, child) {
                      return loginViewModel.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: _buttonStyle(),
                              onPressed: () async {
                                final userId = await loginViewModel.login(
                                  emailController.text,
                                  passwordController.text,
                                );

                                if (userId != null) {
                                  final isCollector = loginViewModel.isCollector;

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => isCollector
                                          ? const PendingRequestsScreen()
                                          : RequestPickupScreen(userId: userId),
                                    ),
                                  );
                                }
                              },
                              child: const Text("INICIAR SESIÓN", style: TextStyle(color: Colors.white)),
                            );
                    },
                  ),
                  const SizedBox(height: 10),
                  Consumer<LoginViewModel>(
                    builder: (context, loginViewModel, child) {
                      return ElevatedButton(
                        style: _buttonStyle().copyWith(
                          backgroundColor: MaterialStateProperty.all(Colors.green.shade600),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        ),
                        child: const Text("REGISTRARSE", style: TextStyle(color: Colors.white)),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "EcoRide",
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          labelStyle: const TextStyle(color: Colors.white),
        ),
        style: const TextStyle(color: Colors.white),
        obscureText: obscureText,
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 33, 121, 39),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
    );
  }
}
