import 'package:collectify/ConexionBD.dart';
import 'package:collectify/VentanaListaProductos.dart';
import 'package:flutter/material.dart';
import 'package:collectify/VentanaRegister.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as noti;
import 'package:collectify/notification.dart' as notif;
import 'package:mysql1/mysql1.dart';

MySqlConnection? conn;
String nick = "";
String pswrd = "";
Usuario logged = new Usuario();

noti.FlutterLocalNotificationsPlugin notPlugin =
    noti.FlutterLocalNotificationsPlugin();

void main() {
  runApp(VentanaLogin());
}

class VentanaLogin extends StatelessWidget {
  //Punto inicial, no tocar
  const VentanaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  //String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    notif.Notification.initialize(notPlugin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("¡Bienvenido a Collectify!"),
        ),
        body: Login());
  }
}

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController usernameText = TextEditingController();
  final TextEditingController passwordText = TextEditingController();

  void subbmitHandler(BuildContext context) async {
    nick = usernameText.text;
    pswrd = passwordText.text;
    if (nick == "" || pswrd == "") {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Por favor, rellene todos los campos"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"))
              ],
            );
          });
      return;
    }

    try {
      await Conexion().login(nick, pswrd).then((value) => {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListaProductos(connected: value!))),
          });
    } catch (e) {
      debugPrint("Error");

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(e.toString()),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Nombre de usuario"),
        TextField(controller: usernameText, textAlign: TextAlign.center),
        const Text("Contraseña"),
        TextField(
          controller: passwordText,
          textAlign: TextAlign.center,
          obscureText: true,
          onSubmitted: (value) {
            subbmitHandler(context);
          },
        ),
        TextButton(
            child: const Text("Iniciar sesión"),
            onPressed: () async {
              subbmitHandler(context);
            }),
        TextButton(
            child: const Text("Registrarse"),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VentanaRegister()));
            }),
        TextButton(
            child: const Text("Funny button"),
            onPressed: () {
              notif.Notification.showBigTextNotification(
                  title: "Nuevo mensaje",
                  body: "Nuevo mensaje de Collectify",
                  fln: notPlugin);
            })
      ],
    );
  }
}
