import 'package:collectify/ConexionBD.dart';
import 'package:collectify/VentanaListaProductos.dart';
import 'package:flutter/material.dart';
import 'package:collectify/VentanaRegister.dart';

String nick = "";
String pswrd = "";
Usuario logged = new Usuario();

class VentanaLogin extends StatefulWidget {
  const VentanaLogin({super.key});

  //String title;

  @override
  State<VentanaLogin> createState() => _LoginPageState();
}

class _LoginPageState extends State<VentanaLogin> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Login(),
        backgroundColor: Colors.black,
    );
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
            Navigator.pop(context),
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
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
                const Text('Bienvenido a',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Aeonik',
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(30),
                  //height: 80,
                  transformAlignment: Alignment.center,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/collectify.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                height: 320,
                child: ShaderMask(
                    shaderCallback: (Rect rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.purple, Colors.transparent, Colors.transparent, Colors.purple],
                        stops: [0.0, 0.1, 0.9, 1.0], // 10% purple, 80% transparent, 10% purple
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstOut,
                    child: ListView(
                      //make smaller when keyboard is open
                      shrinkWrap: true,

                      padding: const EdgeInsets.all(10.0),
                      children: [
                        const SizedBox(height: 25,),
                        TextField(controller: usernameText,
                            textAlign: TextAlign.start,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              labelStyle: TextStyle(color: Color.fromRGBO(255,255,255, 0.4)),
                              filled: true,
                              fillColor: Color.fromRGBO(52,52,52, 1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(179, 255, 119, 1), width: 2.0),
                              ),
                            )
                        ),
                        const SizedBox(height: 20,),
                        TextField(controller: passwordText,
                            textAlign: TextAlign.start,
                            style: const TextStyle(color: Colors.white),
                            obscureText: true,
                            onSubmitted: (value) {
                              subbmitHandler(context);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(color: Color.fromRGBO(255,255,255, 0.4)),
                              filled: true,
                              fillColor: Color.fromRGBO(52,52,52, 1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(179, 255, 119, 1), width: 2.0),
                              ),
                            )
                        ),
                      ],
                    )
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 30,),
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(254,111,31, 1),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: IconButton(
                    onPressed: () => subbmitHandler(context),
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    color: Colors.white,
                    iconSize: 40,
                  ),
                ),
                const SizedBox(height: 30,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿Aún no eres miembro?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Aeonik',
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  VentanaRegister()));
                      },
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Aeonik',
                          color: Color.fromRGBO(254, 111, 31, 1),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        )
    );
  }
}
