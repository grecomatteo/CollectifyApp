import 'package:flutter/material.dart';
import 'package:collectify/main.dart';

void main() {
  runApp(const VentanaLogin());
}



bool validateFields() {
  return true;
}

class VentanaLogin extends StatelessWidget { //Punto inicial, no tocar
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("¡Bienvenido a Collectify!"),
      ),
      body: const Login()
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
              return Column(
                children: [
                  Text("Nombre de usuario"),
                  TextField(
                      textAlign: TextAlign.center
                  ),
                  Text("Contraseña"),
                  TextField(
                      textAlign: TextAlign.center,
                      obscureText: true
                  ),
                  TextButton(
                    child: Text("Iniciar sesión"),
                    onPressed: () {
                      if(validateFields()){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp()));
                      }
                    }
                  ),
                ],
              );
  }
}