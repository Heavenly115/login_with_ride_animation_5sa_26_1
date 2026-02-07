import 'package:flutter/material.dart';
// Se actualizó el nombre del paquete según tu carpeta raíz
import 'package:login_with_ride_animation_5sa_26_1/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta 'Debug' de la esquina
      title: 'Flutter Demo',
      theme: ThemeData(
        // Se corrigió el error: faltaba la clase 'ColorScheme' antes de .fromSeed
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}