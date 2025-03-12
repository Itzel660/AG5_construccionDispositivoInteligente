import 'package:flutter/material.dart';
import 'home_page.dart'; // Importa la página principal

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clima y LED Control',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(), // Usa HomePage como pantalla principal
      debugShowCheckedModeBanner: false,
    );
  }
}
