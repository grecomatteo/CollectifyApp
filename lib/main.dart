import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';

import 'VentanaInicio.dart';

//Placeholder, cambiar
Usuario u = new Usuario();
void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  Conexion().conectar();

}

class MyApp extends StatelessWidget { //Punto inicial, no tocar
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      home:  const VentanaInicio(),
    );
  }
}
