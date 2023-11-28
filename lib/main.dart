import 'dart:async';
import 'package:collectify/VentanaProducto.dart';
import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'VentanaInicio.dart';
import 'package:uni_links3/uni_links.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, PlatformException, SystemChrome;

import 'package:collectify/notification.dart' as notificaciones;
import 'package:workmanager/workmanager.dart';

///////////



final StreamController<Widget> _streamController =
    StreamController<Widget>.broadcast();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
      callbackDispatcher,
      );

  Workmanager().registerOneOffTask(
    "task",
    "simpleTask",
  );
  
  Conexion().conectar();
  initUniLinks();
  runApp( MyApp());


}

Future<void> initUniLinks() async {
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    final initialLink = await getInitialLink();
    // Parse the link and warn the user, if it is not correct,
    // but keep in mind it could be `null`.
    handleLink(initialLink).then((value) => _streamController.add(value));
  } on PlatformException {
    // Handle exception by warning the user their action did not succeed
    // return?
  }
  linkStream.listen((String? link) {
    // Parse the link and warn the user, if it is not correct
    handleLink(link).then((value) => _streamController.add(value));
  }, onError: (err) {
    // Handle exception by warning the user their action did not succeed
  });
}

Future<Widget> handleLink(String? link) async {
  if (link != null) {
    List<Producto> productos = await Conexion().getAllProductos();
    Usuario u = await Conexion().getUsuarioByNick('admin') as Usuario;
    for (var p in productos) {
      if (link == "https://collectify.es/${p.productoID}") {
        return VentanaProducto(
          connected: u,
          producto: p,
        );
      }
    }
  }
  return const VentanaInicio();
}

class MyApp extends StatelessWidget {
  //Punto inicial, no tocar
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      title: 'Collectify',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<Uri?>(
          stream: uriLinkStream,
          builder: (context, snapshot) {
            return StreamBuilder<Widget>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) return snapshot.data!;
                  //Loading
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                });
          }),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher(){
  Workmanager().executeTask((task, inputData)  {
    notificaciones.Notification.showBigTextNotification(
        title: "Primera",
        body: "Primera notificacion",
        fln: FlutterLocalNotificationsPlugin()

    );

    return Future.value(true);
  });
}

