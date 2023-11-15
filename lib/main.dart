import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'VentanaInicio.dart';

//Placeholder, cambiar
Usuario u = new Usuario();

void main(){
  runURILINKS();
  runApp(const MyApp());
  Conexion().conectar();
}

Future<void> runURILINKS() async {
  try{
      WidgetsFlutterBinding.ensureInitialized();
      String? initialLink = await getInitialLink();
      handleLink(initialLink);

      uriLinkStream.listen((Uri? uri) {
      handleLink(uri.toString());
    });
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
  }
}
void handleLink(String? link) {
  if (link != null) {
    print(link);
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
