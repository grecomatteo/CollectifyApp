import 'package:collectify/ConexionBD.dart';
import 'package:collectify/VentanaListaProductos.dart';
import 'package:flutter/material.dart';
import 'package:collectify/VentanaRegister.dart';
import 'package:mysql1/mysql1.dart';

MySqlConnection? conn;
String nick = "";
String pswrd = "";

void main() {
  runApp(VentanaLogin());
}


Future<bool> validateFields() async{
  conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: "collectify-server-mysql.mysql.database.azure.com",
        port: 3306,
        user: "pin2023",
        password: "AsLpqR_23",
        db: "collectifyDB",
      ));

  await conn?.query('select * from users where (nick = $nick AND contrasena = $pswrd)').then((result) {
    if (result != null) return true;
  }
  );
  return false;
  //return true;
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
      body: Login()
    );
  }
}

class Login extends StatelessWidget {
   Login({super.key});

  final TextEditingController usernameText = TextEditingController();
  final TextEditingController passwordText = TextEditingController();
  String errorText = "";

  @override
  Widget build(BuildContext context) {
              return Column(
                children: [
                  Text("Nombre de usuario"),
                  TextField(
                    controller: usernameText,
                      textAlign: TextAlign.center
                  ),
                  Text("Contraseña"),
                  TextField(
                    controller: passwordText,
                      textAlign: TextAlign.center,
                      obscureText: true
                  ),
                  TextButton(
                    child: Text("Iniciar sesión"),
                    onPressed: () async{
                      nick = usernameText.text;
                      pswrd = passwordText.text;
                      if(await Conexion().login(nick, pswrd) !=null){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ListaProductos()));
                      }
                      else{
                          errorText = "Usuario o contraseña incorrectos";
                        }
                      }
                  ),
                  TextButton(
                      child: Text("Registrarse"),
                      onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => VentanaRegister()));
                      }
                  ),
                ],
              );

  }


}
