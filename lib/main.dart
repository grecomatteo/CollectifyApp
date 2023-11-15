import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'VentanaInicio.dart';
import 'package:uni_links3/uni_links.dart';

//Placeholder, cambiar
Usuario u = new Usuario();

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
