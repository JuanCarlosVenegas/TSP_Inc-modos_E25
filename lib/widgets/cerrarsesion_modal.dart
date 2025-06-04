import 'package:flutter/material.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutConfirmationDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              '¿Cerrar sesión?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text(
              '¿Estás seguro de que deseas cerrar sesión?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 211, 16, 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm();
                    },
                    child: const Text(
                      'Cerrar sesión',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
