//import 'package:collectify/VentanaChat.dart';
import 'package:flutter/material.dart';
//import 'package:collectify/VentanaAnadirProducto.dart';
import 'package:collectify/VentanaListaProductos.dart';
import 'package:collectify/ConexionBD.dart';


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

      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return  ListaProductos();
  }
}
