import 'package:collectify/VentanaValoracion.dart';
import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'VentanaInicio.dart';
import 'package:uni_links3/uni_links.dart';
import 'ConexionBD.dart';


//Placeholder, cambiar
Usuario u = Usuario();

void main(){
  runUriLinks();
  runApp(const MyApp());
  Conexion().conectar();
}

Future<void> runUriLinks() async {
  try{
      WidgetsFlutterBinding.ensureInitialized();
      final initialLink = await getInitialLink();
      handleLink(initialLink);
      uriLinkStream.listen((Uri? uri) {
      handleLink(uri.toString());
    });
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
  }
}
Future<void> handleLink(String? link) async {
  List<Producto> productos = await Conexion().getProductos();
  u = await Conexion().getUsuarioByNick('admin') as Usuario;
  for(var p in productos){
    if (link == "https://Collectify.es/${p.productoID}") {
      VentanaValoracion(connected: u, producto: p,);
    }
  }
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
