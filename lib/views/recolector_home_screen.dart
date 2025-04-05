import 'package:flutter/material.dart';

class EnConstruccionWidget extends StatelessWidget {
  const EnConstruccionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("En construcción"),
      ),
      body: Center(
        child: Text(
          'Esta sección está en construcción',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}
