/*
 * Pantalla de historial de recolecciones
 *
 * De momento muestra todas las recolecciones, -no tiene fintro de usuario. -toda la logica está en esta misma clase.
 */


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HistorialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: Text('Historial')),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pickup_requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay recolecciones.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              //como unico dato se muestra la cantidad de cada recoleccion.
              final amount = data['amount']?.toString() ?? 'Sin cantidad';

              return ListTile(
                title: Text('Cantidad: $amount')
              );
            },
          );
        },
      ),
    );
  }
}