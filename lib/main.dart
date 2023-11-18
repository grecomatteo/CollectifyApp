import 'dart:async';

import 'package:collectify/VentanaValoracion.dart';
import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'VentanaInicio.dart';
import 'package:uni_links3/uni_links.dart';
import 'ConexionBD.dart';


void main(){
  Conexion().conectar();
  runApp(const MyApp());
}

Future<Widget> handleLink(String? link) async {
  if(link != null) {
    List<Producto> productos = await Conexion().getProductos();
    Usuario u = await Conexion().getUsuarioByNick('admin') as Usuario;
    for (var p in productos) {
      if (link!.toLowerCase() == "https://collectify.es/${p.productoID}") {
        return VentanaValoracion(connected: u, producto: p,);
      }
    }
  }
  return const VentanaInicio();
}

class MyApp extends StatelessWidget { //Punto inicial, no tocar
  const MyApp({super.key});

  static final StreamController<Widget> _streamController = StreamController<Widget>.broadcast();

  static void refresh(Uri? link) async {
    await handleLink(link.toString()).then((value) => _streamController.add(value));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      home:  StreamBuilder<Uri?>(
        stream: uriLinkStream,
        builder: (context, snapshot) {
          refresh(snapshot.data);
          return StreamBuilder<Widget>(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              if(snapshot.hasData) return snapshot.data!;
              return const VentanaInicio();
            }
          );
        }
      ),
    );
  }
}
