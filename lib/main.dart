import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collectify/VentanaProducto.dart';
import 'package:flutter/material.dart';
import 'package:collectify/ConexionBD.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'VentanaInicio.dart';
import 'package:uni_links3/uni_links.dart';
import 'package:flutter/services.dart'
    show DeviceOrientation, PlatformException, SystemChrome;

import 'package:collectify/notification.dart' as notificaciones;
import 'package:workmanager/workmanager.dart';

///////////

int state = 0;




final StreamController<Widget> _streamController =
    StreamController<Widget>.broadcast();
Socket gSocket = Socket.connect('bytedev.es',55555) as Socket;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  final pref = await SharedPreferences.getInstance();

  print(await pref.getInt('ID'));
  Workmanager().registerOneOffTask(
    "1",
    "socketTask",
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
    debugPrint(err.toString());
  });
}

Future<Widget> handleLink(String? link) async {
  if (link != "" && link != null) {
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
    return SafeArea(child: MaterialApp(
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
                  return const VentanaInicio();
                });
          }),
    ));
  }
}

@pragma('vm:entry-point')
Future<void> callbackDispatcher() async {
  print("Se está ejecutando una tarea en segundo plano");
  await Socket.connect('bytedev.es',55555).then((socket) {
    gSocket = socket;
    print('Connected to: ' + '${socket.remoteAddress.address}:${socket.remotePort}');
    socket.write("ConnectedUser:1");
    socket.listen(socketDispatcher);

  });
  Workmanager().executeTask((task, inputData)  async {
    print("Se está ejecutando una tarea en segundo plano2...");
    await Socket.connect('bytedev.es',55555).then((socket) {
      gSocket = socket;
      print('Connected to: ' + '${socket.remoteAddress.address}:${socket.remotePort}');
      socket.write("ConnectedUser:1");
      socket.listen(socketDispatcher);

    });

    return Future.value(true);
  });
}

@pragma('vm:entry-point')
void socketDispatcher(List<int> event){
  print("Manejador de sockets");
  String message = utf8.decode(event);
  if(message.startsWith("NewMessage")){
    print("NewMessage");
    notificaciones.Notification.showBigTextNotification(
        title: "Nuevo mensaje",
        body: "Tienes un nuevo mensaje",
        fln: FlutterLocalNotificationsPlugin()

    );
  }
}


